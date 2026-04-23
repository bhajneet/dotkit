#!/bin/sh
set -eu
. "$DOTKIT_DIR/scripts/lib.sh"
data="$DOTKIT_PROFILE_DIR/packages/flatpaks.txt"
[ -f "$data" ] || exit 0
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
failed=""
while IFS= read -r line; do
  id="${line%% *}"
  flatpak install -y flathub "$id" || failed="$failed
  - $line"
done << EOF
$(parse_list "$data")
EOF
flatpak update -y
[ -z "$failed" ] || printf "[packages/flatpaks] Failed:%s\n" "$failed" >> "${DOTKIT_FAILURES:-/dev/stderr}"
