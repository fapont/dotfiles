# File always sourced used to store env variable that
# need to be accesible by other programs. This file is
# source even on non interactive shell session (this is
# not the case for .zshrc)

# Add bin folders to path
export PATH="$HOME/.local/bin:$HOME/.config/scripts:$PATH" # custom scripts
export PATH="$HOME/.cargo/bin:$PATH" # rust scripts

# XDG Base Directory Specification
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="/usr/local/share/:/usr/share/"

# Config
export ZSH="$HOME/.config/oh-my-zsh" # oh-my-zsh folder
export KUBE_EDITOR="code --wait"
export SPACESHIP_CONFIG="$HOME/.config/oh-my-zsh/spaceship.zsh"
export FZF_DEFAULT_OPTS=" \ 
--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796" # Catppuccin theme to fzf

