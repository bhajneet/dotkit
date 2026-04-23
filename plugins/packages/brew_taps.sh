#!/bin/sh
set -eu
. "$DOTKIT_DIR/scripts/lib.sh"
data="$DOTKIT_PROFILE_DIR/packages/brew_taps.txt"
[ -f "$data" ] || exit 0

taps=$(parse_list "$data")

while IFS= read -r tap; do
  brew tap "$tap" >/dev/null 2>&1 || true
done << EOF
$taps
EOF
