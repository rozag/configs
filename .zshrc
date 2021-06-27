export ME=/Users/rozag
export ZSH=$ME/.oh-my-zsh
export LANG=en_US.UTF-8
export EDITOR="vim"
export ZSH_THEME="gnzh"

export ANDROID_HOME=$ME/Library/Android/sdk

export PATH=$PATH:$ME/anaconda3/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/sdk/tools

# Go related stuff
export GOPATH=$HOME/workspace/go
export PATH=$PATH:$(go env GOPATH)/bin

export PATH="/usr/local/bin:$PATH"

# Scripts
export PATH="$ME/configs/script:$PATH"

# PostgreSQL - Postgress.app
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

# Git without XCode
export PATH="/usr/local/Cellar/git/2.20.1/bin:$PATH"

# scrcpy - stream android device screen
export PATH="/usr/local/Cellar/scrcpy/1.8/bin:$PATH"

# libxml2
export PATH="/usr/local/opt/libxml2/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/opt/libxml2/lib/pkgconfig"

# Gradle completion
fpath=($HOME/.zsh/gradle-completion $fpath)

# Android Device Monitor stuff
export ANDROID_HVPROTO=ddm

# gcloud SDK
export CLOUDSDK_PYTHON=/usr/local/Cellar/python@3.8/3.8.10/bin/python3.8

plugins=(git)

source $ZSH/oh-my-zsh.sh

export ENABLE_CORRECTION="true"

alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias advice="advice | cowsay"
alias :q="exit"
alias tarcd='tar -czf "../${PWD##*/}.tar.gz" .'
alias wtr='curl wttr.in/moscow'
alias kakava='python3 $ME/workspace/kakava/kakava'
alias v='vim'
alias wuzz='"$GOPATH/bin/wuzz"'
alias gmnf="git merge --no-ff"
alias gd="git icdiff"
alias gdf="git diff-tree --no-commit-id --name-only -r"
alias gcob="git checkout -b"
alias glb="git shortlog -sn"
alias ls="/usr/local/opt/coreutils/bin/gls --color -hF --group-directories-first"
alias ll="ls -l"
alias lla="ll -a"

# ctags macOS fix
alias ctags="`brew --prefix`/bin/ctags"

# Android development bash aliases (https://medium.com/@jonfhancock/bash-your-way-to-better-android-development-1169bc3e0424#.ezlrvqk5w)
alias startintent="adb devices | tail -n +2 | cut -sf 1 | xargs -I X adb -s X shell am start $1"
alias apkinstall="adb devices | tail -n +2 | cut -sf 1 | xargs -I X adb -s X install -r $1"
alias rmapp="adb devices | tail -n +2 | cut -sf 1 | xargs -I X adb -s X uninstall $1"
alias clearapp="adb devices | tail -n +2 | cut -sf 1 | xargs -I X adb -s X shell pm clear $1"
alias wifiadb='adb start-server && \
    sleep 3 && \
    adb tcpip 5555 && \
    sleep 3 && \
    adb shell ip -f inet addr show wlan0 | \
    tail -n +2 | \
    head -n 1 | \
    cut -d '/' -f 1 | \
    xargs -n1 | \
    tail -n +2 | \
    awk '"'"'{print "connect", $1":5555"}'"'"' | \
    xargs adb && \
    adb devices'
alias devs="adb devices"
alias w='./gradlew --daemon'
alias wo='w --offline'

# Android reverse engineering aliases
export AHACK=$ME/Library/Android/hack
export ANDROID_HOME=$ME/Library/Android/sdk

alias apktool='java -jar $AHACK/apktool_2.4.0.jar'
alias jadx-gui='$AHACK/jadx-0.6.1/bin/jadx-gui'
alias baksmali='java -jar $AHACK/baksmali-2.1.3.jar'
alias sign='java -jar $AHACK/sign.jar'
alias droidc='javac -classpath $ANDROID_HOME/platforms/android-25/android.jar'
alias dx='$ANDROID_HOME/build-tools/25.0.2/dx'
alias dex2jar='$AHACK/dex2jar-2.0/d2j-dex2jar.sh'
alias backdoor-apk='$AHACK/backdoor-apk/backdoor-apk.sh'

alias checkstyle='java -jar ~/Library/Android/checkstyle-8.42-all.jar'

# Emacs
alias emacs='/Applications/Emacs.app/Contents/MacOS/Emacs -nw'

# ki (https://blog.jetbrains.com/kotlin/2021/04/ki-the-next-interactive-shell-for-kotlin/)
alias ki='/usr/local/bin/ki/bin/ki.sh'

# Pull database from device
function pulldevdb {
    adb exec-out run-as $1 cat databases/$2 > $2
}

# Record and pull video from device
function adb-record-vid {
    adb shell screenrecord /sdcard/$1.mp4
}
function adb-pull-vid {
    adb pull /sdcard/$1.mp4 && adb shell rm /sdcard/$1.mp4
}

# Record and pull video aliases
alias recvid='rm video.mp4 video.mp4.zip; adb-record-vid video'
alias pullvid='adb-pull-vid video && zip video.mp4.zip video.mp4'

# Capture and pull a screenshot from a device
function adbscrn {
    __scrnname=device-scrn-$(date +'%Y-%m-%d-%H-%M-%S').png
    __scrnpath=/sdcard/$__scrnname
    adb shell screencap -p $__scrnpath
    adb pull $__scrnpath
    adb shell rm $__scrnpath
    mv $__scrnname $ME/Pictures/device-screenshots/
}

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

# Use C-n and C-p to cycle through history
bindkey "^p" history-beginning-search-backward
bindkey "^n" history-beginning-search-forward

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$ME/Library/google-cloud-sdk/path.zsh.inc" ]; then . "$ME/Library/google-cloud-sdk/path.zsh.inc"; fi
# The next line enables shell command completion for gcloud.
if [ -f "$ME/Library/google-cloud-sdk/completion.zsh.inc" ]; then . "$ME/Library/google-cloud-sdk/completion.zsh.inc"; fi

# Print great advice
advice

