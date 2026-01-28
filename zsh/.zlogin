# .zlogin - Sourced for login shells, after .zshrc.
# Run commands that should execute once per login session (greetings, etc.).

if (( $+commands[figlet] && $+commands[lolcat] )); then
  figlet $USER | lolcat
fi
