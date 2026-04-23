#!/bin/sh
set -e

DOTKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

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
echo "DEBUG: age_files='$age_files'"
printf '%s\n' "$age_files" | while IFS= read -r f; do
  echo "DEBUG: downloading '$f'"
  _gh_save "$github_pat" "$gh_url/$f" "$HOME/.ssh/$f"
done

chmod +x "$age_dir/age" "$age_dir/age-plugin-batchpass"
printf "age passphrase: "; read -r age_passphrase
export AGE_PASSPHRASE="$age_passphrase"
export PATH="$age_dir:$PATH"
echo "Decrypting SSH keys..."
printf '%s\n' "$age_files" | while IFS= read -r f; do
  out="${f%.age}"
  echo "DEBUG: decrypting '$f' -> '$out'"
  "$age_dir/age" --decrypt -j batchpass -o "$HOME/.ssh/$out" "$HOME/.ssh/$f"
  echo "DEBUG: exit $?"
  chmod 600 "$HOME/.ssh/$out"
done
