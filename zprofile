# Packages declared in [bootstrap.packages] (mise.toml) are installed by mise's
# own brew/brew-cask backend, which pours into the canonical /opt/homebrew
# prefix without needing a real `brew` binary. No `brew shellenv` to eval here
# -- just make sure the prefix is on PATH.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
