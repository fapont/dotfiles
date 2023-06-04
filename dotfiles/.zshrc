#### Zsh configuration ####

# Enable starship https://starship.rs/
eval "$(starship init zsh)"

# Plugins
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
plugins=(git npm yarn colored-man-pages colorize command-not-found common-aliases docker docker-compose kubectl zsh-autosuggestions history zsh-syntax-highlighting emoji pip)
source $ZSH/oh-my-zsh.sh

#### Load custom aliases, env variables and functions ####

# Load environment variables
if [ -f $HOME/.variables ]; then
    source $HOME/.variables
else
    print "404: .variables not found."
fi

if [ -f $HOME/.aliases ]; then
    source $HOME/.aliases
else
    print "404: .aliases not found."
fi

# Load functions
if [ -f $HOME/.functions ]; then
    source $HOME/.functions
else
    print "404: .functions not found."
fi