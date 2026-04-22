#!/bin/sh
# Usage: curl -fsSL <url> | sh
#        wget -qO- <url>  | sh
#        sh run.sh

REPO="https://github.com/bhajneet/dotkit.git"
DOTKIT_DIR="$HOME/dev/dotkit"

# Optional doorknock. Set to md5sum of your passphrase to enable, or leave empty.
# Generate: echo -n "passphrase" | md5sum | cut -d' ' -f1
PASSPHRASE_HASH=""

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
  for f in $age_files; do
    _gh_save "$github_pat" "$gh_url/$f" "$HOME/.ssh/$f"
  done
  chmod +x "$age_dir/age" "$age_dir/age-plugin-batchpass"
  printf "age passphrase: "; read -r age_passphrase
  echo "Decrypting SSH keys..."
  for f in $age_files; do
    out="${f%.age}"
    AGE_PASSPHRASE="$age_passphrase" PATH="$age_dir:$PATH" "$age_dir/age" --decrypt -j batchpass -o "$HOME/.ssh/$out" "$HOME/.ssh/$f"
    chmod 600 "$HOME/.ssh/$out"
  done
}

main() {
  check_passphrase
  printf "Set up SSH keys? [y/N]: "; read -r ssh_choice
  case "$ssh_choice" in y|Y) setup_ssh_keys ;; esac
  [ -d "$DOTKIT_DIR" ] && { echo "Error: $DOTKIT_DIR already exists. Remove it and re-run." >&2; exit 1; }
  command -v git >/dev/null 2>&1 || { echo "Error: git is required." >&2; exit 1; }
  mkdir -p "$(dirname "$DOTKIT_DIR")" && echo "Cloning repo..."
  git clone "$REPO" "$DOTKIT_DIR"
  sh "$DOTKIT_DIR/scripts/profile.sh"
}

# Redirect stdin from /dev/tty so interactive prompts work when piped through curl/wget
main "$@" </dev/tty
