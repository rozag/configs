export ME=/Users/rozag
export ZSH=$ME/.oh-my-zsh
export LANG=en_US.UTF-8
export EDITOR="nvim"
export ZSH_THEME="gnzh"

# Go related stuff
export PATH="$PATH:$(go env GOPATH)/bin"

export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/bin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# Scripts
export PATH="$ME/configs/script:$PATH"

# Doom Emacs
export PATH="$ME/.emacs.d/bin:$PATH"

# Required by Poetry
export PATH="/Users/rozag/.local/bin:$PATH"

# OpenJDK
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"

plugins=(
  git
  zsh-syntax-highlighting
  # zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

export ENABLE_CORRECTION="true"

alias vi="nvim"
alias vim="nvim"
alias nvdiff="nvim -d -O" # neovim diff with vertical split

alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias advice="advice | cowsay"
alias :q="exit"
alias tarcd='tar -czf "../${PWD##*/}.tar.gz" .'
alias gmnf="git merge --no-ff"
alias gd="git icdiff"
alias gdf="git diff-tree --no-commit-id --name-only -r"
alias gcob="git checkout -b"
alias glb="git shortlog -sn"
alias ls="gls --color -hF --group-directories-first"
alias ll="ls -l"
alias lla="ll -a"

# ctags macOS fix
alias ctags="`brew --prefix`/bin/ctags"

alias python='python3'
alias pip='pip3'
alias vact='source .venv/bin/activate'

alias pod='podman'

alias t="task"

### BEGIN UNALIAS GIT PLUGIN ###
unalias glg
unalias glgg
unalias glgga
unalias glgm
unalias glgp
unalias glo
unalias glog
unalias gloga
unalias glol
unalias gunwip
### END UNALIAS GIT PLUGIN ###

### BEGIN MARKS ###
export MARKPATH=$HOME/.marks
function jump {
  cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}
function mark {
  mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}
function unmark {
  rm -i "$MARKPATH/$1"
}
function marks {
  ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/ -/g' && echo
}
function _completemarks {
  reply=($(ls $MARKPATH))
}

compctl -K _completemarks jump
compctl -K _completemarks unmark

alias jm="jump"
### END MARKS ###

### BEGIN NEOVIM MARKS ###
function nvim-jump {
    jump $1
    nvim
}

compctl -K _completemarks nvim-jump

alias njm="nvim-jump"
### END NEOVIM MARKS ###

# Use C-n and C-p to cycle through history
bindkey "^p" history-beginning-search-backward
bindkey "^n" history-beginning-search-forward

# Google Cloud SDK.
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

# Prevent brew from randomly breaking stuff...
export HOMEBREW_NO_AUTO_UPDATE=1

autoload -U compinit
compinit -i

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform
complete -o nospace -C /usr/local/bin/tofu tofu

eval "$(rbenv init - zsh)"

# Poetry auto-completion
fpath+=~/.zfunc
autoload -Uz compinit && compinit

# Disable autocorrect
unsetopt correct
unsetopt correct_all

function github_loc() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: github_loc <github-url-or-username/reponame>"
    echo "Examples:"
    echo "  github_loc octocat/Hello-World"
    echo "  github_loc https://github.com/octocat/Hello-World"
    echo "  github_loc https://github.com/octocat/Hello-World.git"
    return 1
  fi

  local input="$1"
  local repo_path

  # Parse input to extract username/reponame
  if [[ "$input" == *"github.com"* ]]; then
    # Extract from URL: capture first two path components after github.com/
    repo_path=$(echo "$input" | sed -E 's|.*github\.com/([^/]+/[^/]+)/?.*|\1|' | sed 's/\.git$//')
  else
    repo_path="$input"
  fi

  # Validate format (should be exactly username/reponame)
  if [[ ! "$repo_path" =~ ^[^/]+/[^/]+$ ]]; then
    echo "Error: Invalid repository format. Expected username/reponame"
    echo "Parsed: '$repo_path'"
    return 1
  fi

  echo "Fetching line count for: $repo_path"
  curl -s -L "https://api.codetabs.com/v1/loc?github=$repo_path" | jq
}

uuid() {
  local generated_uuid=$(python3 -c "import uuid; print(uuid.uuid4())")
  echo -n "$generated_uuid" | pbcopy
  echo "$generated_uuid copied to clipboard"
}

function run_n_parallel() {
    # Disable job control messages ([1] done...) locally for this function
    setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR

    # 1. Input Validation
    local count=$1
    local cmd=$2

    if [[ -z "$count" || -z "$cmd" ]]; then
        echo "Usage: run_n_parallel <count> <command>"
        echo "Example: run_n_parallel 5 'pytest tests/test_llm.py'"
        return 1
    fi

    if ! [[ "$count" =~ ^[0-9]+$ ]] || (( count < 1 )); then
        echo "Error: Count must be an integer >= 1"
        return 1
    fi

    # 2. Setup Infrastructure
    local tmp_dir=$(mktemp -d)
    local pids=()

    cleanup() {
        if (( ${#pids[@]} > 0 )); then
            kill "${pids[@]}" 2>/dev/null
        fi
        rm -rf "$tmp_dir"
    }
    trap cleanup EXIT INT TERM

    echo "🚀 Starting $count parallel runs of: $cmd"
    echo "----------------------------------------"

    # 3. Execution Loop (Fan-out)
    for i in {1..$count}; do
        (
            export FORCE_COLOR=1
            export CLICOLOR_FORCE=1
            export PYTHONUNBUFFERED=1

            eval "$cmd" > "${tmp_dir}/${i}.log" 2>&1
            echo $? > "${tmp_dir}/${i}.exit"
        ) &
        pids+=($!)
    done

    # 4. Monitoring Loop (Improved)
    local finished_count=0
    tput civis

    while true; do
        # Check files immediately
        local done_files=("${tmp_dir}"/*.exit(N))
        finished_count=${#done_files}

        # Update UI
        printf "\r\033[2K🤖 Progress: %d / %d completed..." "$finished_count" "$count"

        # Break if done
        (( finished_count >= count )) && break

        # Sleep AFTER checking/printing (and reduced to 1s for better responsiveness)
        sleep 1
    done

    tput cnorm
    echo -e "\n\n🎉 All runs completed. Aggregating outputs...\n"

    # 5. Output Aggregation & Summary (Fan-in)
    local global_fail=0
    local success_cnt=0
    local fail_cnt=0
    local failed_ids=()

    for i in {1..$count}; do
        local exit_code=$(cat "${tmp_dir}/${i}.exit")
        local status_icon="✅"

        if (( exit_code != 0 )); then
            status_icon="❌"
            global_fail=1
            (( fail_cnt++ ))
            failed_ids+=($i)
        else
            (( success_cnt++ ))
        fi

        echo "----------------------------------------"
        echo "$status_icon Run #$i (Exit Code: $exit_code)"
        echo "----------------------------------------"
        cat "${tmp_dir}/${i}.log"
        echo ""
    done

    # 6. Final Summary
    echo "========================================"
    echo "📊 RUN SUMMARY"
    echo "========================================"
    echo "✅ Successful: $success_cnt"
    echo "❌ Failed:     $fail_cnt"

    if (( fail_cnt > 0 )); then
        # Join array with commas
        echo "🚧 Failed IDs: ${failed_ids[*]}"
    fi
    echo ""

    return $global_fail
}

advice
# fastfetch
