#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTKIT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG="$SCRIPT_DIR/packages"

. "$DOTKIT_DIR/scripts/lib.sh"

# Flathub

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Flatpaks

parse_list "$CONFIG/flatpaks.txt" | cut -d' ' -f1 | xargs flatpak install -y flathub
flatpak update -y
