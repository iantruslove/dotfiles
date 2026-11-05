# .bashrc

# Source main environment
[ -f ~/.env.sh ] && . ~/.env.sh

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

# Let Ctrl-O work in macOS terminals
if [[ "$OSTYPE" == darwin* ]]; then
  stty discard undef
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# auto correct spelling
shopt -s cdspell

# Prompt: [user@host (over ssh)] path (git branch) [exit status if failed] $
__git_branch() {
  local b
  b=$(git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return
  printf ' (%s)' "$b"
}

__prompt() {
  local status=$?
  # $(__git_branch) stays unexpanded here so branch names are never evaluated
  PS1='${SSH_TTY:+\u@\h }\[\e[36m\]\w\[\e[0m\]\[\e[32m\]$(__git_branch)\[\e[0m\]'
  (( status )) && PS1+=" \[\e[31m\][$status]\[\e[0m\]"
  PS1+=' \$ '
}
PROMPT_COMMAND=__prompt

# SSH agent (see .functions)
ensure-ssh-agent

for f in ~/.site/*; do
    if [[ -x "$f" ]] ; then
        source $f;
    fi
done

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
