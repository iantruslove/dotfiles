# .zprofile - Sourced for login shells, before .zshrc.
# Configure login-session environment: source env files, set PATH, deduplicate paths.

# Source main environment file
source ~/.env

# Paths
# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path
