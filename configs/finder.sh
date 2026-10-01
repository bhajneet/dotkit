#!/usr/bin/env zsh
set -euo pipefail

echo "Configuring Finder..."

# Hide file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool false

# Keep folders on top when sorting by name (windows)
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Keep folders on top on desktop
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true

# Stop creating .DS_Store files on USB drives/Network drives
# Adjust SMB browsing behavior in macOS
# https://support.apple.com/en-us/HT208209
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool TRUE
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

# Restart Finder to apply above changes
killall Finder
