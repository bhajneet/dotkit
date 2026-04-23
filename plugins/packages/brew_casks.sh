#!/bin/sh
set -eu
. "$DOTKIT_DIR/scripts/lib.sh"
data="$DOTKIT_PROFILE_DIR/packages/brew_casks.txt"
[ -f "$data" ] || exit 0

pkgs=$(parse_list "$data")

echo "Prefetching casks in parallel..."
printf '%s\n' "$pkgs" | xargs -P 4 -I {} brew fetch --cask {} 2>&1 || true

echo "Installing casks..."
failed=""
while IFS= read -r pkg; do
  brew install --cask "$pkg" || failed="$failed
  - $pkg"
done << EOF
$pkgs
EOF
[ -z "$failed" ] || printf "[packages/brew_casks] Failed:%s\n" "$failed" >> "${DOTKIT_FAILURES:-/dev/stderr}"
