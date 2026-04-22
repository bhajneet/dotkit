#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
DOTKIT_DIR="${SCRIPT_DIR:h:h}"
CONFIG="$SCRIPT_DIR/packages"

. "$DOTKIT_DIR/scripts/lib.sh"

# Dotfiles

echo "Linking dotfiles..."
sh "$DOTKIT_DIR/scripts/dotfiles.sh" "$SCRIPT_DIR/dotfiles"

# Homebrew

test -f /opt/homebrew/bin/brew || \
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update
parse_list "$CONFIG/brew_formulae.txt" | xargs brew install
parse_list "$CONFIG/brew_casks.txt"    | xargs brew install --cask

# Mac App Store

echo "Sign in to the Mac App Store before continuing (required for MAS installs)."
read "?Press Enter when ready..."

parse_list "$CONFIG/mas_apps.txt" | cut -d' ' -f1 | xargs mas install
mas upgrade

# Configs

for f in "$SCRIPT_DIR/configs/"*.sh; do zsh "$f"; done

# Node (fnm)

echo "Installing current Node version..."
eval "$(fnm env)"
fnm install current
fnm default current

# Manual installs reminder

if parse_list "$CONFIG/manual_installs.txt" | grep -q .; then
  echo ""
  echo "Manual installs required..."
  parse_list "$CONFIG/manual_installs.txt" | while IFS=' = ' read -r name info; do
    printf "• %s  %s\n" "$name" "$info"
  done
  echo ""
fi
