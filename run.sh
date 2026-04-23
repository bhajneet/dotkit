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

setup_ssh_keys() {
  os=$(uname -s | tr '[:upper:]' '[:lower:]'); arch=$(uname -m)
  case "$arch" in
    aarch64|arm64) arch="arm64" ;;
    x86_64) arch="amd64" ;;
  esac
  age_dir="$DOTKIT_DIR/bin/age-v1.3.1/${os}-${arch}"
  case "${os}-${arch}" in
    darwin-arm64|linux-amd64|linux-arm64) ;;
    *) echo "Error: no age binary for ${os}-${arch}." >&2; exit 1 ;;
  esac
  if command -v curl >/dev/null 2>&1; then
    _gh_get()  { curl -fsSL -H "Authorization: token $1" "$2"; }
    _gh_save() { curl -fsSL -H "Authorization: token $1" -H "Accept: application/vnd.github.v3.raw" "$2" -o "$3"; }
  elif command -v wget >/dev/null 2>&1; then
    _gh_get()  { wget -qO- --header="Authorization: token $1" "$2"; }
    _gh_save() { wget -qO "$3" --header="Authorization: token $1" --header="Accept: application/vnd.github.v3.raw" "$2"; }
  else
    echo "Error: curl or wget is required." >&2; exit 1
  fi
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  printf "GitHub PAT (to download SSH keys): "; read -r github_pat
  gh_url="https://api.github.com/repos/bhajneet/private-ssh-key/contents"
  age_files=$(_gh_get "$github_pat" "$gh_url" \
    | awk -F'"' '$2 == "name" && $4 ~ /\.age$/ { print $4 }')
  [ -z "$age_files" ] && { echo "Error: no .age files found in private-ssh-key repo." >&2; exit 1; }
  while IFS= read -r f; do
    _gh_save "$github_pat" "$gh_url/$f" "$HOME/.ssh/$f"
  done << EOF
$age_files
EOF
  chmod +x "$age_dir/age" "$age_dir/age-plugin-batchpass"
  printf "age passphrase: "; read -r age_passphrase
  export AGE_PASSPHRASE="$age_passphrase"
  export PATH="$age_dir:$PATH"
  echo "Decrypting SSH keys..."
  while IFS= read -r f; do
    out="${f%.age}"
    "$age_dir/age" --decrypt -j batchpass -o "$HOME/.ssh/$out" "$HOME/.ssh/$f" </dev/tty
    chmod 600 "$HOME/.ssh/$out"
  done << EOF
$age_files
EOF
}

install_prerequisites() {
  os=$(uname -s)
  case "$os" in
    Darwin)
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
  case "$ssh_choice" in y|Y) setup_ssh_keys ;; esac
  sh "$DOTKIT_DIR/scripts/profile.sh"
}

# Redirect stdin from /dev/tty so interactive prompts work when piped through curl/wget
main "$@" </dev/tty
