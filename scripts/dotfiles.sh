#!/bin/sh
# Link dotfiles from a directory to ~/
# Usage: dotfiles.sh <dotfiles-dir>
set -eu

DOTFILES_DIR="${1:?Usage: dotfiles.sh <dotfiles-dir>}"
DOTFILES_DIR="$(cd "$DOTFILES_DIR" && pwd)"

find "$DOTFILES_DIR" -type f | while IFS= read -r src; do
  rel="${src#$DOTFILES_DIR/}"
  dest="$HOME/$rel"

  mkdir -p "$(dirname "$dest")"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    bak="$dest.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$bak"
    echo "Backed up ~/$rel → $bak"
    if command -v diff >/dev/null 2>&1; then
      echo "changes..."
      diff "$bak" "$src" || true
      echo ""
    fi
  fi

  ln -sf "$src" "$dest"
  echo "Linked ~/$rel → $src"
done
