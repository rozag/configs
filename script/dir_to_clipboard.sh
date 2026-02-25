#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: dir_to_clipboard.sh
# DESCRIPTION: Recursively reads text files in a directory and formats them
#              into a Markdown code block structure for the MacOS clipboard.
# USAGE: ./dir_to_clipboard.sh [directory_path]
# ==============================================================================

# 1. Defensive Options
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of the last command
#              to exit with a non-zero status, or zero if no command failed.
set -euo pipefail

# 2. Input Validation
target_dir="${1:-.}" # Default to current directory if no arg provided

if [[ ! -d "$target_dir" ]]; then
    echo "Error: Directory '$target_dir' does not exist." >&2
    exit 1
fi

if ! command -v pbcopy &> /dev/null; then
    echo "Error: 'pbcopy' not found. This script requires MacOS." >&2
    exit 1
fi

# 3. Helper Functions

# Check if a file is binary using grep.
# -I treats binary files as if they don't match.
# -q suppresses output.
# We search for a null character or known binary signature.
is_text_file() {
    local file="$1"
    # If file is empty, treat as text
    if [[ ! -s "$file" ]]; then return 0; fi

    # grep -Iq . checks if the file has printable characters and isn't binary
    grep -Iq . "$file"
}

generate_output() {
    # Find all files:
    # -type f: Files only
    # -not -path '*/.git/*': Ignore .git folder content
    # -print0: Print filename followed by null char (handles spaces/newlines safely)
    find "$target_dir" -type f -not -path '*/.git/*' -not -path '*/__pycache__/*' -print0 | \
    while IFS= read -r -d '' file; do

        # Skip binary files (images, DS_Store, etc)
        if ! is_text_file "$file"; then
            continue
        fi

        # Print the Header
        echo "# File \`$file\`:"
        echo "\`\`\`"

        # Print the Content
        cat "$file"

        # Ensure the closing fence is on a new line, even if file lacks EOF newline
        echo ""
        echo "\`\`\`"
        echo "" # Extra spacing between files
    done
}

# 4. Main Execution
echo "Processing files in '$target_dir'..." >&2

# Capture all output and pipe to clipboard
generate_output | pbcopy

echo "✅ Copied contents of '$target_dir' to clipboard." >&2
