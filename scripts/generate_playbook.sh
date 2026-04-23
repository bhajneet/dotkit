#!/bin/sh
# Usage: sh scripts/generate_playbook.sh
# Generates a human-readable overview of what a profile will do.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTKIT_DIR="$(dirname "$SCRIPT_DIR")"
PROFILES="$DOTKIT_DIR/profiles"

detect_platform() {
  os=$(uname -s)
  case "$os" in
    Darwin) echo "macos" ;;
    Linux)
      [ -f /etc/os-release ] && . /etc/os-release
      case "${ID}-${VARIANT_ID:-}" in
        fedora-silverblue) echo "fedora-silverblue" ;;
        fedora-)           echo "fedora" ;;
        ubuntu-)           echo "ubuntu" ;;
        debian-)           echo "debian" ;;
        *)                 echo "linux" ;;
      esac ;;
    *) echo "$os" | tr '[:upper:]' '[:lower:]' ;;
  esac
}

PLATFORM=$(detect_platform)
PLATFORM_DIR="$PROFILES/$PLATFORM"
[ -d "$PLATFORM_DIR" ] || { echo "Error: no profiles for platform '$PLATFORM'." >&2; exit 1; }

echo "Platform: $PLATFORM"
echo "Available profiles:"
names=""; count=0
for dir in "$PLATFORM_DIR/"/*/; do
  [ -d "$dir" ] || continue
  count=$((count + 1))
  name="${dir%/}"; name="${name##*/}"
  names="${names}${name}
"
  printf "  %d) %s\n" "$count" "$name"
done
[ "$count" -gt 0 ] || { echo "No profiles found." >&2; exit 1; }
printf "\nSelect a profile [number or name]: "
read -r choice
if echo "$choice" | grep -qE '^[0-9]+$'; then
  profile=$(printf '%s' "$names" | sed -n "${choice}p")
else
  profile="$choice"
fi
[ -n "$profile" ] || { echo "Error: invalid selection." >&2; exit 1; }
PROFILE_DIR="$PLATFORM_DIR/$profile"
[ -d "$PROFILE_DIR" ] || { echo "Error: profile '$profile' not found." >&2; exit 1; }

# Print items from a .txt file grouped by comment headers
print_pkg_section() {
  title="$1"; file="$2"
  [ -f "$file" ] || return 0
  printf "\n%s\n" "$title"
  awk '
    /^[[:space:]]*#/ {
      sub(/^[[:space:]]*#[[:space:]]*/, "")
      if ($0 != "") category = $0
      next
    }
    /^[[:space:]]*$/ { next }
    {
      if (category != last_cat) {
        printf "  %s:\n", category
        last_cat = category
      }
      printf "    - %s\n", $0
    }
  ' "$file"
}

# Print App Store apps showing name only (from "id = Name" format)
print_mas_section() {
  file="$1"
  [ -f "$file" ] || return 0
  printf "\nApp Store\n"
  awk '
    /^[[:space:]]*#/ {
      sub(/^[[:space:]]*#[[:space:]]*/, "")
      if ($0 != "") category = $0
      next
    }
    /^[[:space:]]*$/ { next }
    /^[[:space:]]*[0-9]/ {
      if (category != last_cat) {
        printf "  %s:\n", category
        last_cat = category
      }
      split($0, parts, " = ")
      printf "    - %s\n", (length(parts) > 1 ? parts[2] : $0)
    }
  ' "$file"
}

# Print manual installs showing "Name — URL/instructions" format
print_manual_section() {
  file="$1"
  [ -f "$file" ] || return 0
  printf "\nManual Installs\n"
  grep -v '^[[:space:]]*#' "$file" | grep -v '^[[:space:]]*$' | while IFS= read -r line; do
    name="${line%% = *}"
    info="${line#* = }"
    printf "  - %s — %s\n" "$name" "$info"
  done
}

# Print dotfiles relative to dotfiles/
print_dotfiles_section() {
  dir="$1"
  [ -d "$dir" ] || return 0
  printf "\nDotfiles\n"
  find "$dir" -type f -not -name ".DS_Store" | sort | while read -r f; do
    rel="${f#$dir/}"
    printf "  - %s\n" "$rel"
  done
}

# Print config scripts
print_configs_section() {
  dir="$1"
  [ -d "$dir" ] || return 0
  printf "\nConfig Scripts\n"
  for f in "$dir"/*.sh; do
    [ -f "$f" ] || continue
    printf "  - %s\n" "${f##*/}"
  done
}

# Print key = value lines
print_kv_section() {
  title="$1"; file="$2"
  [ -f "$file" ] || return 0
  printf "\n%s\n" "$title"
  grep -v '^[[:space:]]*#' "$file" | grep -v '^[[:space:]]*$' | while IFS= read -r line; do
    printf "  %s\n" "$line"
  done
}

# Print repos grouped by comment headers
print_repos_section() {
  file="$1"
  [ -f "$file" ] || return 0
  printf "\nRepos\n"
  awk '
    /^[[:space:]]*#/ {
      sub(/^[[:space:]]*#[[:space:]]*/, "")
      # Skip header/format comments (contain "Format:" or "->")
      if ($0 ~ /Format:|->/ || $0 ~ /clone into/) { next }
      if ($0 != "") category = $0
      next
    }
    /^[[:space:]]*$/ { next }
    {
      if (category != last_cat) {
        printf "  %s:\n", category
        last_cat = category
      }
      printf "    - %s\n", $0
    }
  ' "$file"
}

# Output
printf "\nPlaybook: %s/%s\n" "$PLATFORM" "$profile"
printf '%0.s=' $(seq 1 $((${#PLATFORM} + ${#profile} + 11)))
printf "\n"

print_pkg_section    "Homebrew Formulae"  "$PROFILE_DIR/packages/brew_formulae.txt"
print_pkg_section    "Homebrew Casks"     "$PROFILE_DIR/packages/brew_casks.txt"
print_mas_section                         "$PROFILE_DIR/packages/mas.txt"
print_manual_section                      "$PROFILE_DIR/packages/manual.txt"
print_dotfiles_section                    "$PROFILE_DIR/dotfiles"
print_configs_section                     "$PROFILE_DIR/configs"
print_kv_section     "Git Config"         "$PROFILE_DIR/extras/git.txt"
print_repos_section                       "$PROFILE_DIR/extras/repos.txt"

printf "\n"
