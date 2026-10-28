# herdr-perso [herdr args]
#
# The "perso" herdr session: local panes plus the Omarchy laptop, while plain
# `herdr` stays Mac-only. Saved SSH machines live in the client's state dir
# ($XDG_STATE_HOME/herdr/client), not per session, so this client gets its own.
# The server is started first with the normal env: it would otherwise inherit
# the override and hand it to every pane (mise state, trust, history...).
herdr-perso() {
  emulate -L zsh
  local running='^status: running'
  if ! herdr --session perso status server 2>/dev/null | grep -q "$running"; then
    nohup herdr --session perso server >/dev/null 2>&1 &!
    local i
    for i in {1..50}; do
      herdr --session perso status server 2>/dev/null | grep -q "$running" && break
      sleep 0.1
    done
  fi
  XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}/herdr-perso" herdr --session perso "$@"
}
