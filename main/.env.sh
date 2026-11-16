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

# Homebrew (Apple Silicon, Intel, or Linuxbrew)
for p in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
    if [ -x "$p/bin/brew" ]; then
        export HOMEBREW_PREFIX=$p
        break
    fi
done
unset p

# PATH: all additions live here so bash and zsh agree. path_prepend skips
# missing directories and moves ones already on PATH to the front (macOS's
# path_helper has already put them behind /usr/bin), so re-sourcing is
# harmless. Later entries end up earlier in PATH.
path_prepend() {
    [ -d "$1" ] || return 0
    PATH=":$PATH:"
    PATH="${PATH//:$1:/:}"
    PATH="$1${PATH%:}"
}
if [[ "$OSTYPE" == darwin* ]]; then
    PNPM_HOME="$HOME/Library/pnpm"
else
    PNPM_HOME="$HOME/.local/share/pnpm"
fi
[ -d "$PNPM_HOME" ] && export PNPM_HOME || unset PNPM_HOME

path_prepend /usr/local/sbin
path_prepend /usr/local/bin
if [ -n "$HOMEBREW_PREFIX" ]; then
    path_prepend "$HOMEBREW_PREFIX/sbin"
    path_prepend "$HOMEBREW_PREFIX/bin"
    path_prepend "$HOMEBREW_PREFIX/opt/libpq/bin"   # psql, pg_dump
fi
path_prepend "$HOME/.yarn/bin"
path_prepend "$HOME/.cargo/bin"
[ -n "$PNPM_HOME" ] && path_prepend "$PNPM_HOME"
path_prepend "$HOME/.opencode/bin"
path_prepend "$HOME/.local/bin"                     # uv, pipx, etc.
path_prepend "$HOME/.docker/bin"                     # uv, pipx, etc.
path_prepend "$HOME/bin"
export PATH

# Less: pass ANSI colors through
export LESS="-R"

# Directory Colors
# GNU ls and zsh completion use LS_COLORS (from dircolors; Homebrew's
# coreutils calls it gdircolors). BSD ls on macOS uses CLICOLOR/LSCOLORS.
export CLICOLOR=true
export LSCOLORS=ExfxcxdxBxegedabagacad
for dc in dircolors gdircolors; do
    if command -v $dc >/dev/null 2>&1; then
        if [ -f ~/.dircolors ]; then
            eval "$($dc -b ~/.dircolors)"
        else
            eval "$($dc -b)"
        fi
        break
    fi
done
unset dc

# Grep Colors
export GREP_COLORS='mt=37;45'                         # GNU
[[ "$OSTYPE" == darwin* ]] && export GREP_COLOR='37;45' # BSD (GNU grep warns if set)

# Editors
export EDITOR='emacsclient -t'
export VISUAL='emacsclient -t'

export PAGER='less'

# Secrets (API tokens, etc.) - stored in uncommitted .env.secrets
[ -f "$DOTFILES/main/.env.secrets" ] && source "$DOTFILES/main/.env.secrets"
[ -f "$DOTFILES/main/.env.secrets.sh" ] && source "$DOTFILES/main/.env.secrets.sh"

# Disable docker sbx telemetry
export SBX_NO_TELEMETRY=1
# Other telemetry-off flags:
export HOMEBREW_NO_ANALYTICS=1
