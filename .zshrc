export ZSH=/home/alexey/.oh-my-zsh
export LANG=en_US.UTF-8
export EDITOR="vim"
export ZSH_THEME="agnoster"
export GOPATH=/media/alexey/Dev/Workspace/golang/
export ANDROID_HVPROTO=ddm
export JAVA_HOME="/opt/java/jdk1.8.0_74/"

plugins=(git)

source $ZSH/oh-my-zsh.sh

ENABLE_CORRECTION="true"

PATH=$PATH:/media/alexey/Dev/Android/sdk/platform-tools/
PATH=$PATH:/media/alexey/Dev/lib/phantomjs-2.1.1-linux-x86_64/bin
PATH=$PATH:/home/alexey/.virtualenvs
PATH=$PATH:/media/alexey/Dev/Workspace/kakava
PATH=$PATH:/media/alexey/Dev/appengine-sdk/
PATH=$PATH:/usr/local/go/bin
PATH=$PATH:/media/alexey/Dev/Workspace/Tools

alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias reload="source ~/.zshrc"
alias homm="cd /home/alexey/.wine/drive_c/Games/Heroes\ of\ Might\ and\ Magic\ III; ./run-homm.sh"
alias upd="sudo apt-get update; sudo apt-get upgrade -y; sudo apt-get autoclean; sudo apt-get autoremove"
alias advice="advice | cowsay"
alias ta="tmux attach || tmux new"
alias python="python3"
alias pip="pip3"
alias autopep8="/home/alexey/.local/lib/python3.5/site-packages/autopep8.py"
alias :q="exit"

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

# Run tmux if not running
if ! { [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; } then
    ta
    exit
fi

# Move terminal to 3rd workspace after startup
a=$(uptime -p | cut -d ' ' -f 2)
if [ $a -lt 3 ]; then
    xdotool search --class gnome-terminal set_desktop_for_window %@ 2
fi
unset a
