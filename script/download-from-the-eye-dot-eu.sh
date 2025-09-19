#!/bin/bash

set -euo pipefail

# Global configuration
readonly SCRIPT_NAME=$(basename "$0")
readonly MAX_WORKERS=4
readonly TEMP_DIR=$(mktemp -d)
readonly WORK_QUEUE="${TEMP_DIR}/work_queue"
readonly ACTIVE_JOBS="${TEMP_DIR}/active_jobs"

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    # Kill any remaining background jobs
    jobs -p | xargs -r kill 2>/dev/null || true
    # Remove temporary files
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# URL decoding function using Python (more reliable than bash implementations)
url_decode() {
    local encoded="$1"
    python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$encoded"
}

# Parse HTML directory listing and extract file/folder links
parse_directory_listing() {
    local url="$1"
    local html_content

    echo "Parsing directory: $url" >&2

    # Fetch HTML content
    if ! html_content=$(curl -s --fail "$url"); then
        echo "Error: Failed to fetch $url" >&2
        return 1
    fi

    # Extract href attributes from <a class="overflow" tags and filter out parent directory
    echo "$html_content" | \
    grep -o '<a class="overflow" href="[^"]*"[^>]*>' | \
    sed 's/.*href="\([^"]*\)".*/\1/' | \
    while IFS= read -r href; do
        # Skip parent directory and empty hrefs
        if [[ "$href" != "../" ]] && [[ -n "$href" ]]; then
            echo "$href"
        fi
    done
}

# Download a single file
download_file() {
    local base_url="$1"
    local relative_path="$2"
    local output_dir="$3"

    # Construct full URL (handle URL encoding in the relative path)
    local encoded_path="$relative_path"
    local full_url="${base_url%/}/${encoded_path}"

    # Decode the path for local filesystem
    local decoded_path
    decoded_path=$(url_decode "$relative_path")
    local local_path="${output_dir}/${decoded_path}"
    local local_dir
    local_dir=$(dirname "$local_path")

    # Create local directory structure
    mkdir -p "$local_dir"

    echo "Downloading: $decoded_path"

    # Download file with progress and error handling
    if ! curl -s --fail --create-dirs -o "$local_path" "$full_url"; then
        echo "Error: Failed to download $full_url" >&2
        return 1
    fi

    echo "Completed: $decoded_path"
}

# Add work item to queue (thread-safe)
add_work() {
    local item="$1"
    local item_type="$2"  # 'file' or 'dir'

    {
        flock -x 200
        echo "${item_type}:${item}" >> "$WORK_QUEUE"
    } 200>"${WORK_QUEUE}.lock"
}

# Get work item from queue (thread-safe)
get_work() {
    local work_item=""

    {
        flock -x 200
        if [[ -s "$WORK_QUEUE" ]]; then
            work_item=$(head -n1 "$WORK_QUEUE")
            # Remove the first line
            if [[ $(wc -l < "$WORK_QUEUE") -gt 1 ]]; then
                tail -n +2 "$WORK_QUEUE" > "${WORK_QUEUE}.tmp"
                mv "${WORK_QUEUE}.tmp" "$WORK_QUEUE"
            else
                > "$WORK_QUEUE"  # Empty the file
            fi
        fi
    } 200>"${WORK_QUEUE}.lock"

    echo "$work_item"
}

# Process directory and add items to work queue
process_directory() {
    local base_url="$1"
    local dir_path="$2"
    local output_dir="$3"

    # Construct directory URL
    local dir_url
    if [[ -n "$dir_path" ]]; then
        dir_url="${base_url%/}/${dir_path}"
    else
        dir_url="$base_url"
    fi

    # Parse directory listing
    local items
    if ! items=$(parse_directory_listing "$dir_url"); then
        echo "Error: Failed to parse directory $dir_url" >&2
        return 1
    fi

    # Process each item found in the directory
    echo "$items" | while IFS= read -r item; do
        if [[ -n "$item" ]]; then
            local full_path
            if [[ -n "$dir_path" ]]; then
                full_path="${dir_path%/}/$item"
            else
                full_path="$item"
            fi

            # Determine if it's a file or directory based on trailing slash
            if [[ "$item" == */ ]]; then
                add_work "$full_path" "dir"
            else
                add_work "$full_path" "file"
            fi
        fi
    done
}

# Worker process function
worker() {
    local worker_id="$1"
    local base_url="$2"
    local output_dir="$3"

    echo "Worker $worker_id started"

    while true; do
        local work_item
        work_item=$(get_work)

        if [[ -z "$work_item" ]]; then
            # No work available, check if we should exit
            sleep 0.5
            continue
        fi

        # Parse work item
        local item_type="${work_item%%:*}"
        local item_path="${work_item#*:}"

        echo "Worker $worker_id processing $item_type: $item_path"

        case "$item_type" in
            "file")
                if ! download_file "$base_url" "$item_path" "$output_dir"; then
                    echo "Worker $worker_id: Download failed for $item_path" >&2
                fi
                ;;
            "dir")
                if ! process_directory "$base_url" "$item_path" "$output_dir"; then
                    echo "Worker $worker_id: Directory processing failed for $item_path" >&2
                fi
                ;;
            *)
                echo "Worker $worker_id: Unknown item type: $item_type" >&2
                ;;
        esac

        # Mark job as completed
        {
            flock -x 201
            echo "$(date): Worker $worker_id completed $item_type: $item_path" >> "$ACTIVE_JOBS"
        } 201>"${ACTIVE_JOBS}.lock"
    done
}

# Check if all work is completed
work_completed() {
    local queue_size
    {
        flock -s 200
        queue_size=$(wc -l < "$WORK_QUEUE" 2>/dev/null || echo "0")
    } 200>"${WORK_QUEUE}.lock"

    [[ "$queue_size" -eq 0 ]]
}

# Main function
main() {
    if [[ $# -ne 2 ]]; then
        cat << EOF
Usage: $SCRIPT_NAME <start_url> <output_directory>

Downloads all files from a directory listing recursively with $MAX_WORKERS parallel workers.

Example:
  $SCRIPT_NAME 'https://beta.the-eye.eu/public/Books/rpg.rem.uz/Paranoia/' ./downloads

Arguments:
  start_url         The base URL to start downloading from
  output_directory  Local directory where files will be saved

EOF
        exit 1
    fi

    local start_url="$1"
    local output_dir="$2"

    # Validate URL format
    if [[ ! "$start_url" =~ ^https?:// ]]; then
        echo "Error: Invalid URL format. Must start with http:// or https://" >&2
        exit 1
    fi

    # Ensure URL ends with slash for directory listings
    if [[ "$start_url" != */ ]]; then
        start_url="${start_url}/"
    fi

    # Create output directory
    if ! mkdir -p "$output_dir"; then
        echo "Error: Cannot create output directory: $output_dir" >&2
        exit 1
    fi

    # Convert to absolute path
    output_dir=$(cd "$output_dir" && pwd)

    echo "Starting recursive download from: $start_url"
    echo "Output directory: $output_dir"
    echo "Using $MAX_WORKERS parallel workers"
    echo ""

    # Initialize work queue and job tracking
    touch "$WORK_QUEUE" "$ACTIVE_JOBS"

    # Add initial directory to work queue
    add_work "" "dir"

    # Start worker processes
    local worker_pids=()
    for ((i=1; i<=MAX_WORKERS; i++)); do
        worker "$i" "$start_url" "$output_dir" &
        worker_pids+=($!)
    done

    echo "Started $MAX_WORKERS workers with PIDs: ${worker_pids[*]}"

    # Monitor progress
    local last_check_time=0
    local check_interval=5

    while true; do
        sleep 1

        local current_time
        current_time=$(date +%s)

        # Check work completion
        if work_completed; then
            # Give workers a moment to finish current tasks
            sleep 2
            if work_completed; then
                echo "All work completed!"
                break
            fi
        fi

        # Periodic status update
        if (( current_time - last_check_time >= check_interval )); then
            local remaining_work
            {
                flock -s 200
                remaining_work=$(wc -l < "$WORK_QUEUE" 2>/dev/null || echo "0")
            } 200>"${WORK_QUEUE}.lock"

            echo "Status: $remaining_work items remaining in queue"
            last_check_time=$current_time
        fi
    done

    # Terminate worker processes
    echo "Terminating workers..."
    for pid in "${worker_pids[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
        fi
    done

    # Wait for workers to finish
    wait

    echo ""
    echo "Download completed successfully!"
    echo "Files saved to: $output_dir"
}

# Ensure required dependencies are available
check_dependencies() {
    local deps=(curl python3)
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Error: Missing required dependencies: ${missing[*]}" >&2
        echo "Please install the missing dependencies and try again." >&2
        exit 1
    fi
}

# Run dependency check and main function
check_dependencies
main "$@"
