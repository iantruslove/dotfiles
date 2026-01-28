#!/usr/bin/env zsh

export NVM_DIR="$HOME/.nvm"
_nvm_dir=$NVM_DIR

# Homebrew is changing where it places binaries. This handles brew installations:
[[ -d "/usr/local/opt/nvm/" ]] && _nvm_dir=/usr/local/opt/nvm
[[ -d "/opt/homebrew/opt/nvm/" ]] && _nvm_dir=/opt/homebrew/opt/nvm

[ -s "$_nvm_dir/nvm.sh" ] && . "$_nvm_dir/nvm.sh"  # This loads nvm
[ -s "$_nvm_dir/etc/bash_completion.d/nvm" ] && . "$_nvm_dir/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
