#!/bin/sh
set -eu
. "$DOTKIT_DIR/scripts/lib.sh"
data="$DOTKIT_PROFILE_DIR/extras/git.txt"
[ -f "$data" ] || exit 0
echo "Configuring git..."
while IFS= read -r line; do
  key="${line% = *}"
  value="${line#* = }"
  git config --global "$key" "$value" || \
    printf "[extras/git] Failed to set: %s\n" "$line" >> "${DOTKIT_FAILURES:-/dev/stderr}"
done << EOF
$(parse_list "$data")
EOF
