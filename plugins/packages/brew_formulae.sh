#!/bin/sh
set -eu
. "$DOTKIT_DIR/scripts/lib.sh"
data="$DOTKIT_PROFILE_DIR/packages/brew_formulae.txt"
[ -f "$data" ] || exit 0
failed=""
while IFS= read -r pkg; do
  brew install "$pkg" || failed="$failed
  - $pkg"
done << EOF
$(parse_list "$data")
EOF
[ -z "$failed" ] || printf "[packages/brew_formulae] Failed:%s\n" "$failed" >> "${DOTKIT_FAILURES:-/dev/stderr}"
