# .zshenv - Sourced for ALL shells (login, interactive, and scripts).
# Keep this minimal and fast. Set essential environment variables here.

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# uv
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# yarn
[[ -d "$HOME/.yarn/bin" ]] && export PATH="$PATH:$HOME/.yarn/bin"

# libpq (psql, pg_dump, etc.)
[[ -d "/opt/homebrew/opt/libpq/bin" ]] && export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
