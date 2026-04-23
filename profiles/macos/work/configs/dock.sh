#!/usr/bin/env zsh
set -euo pipefail

echo "Configuring Dock..."

# Auto-hide, default tile size, lock tile size
defaults write com.apple.dock autohide -bool true
defaults delete com.apple.dock "tilesize" 2>/dev/null || true
defaults write com.apple.dock size-immutable -bool yes

dockutil --remove all --no-restart
# Finder stays at position 1 (macOS always keeps it)
dockutil --add /System/Applications/Launchpad.app                    --no-restart
dockutil --add "/System/Applications/Mission Control.app"            --no-restart
dockutil --add /Applications/Safari.app                              --no-restart
dockutil --add "/Applications/Google Chrome.app"                     --no-restart
dockutil --add /System/Applications/Mail.app                         --no-restart
dockutil --add /System/Applications/Calendar.app                     --no-restart
dockutil --add /System/Applications/Notes.app                        --no-restart
dockutil --add /System/Applications/Photos.app                       --no-restart
dockutil --add /System/Applications/Messages.app                     --no-restart
dockutil --add /Applications/WhatsApp.app                            --no-restart
# YouTube Music: manual install required first (Safari PWA)
# dockutil --add "/Applications/YouTube Music.app"                   --no-restart
dockutil --add /Applications/Amperfy.app                             --no-restart
dockutil --add "/System/Applications/Clock.app"                      --no-restart
dockutil --add "/System/Applications/Utilities/Terminal.app"         --no-restart
dockutil --add /Applications/Warp.app                                --no-restart
dockutil --add "/Applications/Glyphs 3.app"                         --no-restart

killall Dock
