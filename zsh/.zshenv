# .zshenv - Sourced for ALL shells (login, interactive, and scripts).
# Keep this minimal and fast. Environment (incl. PATH) lives in ~/.env.sh.

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi
