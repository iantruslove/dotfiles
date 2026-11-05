# .zshrc - Sourced for interactive shells.
# Configure shell options, keybindings, aliases, plugins, prompt, history, and completions.

# set -e
# set -x

## Options section
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt interactivecomments                                      # Allow comments in interactive prompts

setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word

################################################################################
## Keybindings section
bindkey -e                                                      # Emacs-style keybindings
bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[H' beginning-of-line                                # Home key
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
fi
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[F' end-of-line                                      # End key
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
fi
bindkey '^[[2~' overwrite-mode                                  # Insert key
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^[[5~' history-beginning-search-backward               # Page up key
bindkey '^[[6~' history-beginning-search-forward                # Page down key

# Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #
bindkey "^[[1;3C" forward-word                                  # alt leftarrow
bindkey "^[[1;3D" backward-word                                 # alt rightarrow
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^[[Z' undo                                             # Shift+tab undo last action

################################################################################
# Functions and Aliases
[ -f ~/.functions ] && . ~/.functions
[ -f ~/.aliases ] && . ~/.aliases

################################################################################
# Theming section
autoload -U colors zcalc
colors

precmd() {
    print -Pn "\e]0;%n@%m %~\a"
}

# enable substitution for prompt
setopt prompt_subst

# Prompt (on left side) similar to default bash prompt, or redhat zsh prompt with colors
 #PROMPT="%(!.%{$fg[red]%}[%n@%m %1~]%{$reset_color%}# .%{$fg[green]%}[%n@%m %1~]%{$reset_color%}$ "
# Maia prompt
PROMPT="%B%{$fg[cyan]%}%(4~|%-1~/.../%2~|%~)%u%b >%{$fg[cyan]%}>%B%(?.%{$fg[cyan]%}.%{$fg[red]%})>%{$reset_color%}%b " # Print some system information when the shell is first started
# Print a greeting message when shell is started
if type lsb_release >/dev/null 2>&1; then
    echo $USER@$HOST  $(uname -srm) $(lsb_release -rcs)
else
    echo $USER@$HOST  $(uname -srm)
fi
## Prompt on right side:
#  - in a git repo: branch plus state markers (one `git status` call)
#  - otherwise: exit status of the previous command, if it failed

GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"
GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"             # A"NUM"         - ahead by "NUM" commits
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"           # B"NUM"         - behind by "NUM" commits
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"     # lightning bolt - merge conflict
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"       # red circle     - untracked files
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"     # yellow circle  - tracked files modified
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"        # green circle   - staged changes

git_prompt_string() {
  local out line head state ahead=0 behind=0 conflict=0 untracked=0 modified=0 staged=0
  if ! out=$(git status --porcelain=v2 --branch 2>/dev/null); then
    echo "%{$fg[red]%} %(?..[%?])"
    return
  fi
  for line in ${(f)out}; do
    case $line in
      ('# branch.head '*) head=${line#'# branch.head '} ;;
      ('# branch.ab '*)   line=${line#'# branch.ab +'}; ahead=${line%% *}; behind=${line##* -} ;;
      ([12]' '*)          [[ ${line[3]} != . ]] && staged=1; [[ ${line[4]} != . ]] && modified=1 ;;
      ('u '*)             conflict=1 ;;
      ('? '*)             untracked=1 ;;
    esac
  done
  if [[ $head == '(detached)' ]]; then
    head=$(git name-rev --name-only --no-undefined --always HEAD 2>/dev/null)
    head=${head#tags/}
  fi
  (( ahead ))     && state+=${GIT_PROMPT_AHEAD//NUM/$ahead}
  (( behind ))    && state+=${GIT_PROMPT_BEHIND//NUM/$behind}
  (( conflict ))  && state+=$GIT_PROMPT_MERGING
  (( untracked )) && state+=$GIT_PROMPT_UNTRACKED
  (( modified ))  && state+=$GIT_PROMPT_MODIFIED
  (( staged ))    && state+=$GIT_PROMPT_STAGED
  [[ -n $state ]] && state=$GIT_PROMPT_PREFIX$state$GIT_PROMPT_SUFFIX
  echo "$GIT_PROMPT_SYMBOL$state$GIT_PROMPT_PREFIX%{$fg[yellow]%}$head$GIT_PROMPT_SUFFIX"
}

RPROMPT='$(git_prompt_string)'


# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'

FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

################################################################################
## Plugins section
# Plugins are listed in ~/.zsh_plugins.txt and managed by antidote, which
# compiles them into a static ~/.zsh_plugins.zsh. `antidote update` updates.

# fzf key bindings (Ctrl-R, Ctrl-T, Alt-C) and completion, generated by the
# installed fzf so they always match it. fzf < 0.48 can't do that; its distro
# package ships the same scripts as files instead. Sourced before antidote so
# that, on zsh < 5.9, zsh-syntax-highlighting also wraps these widgets.
if (( $+commands[fzf] )); then
    if fzf --zsh &>/dev/null; then
        source <(fzf --zsh)
    else
        for f in /usr/share/{doc/fzf/examples,fzf}/{key-bindings,completion}.zsh(N); do source $f; done
        unset f
    fi
fi

[[ -d ~/.antidote ]] || git clone -q --depth 1 https://github.com/mattmc3/antidote.git ~/.antidote
source ~/.antidote/antidote.zsh
antidote load

# Directory jumping (`z`), if zoxide is installed
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

################################################################################
# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY_TIME  # Multiple sessions contribute to a shared history
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS


ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# SSH agent (see .functions)
ensure-ssh-agent

# # Load local plugins
# for script in ~/.zsh/**/*.zsh; do
#   source $script
# done




### The following pipenv stuff is replaced with a zsh plugin
# # Automatically use pipenvs
# function auto_pipenv_shell {
#     if [ ! -n "${PIPENV_ACTIVE+1}" ] ; then
#         if [ -f "Pipfile" ] ; then
#             if command -v pipenv &> /dev/null ; then
#                 pipenv shell
#             fi
#         fi
#     fi
# }
# function cd {
#     builtin cd "$@"
#     auto_pipenv_shell
# }

################################################################################
# Completions

# Homebrew completions (HOMEBREW_PREFIX is set in .env.sh)
[[ -n "$HOMEBREW_PREFIX" ]] && fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)

# Having loaded the zsh-completions plugin and possibly others during
# the starup sequence, reload completion backends:
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# aws-cli completions:
(( $+commands[aws_completer] )) && complete -C "$(command -v aws_completer)" aws

################################################################################
# NVM

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

################################################################################
# Machine-local config: source executable files in ~/.site (not in git)
for f in ~/.site/*(N); do
    [[ -x "$f" ]] && source "$f"
done
unset f
