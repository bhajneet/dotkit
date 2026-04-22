#!/usr/bin/env zsh
set -euo pipefail

echo "Applying screenshot settings..."

# Save to clipboard, no window shadow, no floating thumbnail
defaults write com.apple.screencapture target clipboard
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture show-thumbnail -bool false
