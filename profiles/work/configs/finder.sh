#!/usr/bin/env zsh
set -euo pipefail

echo "Configuring Finder..."

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Keep folders on top when sorting by name (windows)
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Keep folders on top on desktop
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true

killall Finder
