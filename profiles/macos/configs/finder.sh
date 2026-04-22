#!/usr/bin/env zsh
set -euo pipefail

echo "Configuring Finder..."

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

killall Finder
