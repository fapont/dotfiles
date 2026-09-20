#!/bin/sh
set -eu

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
REPO_URL="https://github.com/fapont/dotfiles.git"

if ! command -v mise >/dev/null 2>&1; then
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$DOTFILES_DIR/.git" ]; then
  git -C "$DOTFILES_DIR" pull --ff-only
elif [ -e "$DOTFILES_DIR" ]; then
  echo "error: $DOTFILES_DIR exists and isn't a git checkout" >&2
  exit 1
else
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
mise bootstrap --yes
