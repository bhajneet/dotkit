#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
DOTKIT_DIR="${SCRIPT_DIR:h:h}"
export DOTKIT_DIR

. "$DOTKIT_DIR/scripts/lib.sh"
[ -f "$DOTKIT_DIR/config.sh" ] && . "$DOTKIT_DIR/config.sh"

# Ensure brew is in PATH (no-op if not yet installed)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Keep screen awake and prevent sleep for the duration
caffeinate -dims &
_caffeinate_pid=$!
trap "kill $_caffeinate_pid 2>/dev/null" EXIT

# Sudo keep-alive: prompt once, refresh every 50s in background
sudo -v
while true; do sudo -n true; sleep 50; done &
_sudo_pid=$!
trap "kill $_caffeinate_pid $_sudo_pid 2>/dev/null" EXIT

export HOMEBREW_CURL_RETRIES=2
export HOMEBREW_DOWNLOAD_CONCURRENCY=4

# Prompt for dev directory
printf "Dev directory [%s]: " "$HOME/dev"
read -r _dev_dir
export DEV_DIR="${_dev_dir:-$HOME/dev}"

# Accept Xcode/CLT license non-interactively
sudo xcodebuild -license accept 2>/dev/null || true

# Shared failure log — plugins append to this, displayed at end
DOTKIT_FAILURES=$(mktemp)
export DOTKIT_FAILURES

run_plugin() {
  local plugin="$DOTKIT_DIR/plugins/$1.sh"
  [[ -f "$plugin" ]] || return 0
  echo "Running plugin $1..."
  zsh "$plugin" || printf "[%s] Plugin exited with an error\n" "$1" >> "$DOTKIT_FAILURES"
}

# Packages: profile dictates what runs, packages_ordered dictates sort order
local -a packages_ordered=(brew_cli brew_taps brew_formulae brew_casks mas manual fnm)
local -a available=()
for f in "$DOTKIT_PROFILE_DIR/packages/"*.txt; do
  [[ -f "$f" ]] || continue
  name="${f##*/}"; name="${name%.txt}"
  available+=("$name")
done
for pkg in "${packages_ordered[@]}"; do
  [[ " ${available[*]} " == *" $pkg "* ]] || continue
  run_plugin "packages/$pkg"
  # Re-eval after brew_cli in case it was just installed
  [[ "$pkg" == "brew_cli" ]] && [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
done
for name in "${available[@]}"; do
  [[ " ${packages_ordered[*]} " == *" $name "* ]] && continue
  run_plugin "packages/$name"
done

# Re-accept Xcode license in case Xcode was just installed via mas
sudo xcodebuild -license accept 2>/dev/null || true

# Dotfiles
run_plugin dotfiles

# Configs
run_plugin configs

# Extras: autodiscover
for f in "$DOTKIT_PROFILE_DIR/extras/"*.txt; do
  [[ -f "$f" ]] || continue
  name="${f##*/}"; name="${name%.txt}"
  run_plugin "extras/$name"
done

# Summary
echo ""
if [[ -s "$DOTKIT_FAILURES" ]]; then
  echo "Issues:"
  cat "$DOTKIT_FAILURES"
else
  echo "Provisioning complete."
fi
rm -f "$DOTKIT_FAILURES"
