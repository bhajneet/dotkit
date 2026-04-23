#!/bin/sh
set -e
# Usage: curl -fsSL <url> | sh
#        wget -qO- <url>  | sh
#        sh run.sh

REPO="https://github.com/bhajneet/dotkit.git"
DOTKIT_DIR="$HOME/dev/dotkit"

# Optional doorknock. Set to md5sum of your passphrase to enable, or leave empty.
# Generate: echo -n "passphrase" | md5sum | cut -d' ' -f1
PASSPHRASE_HASH="7e0a4e3e87f404101afc3560977d35d9"

check_passphrase() {
  [ -z "$PASSPHRASE_HASH" ] && return 0
  printf "Passphrase: "; read -r input
  hash=$(printf '%s' "$input" | md5sum | cut -d' ' -f1)
  [ "$hash" = "$PASSPHRASE_HASH" ] || { echo "Incorrect passphrase." >&2; exit 1; }
}


install_prerequisites() {
  os=$(uname -s)
  case "$os" in
    Darwin)
      sudo xcode-select --switch /Library/Developer/CommandLineTools 2>/dev/null || true
      sudo xcodebuild -license accept 2>/dev/null || true
      git --version >/dev/null 2>&1 && return 0
      echo "Installing Xcode Command Line Tools (git)..."
      sudo xcode-select --install
      echo "Complete the installation popup, then re-run this script."
      exit 0
      ;;
    Linux)
      command -v git >/dev/null 2>&1 && return 0
      echo "Installing git..."
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y git
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y git
      else
        echo "Error: git is required. Please install it manually." >&2; exit 1
      fi
      ;;
  esac
}

main() {
  check_passphrase
  install_prerequisites
  [ -d "$DOTKIT_DIR" ] && { echo "Error: $DOTKIT_DIR already exists. Remove it and re-run." >&2; exit 1; }
  mkdir -p "$(dirname "$DOTKIT_DIR")" && echo "Cloning repo..."
  git clone "$REPO" "$DOTKIT_DIR"
  printf "Set up SSH keys? [y/N]: "; read -r ssh_choice
  case "$ssh_choice" in y|Y) sh "$DOTKIT_DIR/scripts/ssh-keys.sh" ;; esac
  sh "$DOTKIT_DIR/scripts/profile.sh"
}

# Redirect stdin from /dev/tty so interactive prompts work when piped through curl/wget
main "$@" </dev/tty
