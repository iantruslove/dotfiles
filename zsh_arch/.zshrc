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
#  - shows status of git when in git repository (code adapted from https://techanic.net/2012/12/30/my_git_prompt_for_zsh.html)
#  - shows exit status of previous command (if previous command finished with an error)
#  - is invisible, if neither is the case

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"                              # plus/minus     - clean repo
GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"             # A"NUM"         - ahead by "NUM" commits
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"           # B"NUM"         - behind by "NUM" commits
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"     # lightning bolt - merge conflict
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"       # red circle     - untracked files
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"     # yellow circle  - tracked files modified
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"        # green circle   - staged changes present = ready for "git push"

parse_git_branch() {
  # Show Git branch/tag, or name-rev if on detached head
  ( git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD ) 2> /dev/null
}

parse_git_state() {
  # Show different symbols as appropriate for various Git repository states
  # Compose this value via multiple conditional appends.
  local GIT_STATE=""
  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi
  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi
  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi
  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi
  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi
  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi
  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi
}

git_prompt_string() {
  local git_where="$(parse_git_branch)"

  # If inside a Git repository, print its branch and state
  [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"

  # If not inside the Git repo, print exit codes of last command (only if it failed)
  [ ! -n "$git_where" ] && echo "%{$fg[red]%} %(?..[%?])"
}

# Right prompt with exit status of previous command if not successful
 #RPROMPT="%{$fg[red]%} %(?..[%?])"
# Right prompt with exit status of previous command marked with ✓ or ✗
 #RPROMPT="%(?.%{$fg[green]%}✓ %{$reset_color%}.%{$fg[red]%}✗ %{$reset_color%})"

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-r

################################################################################
## Plugins section

[ -d ~/.zplug ] || git clone https://github.com/b4b4r07/zplug ~/.zplug
. ~/.zplug/init.zsh

# zplug "plugins/cargo", from:oh-my-zsh
zplug "plugins/fzf", from:oh-my-zsh  # Also needs `fzf` executable installed
# zplug "plugins/git", from:oh-my-zsh
# zplug "plugins/golang", from:oh-my-zsh
# zplug "b4b4r07/zsh-history"
# zplug "plugins/pyenv", from:oh-my-zsh
# zplug "plugins/rust", from:oh-my-zsh
# zplug "plugins/rustup", from:oh-my-zsh
zplug "agkozak/zsh-z"
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
# zplug "zsh-users/zsh-history-substring-search", defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY_TIME  # Multiple sessions contribute to a shared history
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# Install plugins if there are plugins that have not been installed
zplug check || zplug install

# Load Plugins
zplug load

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi


################################################################################

# Apply different settings for different terminals
# case $(basename "$(cat "/proc/$PPID/comm")") in
#   login)
#     	RPROMPT="%{$fg[red]%} %(?..[%?])"
#     	alias x='startx ~/.xinitrc'      # Type name of desired desktop after x, xinitrc is configured for it
#     ;;
# #  'tmux: server')
# #        RPROMPT='$(git_prompt_string)'
# #		## Base16 Shell color themes.
# #		#possible themes: 3024, apathy, ashes, atelierdune, atelierforest, atelierhearth,
# #		#atelierseaside, bespin, brewer, chalk, codeschool, colors, default, eighties,
# #		#embers, flat, google, grayscale, greenscreen, harmonic16, isotope, londontube,
# #		#marrakesh, mocha, monokai, ocean, paraiso, pop (dark only), railscasts, shapesifter,
# #		#solarized, summerfruit, tomorrow, twilight
# #		#theme="eighties"
# #		#Possible variants: dark and light
# #		#shade="dark"
# #		#BASE16_SHELL="/usr/share/zsh/scripts/base16-shell/base16-$theme.$shade.sh"
# #		#[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
# #		# Use autosuggestion
# #		source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# #		ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
# #  		ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
# #     ;;
#   *)
#         RPROMPT='$(git_prompt_string)'
# 		# Use autosuggestion
# #		source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# 		ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
#   		ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
#     ;;
# esac

RPROMPT='$(git_prompt_string)'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

source ~/.env

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
#if [[ ! "$SSH_AUTH_SOCK" ]]; then
#    fix-agent
#fi

# Load local plugins
for script in ~/.zsh/**/*.zsh; do
  source $script
done

for f in ~/.site/*; do
    if [[ -x "$f" ]] ; then
        source $f;
    fi
done

# Automatically use pipenvs
function auto_pipenv_shell {
    if [ ! -n "${PIPENV_ACTIVE+1}" ] ; then
        if [ -f "Pipfile" ] ; then
            if command -v pipenv &> /dev/null ; then
                pipenv shell
            fi
        fi
    fi
}
function cd {
    builtin cd "$@"
    auto_pipenv_shell
}


# Having loaded the zsh-completions plugin and possibly others during
# the starup sequence, reload completion backends:
autoload -U compinit
compinit -d
