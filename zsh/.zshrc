# ZPlug Setup
# https://github.com/b4b4r07/zplug
[ -d ~/.zplug ] || git clone https://github.com/b4b4r07/zplug ~/.zplug
. ~/.zplug/init.zsh

# Emacs Keybindings
bindkey -e

# Bash style word jumping
autoload -U select-word-style
select-word-style bash

# Environment
zplug "sorin-ionescu/prezto", use:"modules/environment/init.zsh"

# History
zplug "sorin-ionescu/prezto", use:"modules/history/init.zsh"

# Directory
zplug "sorin-ionescu/prezto", use:"modules/directory/init.zsh"

# Completion
if (( $+commands[brew] )); then
	fpath=("`brew --prefix`/share/zsh/site-functions" $fpath)
fi

zplug "plugins/kubectl", from:oh-my-zsh
zplug "sorin-ionescu/prezto", use:"modules/completion/init.zsh"
zplug "tmuxinator/tmuxinator", use:"completion/tmuxinator.zsh"

# Dircolors
(( $+commands[gdircolors] )) && eval $(gdircolors ~/.dircolors)

# Lesspipe
(( $+commands[lesspipe.sh] )) && eval $(lesspipe.sh)

# Highlighting
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Install plugins if there are plugins that have not been installed
zplug check || zplug install

# Load Plugins
zplug load

# Functions and Aliases
[ -f ~/.functions ] && . ~/.functions
[ -f ~/.aliases ] && . ~/.aliases

# Load my local plugins
for script in ~/.zsh/**/*.zsh; do
  . $script
done

# Load Blizzard plugins
if [ -d ~/blizzard/src/configs ]; then
  for script in ~/blizzard/src/configs/**/*.zsh; do
    . $script
  done
fi

# added by travis gem
[ -f /Users/cgiroir/.travis/travis.sh ] && source /Users/cgiroir/.travis/travis.sh

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /Users/cgiroir/.nodenv/versions/8.11.2/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /Users/cgiroir/.nodenv/versions/8.11.2/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /Users/cgiroir/.nodenv/versions/8.11.2/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /Users/cgiroir/.nodenv/versions/8.11.2/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh