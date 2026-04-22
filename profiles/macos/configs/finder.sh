#!/usr/bin/env zsh
set -euo pipefail

echo "Applying Finder settings..."

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
