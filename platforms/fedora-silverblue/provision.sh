#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTKIT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
export DOTKIT_DIR

. "$DOTKIT_DIR/scripts/lib.sh"
[ -f "$DOTKIT_DIR/config.sh" ] && . "$DOTKIT_DIR/config.sh"

# Shared failure log — plugins append to this, displayed at end
DOTKIT_FAILURES=$(mktemp)
export DOTKIT_FAILURES

run_plugin() {
  plugin="$DOTKIT_DIR/plugins/$1.sh"
  [ -f "$plugin" ] || return 0
  echo "Running plugin $1..."
  sh "$plugin" || printf "[%s] Plugin exited with an error\n" "$1" >> "$DOTKIT_FAILURES"
}

# Packages: profile dictates what runs, packages_ordered dictates sort order
packages_ordered="flatpaks"
available=""
for f in "$DOTKIT_PROFILE_DIR/packages/"*.txt; do
  [ -f "$f" ] || continue
  name="${f##*/}"; name="${name%.txt}"
  available="$available $name"
done
for pkg in $packages_ordered; do
  case " $available " in
    *" $pkg "*) run_plugin "packages/$pkg" ;;
  esac
done
for name in $available; do
  case " $packages_ordered " in
    *" $name "*) continue ;;
  esac
  run_plugin "packages/$name"
done

# Dotfiles
run_plugin dotfiles

# Configs
run_plugin configs

# Extras: autodiscover
for f in "$DOTKIT_PROFILE_DIR/extras/"*.txt; do
  [ -f "$f" ] || continue
  name="${f##*/}"; name="${name%.txt}"
  run_plugin "extras/$name"
done

# Summary
echo ""
if [ -s "$DOTKIT_FAILURES" ]; then
  echo "Issues:"
  cat "$DOTKIT_FAILURES"
else
  echo "Provisioning complete."
fi
rm -f "$DOTKIT_FAILURES"
