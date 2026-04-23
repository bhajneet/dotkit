#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTKIT_DIR="$(dirname "$SCRIPT_DIR")"
PROFILES="$DOTKIT_DIR/profiles"
PLATFORMS="$DOTKIT_DIR/platforms"

# Detect current platform
detect_platform() {
  os=$(uname -s)
  case "$os" in
    Darwin) echo "macos" ;;
    Linux)
      if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "${ID}-${VARIANT_ID:-}" in
          fedora-silverblue) echo "fedora-silverblue" ;;
          fedora-)           echo "fedora" ;;
          ubuntu-)           echo "ubuntu" ;;
          debian-)           echo "debian" ;;
          *)                 echo "linux" ;;
        esac
      else
        echo "linux"
      fi
      ;;
    *) echo "$os" | tr '[:upper:]' '[:lower:]' ;;
  esac
}

PLATFORM=$(detect_platform)
export DOTKIT_PLATFORM="$PLATFORM"
PLATFORM_DIR="$PROFILES/$PLATFORM"

[ -d "$PLATFORM_DIR" ] || { echo "Error: no profiles found for platform '$PLATFORM'." >&2; exit 1; }

# List profiles for the current platform
echo "Platform: $PLATFORM"
echo "Available profiles:"
names=""
count=0
for dir in "$PLATFORM_DIR/"/*/; do
  [ -d "$dir" ] || continue
  count=$((count + 1))
  name="${dir%/}"; name="${name##*/}"
  names="${names}${name}
"
  printf "  %d) %s\n" "$count" "$name"
done

[ "$count" -gt 0 ] || { echo "No profiles found in $PLATFORM_DIR" >&2; exit 1; }

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

# Validate profile and platform provision script
export DOTKIT_PROFILE_DIR="$PLATFORM_DIR/$profile"
[ -d "$DOTKIT_PROFILE_DIR" ] || { echo "Error: profile '$profile' not found." >&2; exit 1; }

provision="$PLATFORMS/$PLATFORM/provision.sh"
[ -f "$provision" ] || { echo "Error: no provision script for platform '$PLATFORM'." >&2; exit 1; }

printf "\n▶ Running %s/%s provision...\n\n" "$PLATFORM" "$profile"
case "$PLATFORM" in
  macos) zsh "$provision" ;;
  *)     sh  "$provision" ;;
esac
