#!/bin/sh
set -eu
. "$DOTKIT_DIR/scripts/lib.sh"
data="$DOTKIT_PROFILE_DIR/packages/mas.txt"
[ -f "$data" ] || exit 0
printf "Sign in to the Mac App Store before continuing (required for MAS installs).\nPress Enter when ready..."; read -r _
failed=""
while IFS= read -r line; do
  id="${line%% *}"
  mas install "$id" || failed="$failed
  - $line"
done << EOF
$(parse_list "$data")
EOF
mas upgrade
[ -z "$failed" ] || printf "[packages/mas] Failed:%s\n" "$failed" >> "${DOTKIT_FAILURES:-/dev/stderr}"
