# .bashrc

# Source main environment
. ~/.env

# If not running interactively, return
[ -z "$PS1" ] && return

# need the host name set sometimes
[ -z "$HOSTNAME" ] && export HOSTNAME=$(hostname)

# Functions / Aliases
[ -f ~/.functions ] && . ~/.functions
[ -f ~/.aliases ] && . ~/.aliases

shopt -s expand_aliases

# no duplicates in history
export HISTIGNORE="ls:ll:pwd:gs:gl:pwd:history:clear"
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT="%F %T "
# append instead of overwrite history file
shopt -s histappend
# save multiline commands in same history entry
shopt -s cmdhist

# Check window size after commands
shopt -s checkwinsize

# Let Ctrl-O work ing terminals
if [ -f /Applications ]; then
  stty discard undef
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

if [ -f /etc/bash.bashrc ]; then
  . /etc/bash.bashrc
fi

# auto correct spelling
shopt -s cdspell

# Prompt

function git_prompt() {
  branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  if [[ $? == 0 ]]; then
    printf "(%.10s%s) " "$branch" "$([[ -n $(git status -s) ]] && echo " ✗")"
  fi
}

function status_symbol() {
  if [[ $1 != 0 ]]; then
    echo -n "⚡ $1 ⚡ "
  fi
}

function right_prompt() {
  local str="$(date +'%a %H:%M:%S')"

  if [[ "$SSH_TTY" ]]; then
    str="$(id -u -n)@$(hostname -s) $str"
  fi

  tput sc
  printf "%*s" $COLUMNS "$str"
  tput rc
}

function ppwd() {
  [[ $COLUMNS -lt 60 ]] && return

  local path="$PWD"
  local path_depth=$(grep -o "/" <<< "$path" | wc -l)
  local cols=$((($COLUMNS * 2 / 5) - 10))

  for (( i=1; i<=$path_depth; i++))
  do
    if [[ ${#path} -gt $cols ]]; then
      path="$(echo "$path" | sed -e "s;\(/.\)[^/][^/]*;\1;")"
    fi
  done

  if [[ ${#path} -gt $cols ]]; then
    path="«${path:0-$cols}"
  fi

  echo "$path "
}

function root_check() {
  if [[ "$(id -u)" == 0 ]]; then
    echo "[ROOT] "
  fi
}

function __prompt {
    # solarized colors
    local BASE03="\[$(tput setaf 8)\]"
    local BASE02="\[$(tput setaf 0)\]"
    local BASE01="\[$(tput setaf 10)\]"
    local BASE00="\[$(tput setaf 11)\]"
    local BASE0="\[$(tput setaf 12)\]"
    local BASE1="\[$(tput setaf 14)\]"
    local BASE2="\[$(tput setaf 7)\]"
    local BASE3="\[$(tput setaf 15)\]"
    local YELLOW="\[$(tput setaf 3)\]"
    local ORANGE="\[$(tput setaf 9)\]"
    local RED="\[$(tput setaf 1)\]"
    local MAGENTA="\[$(tput setaf 5)\]"
    local VIOLET="\[$(tput setaf 13)\]"
    local BLUE="\[$(tput setaf 4)\]"
    local CYAN="\[$(tput setaf 6)\]"
    local GREEN="\[$(tput setaf 2)\]"
    local RESET="\[$(tput sgr0)\]"

    PS1="$BASE0\$(LS=\$?; right_prompt; exit \$LS)"
    PS1+="$RED\$(status_symbol \$?)$RESET\n"
    PS1+="$BASE1\$(ppwd)$GREEN\$(git_prompt)"
    PS1+="$ORANGE\$(root_check)"
    PS1+="$BASE01\\$ $RESET"

    export PS1
}

#export PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
export PROMPT_COMMAND=__prompt

# Keychains and SSH agents:
#if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    if [[ -x $(which keychain) ]]; then
        # Keychain is wicked smaht, but not necessarily installed
        eval `keychain --eval --agents ssh 2>/dev/null`
    else
        eval `ssh-agent` > /dev/null
    fi
#fi

# Fix ssh-agent
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    fix-agent
fi

for f in ~/.site/*; do
    if [[ -x "$f" ]] ; then
        source $f;
    fi
done

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
