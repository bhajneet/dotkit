#!/bin/sh
set -eu
. "$DOTKIT_DIR/scripts/lib.sh"
data="$DOTKIT_PROFILE_DIR/packages/brew_formulae.txt"
[ -f "$data" ] || exit 0

pkgs=$(parse_list "$data")

# Filter to only packages not already installed
to_install=""
while IFS= read -r pkg; do
  brew list --formula "$pkg" >/dev/null 2>&1 || to_install="$to_install $pkg"
done << EOF
$pkgs
EOF
to_install="${to_install# }"
[ -n "$to_install" ] || exit 0

# Prefetch bottles in parallel, then batch install
printf '%s\n' $to_install | xargs -P 16 -I {} brew fetch --formula {} 2>&1 || true
printf '%s\n' $to_install | xargs brew install || true

# Detect failures (brew install on already-installed pkg exits 0 immediately)
failed=""
for pkg in $to_install; do
  brew install "$pkg" 2>/dev/null || failed="$failed
  - $pkg"
done
[ -z "$failed" ] || printf "[packages/brew_formulae] Failed:%s\n" "$failed" >> "${DOTKIT_FAILURES:-/dev/stderr}"
