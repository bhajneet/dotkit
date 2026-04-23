#!/bin/sh
set -eu
. "$DOTKIT_DIR/scripts/lib.sh"
DEV_DIR="${DEV_DIR:-$HOME/dev}"
[ -f "$DOTKIT_DIR/config.sh" ] && . "$DOTKIT_DIR/config.sh"
data="$DOTKIT_PROFILE_DIR/extras/repos.txt"
[ -f "$data" ] || exit 0
echo "Cloning repos..."
while IFS= read -r repo; do
  org="${repo%%/*}"
  name="${repo##*/}"
  dest="$DEV_DIR/$org/$name"
  if [ -d "$dest" ]; then
    echo "  Skipping $repo (already exists)"
  else
    mkdir -p "$DEV_DIR/$org"
    git clone "git@github.com:${repo}.git" "$dest" || \
      printf "[extras/repos] Failed to clone: %s\n" "$repo" >> "${DOTKIT_FAILURES:-/dev/stderr}"
  fi
done << EOF
$(parse_list "$data")
EOF
