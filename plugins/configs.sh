#!/bin/sh
set -eu
[ -d "$DOTKIT_PROFILE_DIR/configs" ] || exit 0
for f in "$DOTKIT_PROFILE_DIR/configs/"*.sh; do
  [ -f "$f" ] || continue
  case "${DOTKIT_PLATFORM:-}" in
    macos) zsh "$f" || printf "[configs] Failed: %s\n" "$f" >> "${DOTKIT_FAILURES:-/dev/stderr}" ;;
    *)      sh "$f" || printf "[configs] Failed: %s\n" "$f" >> "${DOTKIT_FAILURES:-/dev/stderr}" ;;
  esac
done
