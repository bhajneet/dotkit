#!/bin/sh
set -eu
. "$DOTKIT_DIR/scripts/lib.sh"
data="$DOTKIT_PROFILE_DIR/packages/brew_formulae.txt"
[ -f "$data" ] || exit 0

pkgs=$(parse_list "$data")

# Batch install — Homebrew resolves deps once and downloads bottles in parallel
printf '%s\n' "$pkgs" | xargs brew install || true

# Check which failed
failed=""
while IFS= read -r pkg; do
  brew list --formula "$pkg" >/dev/null 2>&1 || failed="$failed
  - $pkg"
done << EOF
$pkgs
EOF
[ -z "$failed" ] || printf "[packages/brew_formulae] Failed:%s\n" "$failed" >> "${DOTKIT_FAILURES:-/dev/stderr}"
