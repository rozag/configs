export ZSH=/home/alexey/.oh-my-zsh
export LANG=en_US.UTF-8
export EDITOR="vim"
export ZSH_THEME="agnoster"
export ANDROID_HVPROTO=ddm
export DATA=/mnt/095CBE2700CF3D5F
export DEV=/mnt/33c3c684-3741-437e-92a2-e4d7432df7aa
# export JAVA_HOME="/opt/java/jdk1.8.0_74/" TODO

plugins=(git)

source $ZSH/oh-my-zsh.sh

export ENABLE_CORRECTION="true"

export PATH=$PATH:$DEV/lib/android-sdk/platform-tools
export PATH=$PATH:$DEV/workspace/kakava

alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias advice="advice | cowsay"
alias :q="exit"
alias gmnf="git merge --no-ff"

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

# Pull database from device
function pulldevdb {
   adb exec-out run-as $1 cat databases/$2 > $2
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
    ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}
function _completemarks {
  reply=($(ls $MARKPATH))
}

compctl -K _completemarks jump
compctl -K _completemarks unmark

alias jm="jump"
### END MARKS ###

# Print great advice
advice
