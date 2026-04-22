#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILES="$(dirname "$SCRIPT_DIR")/profiles"

# List available profiles, storing names for later resolution
echo "Available profiles:"
names=""
count=0
for dir in "$PROFILES"/*/; do
  [ -f "${dir}provision.sh" ] || continue
  count=$((count + 1))
  name="${dir%/}"; name="${name##*/}"
  names="${names}${name}
"
  printf "  %d) %s\n" "$count" "$name"
done

[ "$count" -gt 0 ] || { echo "No profiles found in $PROFILES" >&2; exit 1; }

# Get selection
if [ $# -ge 1 ]; then
  choice="$1"
else
  printf "\nSelect a profile [number or name]: "
  read -r choice
fi

# Resolve numeric choice to name
if echo "$choice" | grep -qE '^[0-9]+$'; then
  profile=$(printf '%s' "$names" | sed -n "${choice}p")
  [ -n "$profile" ] || { echo "Error: invalid selection '$choice'" >&2; exit 1; }
else
  profile="$choice"
fi

# Validate and run
provision="$PROFILES/$profile/provision.sh"
[ -f "$provision" ] || { echo "Error: profile '$profile' not found." >&2; exit 1; }

printf "\n▶ Running %s provision...\n\n" "$profile"
case "$(uname)" in
  Darwin) zsh "$provision" ;;
  *)      sh  "$provision" ;;
esac
