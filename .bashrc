# ~/.bashrc: executed by bash(1) for non-login shells

# --- PATH ---
export PATH="$HOME/.local/bin:$PATH"

# --- Interactive shell check ---
[[ $- != *i* ]] && return  # exit if not interactive

# --- History ---
HISTCONTROL=ignoreboth           # no duplicates or lines starting with space
shopt -s histappend              # append to history, don't overwrite
HISTSIZE=1000
HISTFILESIZE=2000

# --- Terminal ---
export TERM=xterm-256color
shopt -s checkwinsize             # update LINES and COLUMNS after each command

# --- Prompt setup ---
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

force_color_prompt=yes
if [ "$force_color_prompt" = yes ] && command -v tput &> /dev/null && tput setaf 1 &> /dev/null; then
    color_prompt=yes
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# --- Xterm title ---
case "$TERM" in
    xterm*|rxvt*) PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1";;
esac

# --- ls & grep color support ---
if command -v dircolors &> /dev/null; then
    [ -r ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# --- Common aliases ---
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# --- Alerts for long-running commands ---
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# --- Load user aliases ---
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# --- Bash completion ---
if ! shopt -oq posix; then
    [ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
    [ -f /etc/bash_completion ] && . /etc/bash_completion
fi

# --- FZF ---
export FZF_DEFAULT_OPTS=" \
--color=bg+:#51576D,bg:#303446,spinner:#F2D5CF,hl:#E78284 \
--color=fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF \
--color=marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284 \
--color=border:#737994,label:#C6D0F5"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# --- Node Version Manager (nvm) ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# --- Android SDK ---
export ANDROID_HOME="$HOME/Android"
export ANDROID_SDK_ROOT="$HOME/Android"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"

# --- Aliases ---
alias bat="batcat"
alias fd="fdfind"

# --- tmux auto-start ---
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen|tmux ]] && [ -z "$TMUX" ]; then
    exec tmux
fi

# --- Oh My Posh prompt ---
eval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/catppuccin.omp.json)"
. "$HOME/.cargo/env"
