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

plugins=(
  git
  zsh-syntax-highlighting
  # zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

export ENABLE_CORRECTION="true"

alias vi="nvim"
alias vim="nvim"

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

alias pod='podman'

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

# Print great advice
advice

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
