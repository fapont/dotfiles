# wt-clone <git-url> [dest-dir]
#
# git clone --bare <url> <dest-dir>/.git, cd into <dest-dir>, then create the
# first worktree on whatever branch the remote's HEAD points at (main,
# master, or anything else). dest-dir defaults to the repo's own name, so
# it clones into ./<repo>/.git.
wt-clone() {
  emulate -L zsh
  if [[ $# -lt 1 ]]; then
    echo "usage: wt-clone <git-url> [dest-dir]" >&2
    return 1
  fi

  local url="$1"
  local dest="${2:-${${url:t}%.git}}"
  git clone --bare -- "$url" "$dest/.git" || return 1
  cd -- "$dest" || return 1
  wt switch "$(wt config state default-branch)"
}
