# -> ~/.zprofile. macOS: brew packages from the modules are poured by
# mise's own brew/brew-cask backend into /opt/homebrew, without a real `brew`
# (no `brew shellenv` to eval), so just put the prefix on PATH. No-op on Linux,
# where Arch's /etc/zsh/zprofile already sources /etc/profile (Omarchy's PATH).
[ -d /opt/homebrew ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# mise 2026.10.20+ no longer puts a vfox plugin's lib/ on the Lua path, so the
# gcloud plugin's `require("python")` fails on every prompt. Read before
# `mise activate` (.zshrc). Remove once mise fixes it.
gcloud_lua="$HOME/.local/share/mise/plugins/vfox-mise-plugins-vfox-gcloud/lib"
[ -d "$gcloud_lua" ] && export LUA_PATH="$gcloud_lua/?.lua;;"
unset gcloud_lua
