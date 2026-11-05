# -*- mode: sh -*-

# Stow and Dotfiles directories
export STOW_DIR=$HOME/.dotfiles
export DOTFILES=$STOW_DIR

# Setup Emacs Shell
export ESHELL=/bin/bash

# Language: default LANG only if unset, preferring en_US when the locale
# exists (minimal Linux boxes often only have C.UTF-8). Never force LC_ALL.
if [ -z "$LANG" ]; then
    if locale -a 2>/dev/null | grep -qiE '^en_US\.utf-?8$'; then
        export LANG='en_US.UTF-8'
    else
        export LANG='C.UTF-8'
    fi
fi

# Emacs Info Files
[ -d "$HOME/.info" ] && export INFOPATH="$HOME/.info"

# Tex Inputs
[ -d "$HOME/.tex" ] && export TEXINPUTS="$HOME/.tex//:"

# Browser
[[ "$OSTYPE" == darwin* ]] && export BROWSER='open'

# Path setup: include home bin dir and brew directories
PATH="$PATH:$HOME/bin"
for d in /opt/homebrew/sbin /usr/local/sbin /opt/homebrew/bin /opt/openssl/bin /usr/local/bin ; do
    if [[ -d $d ]] ; then
        PATH="$d:$PATH"
    fi
done
export PATH

# Less: pass ANSI colors through
export LESS="-R"

# Directory Colors
export CLICOLOR=true

if type dircolors >/dev/null 2>&1 && [ -f ~/.dircolors ]; then
    eval $(dircolors ~/.dircolors)
elif type dircolors >/dev/null 2>&1; then
    eval $(dircolors)
else
    export LS_COLORS=ExfxcxdxBxegedabagacad
fi

# Grep Colors
export GREP_COLORS='mt=37;45'                         # GNU
[[ "$OSTYPE" == darwin* ]] && export GREP_COLOR='37;45' # BSD (GNU grep warns if set)

# Editors
# export EDITOR='emacs'
# export VISUAL='emacs'
export EDITOR='emacsclient -t'
export VISUAL='emacsclient -t'
#export VISUAL='emacsclient -c -n'

export PAGER='less'

# Rust
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

# Secrets (API tokens, etc.) - stored in uncommitted .env.secrets
[ -f "$DOTFILES/main/.env.secrets" ] && source "$DOTFILES/main/.env.secrets"
[ -f "$DOTFILES/main/.env.secrets.sh" ] && source "$DOTFILES/main/.env.secrets.sh"

# Disable docker sbx telemetry
export SBX_NO_TELEMETRY=1
# Other telemetry-off flags:
export HOMEBREW_NO_ANALYTICS=1
