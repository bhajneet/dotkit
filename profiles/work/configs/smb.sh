#!/usr/bin/env zsh
set -euo pipefail

echo "Configuring SMB..."

# Adjust SMB browsing behavior in macOS
# https://support.apple.com/en-us/HT208209
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

killall Finder
