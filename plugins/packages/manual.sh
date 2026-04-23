#!/bin/sh
set -eu
. "$DOTKIT_DIR/scripts/lib.sh"
data="$DOTKIT_PROFILE_DIR/packages/manual.txt"
[ -f "$data" ] || exit 0
parse_list "$data" | grep -q . || exit 0
echo ""
echo "Manual installs required..."
parse_list "$data" | while IFS= read -r line; do
  name="${line% = *}"
  info="${line#* = }"
  printf "  • %s  %s\n" "$name" "$info"
done
echo ""
