#!/bin/sh
set -eu
. "$DOTKIT_DIR/scripts/lib.sh"
data="$DOTKIT_PROFILE_DIR/packages/brew_casks.txt"
[ -f "$data" ] || exit 0

pkgs=$(parse_list "$data")

# Filter to only packages not already installed
to_install=""
while IFS= read -r pkg; do
  brew list --cask "$pkg" >/dev/null 2>&1 || to_install="$to_install $pkg"
done << EOF
$pkgs
EOF
to_install="${to_install# }"
[ -n "$to_install" ] || exit 0

echo "Prefetching casks in parallel..."
printf '%s\n' $to_install | xargs -P 4 -I {} brew fetch --cask {} 2>&1 || true

echo "Installing casks..."
printf '%s\n' $to_install | xargs brew install --cask || true

# Detect failures (brew install on already-installed cask exits 0 immediately)
failed=""
for pkg in $to_install; do
  brew install --cask "$pkg" 2>/dev/null || failed="$failed
  - $pkg"
done
[ -z "$failed" ] || printf "[packages/brew_casks] Failed:%s\n" "$failed" >> "${DOTKIT_FAILURES:-/dev/stderr}"
