# dotkit

A shell-based bootstrapping and provisioning kit built around dotfiles. Bootstrap a new machine with a single curl/wget command, select a profile, and have your full environment (dotfiles, packages, system settings) configured automatically. Profiles support multiple machines and operating systems with no dependencies beyond sh.

```shell
curl -fsSL <url> | sh
```

```shell
wget -qO- <url> | sh
```

## How to run

Bootstrap and provision a new machine in one step. For example, the raw GitHub URL for this repo is:

```shell
curl -fsSL https://raw.githubusercontent.com/bhajneet/dotkit/main/run.sh | sh
```

For example, use a subdomain as a Cloudflare Redirect Rule to the raw GitHub URL:

```shell
curl -fsSL https://dotkit.<your-domain>.com | sh
```

The goal of scripts is to be idempotent. Some examples of scripts that can be re-run (safely afaik):

```shell
dotkit/scripts/profile.sh
dotkit/platforms/macos/provision.sh
```

## Prerequisites

These programs may need to be installed before running the bootstrap. Everything else used by the scripts (`awk`, `grep`, `sed`, `find`, `tr`, `cut`, `md5sum`, etc.) is included in recent macOS and most common distros.

| Cmd              | Pkg              | Notes                                                   |
| ---------------- | ---------------- | ------------------------------------------------------- |
| `curl` or `wget` | `curl` or `wget` | Debian slim and Ubuntu minimal lack both — install one. |
| `git`            | `git`            | Not included on any minimal distro.                     |
| `diff`           | `diffutils`      | Optional. Skipped automatically if absent.              |

## File map

| Path                                      | Purpose                                                                         |
| ----------------------------------------- | ------------------------------------------------------------------------------- |
| `run.sh`                                  | Bootstrap. Clones repo, fetches and decrypts SSH keys, then runs `profile.sh`. |
| `config.sh`                               | Optional top-level config (e.g. `DEV_DIR`). Sourced by plugins if present.     |
| `scripts/profile.sh`                      | Detects platform, lists matching profiles, and runs the selected one.           |
| `scripts/lib.sh`                          | Shared shell utilities (`parse_list`).                                          |
| `platforms/<platform>/provision.sh`       | Orchestrator for that platform. Controls plugin ordering and autodiscovery.     |
| `plugins/<name>.sh`                       | Cross-platform plugin. Reads data from the active profile via `$DOTKIT_PROFILE_DIR`. |
| `plugins/packages/<name>.sh`              | Package manager plugin (e.g. `brew_formulae`, `flatpaks`).                     |
| `plugins/extras/<name>.sh`               | Extra plugin (e.g. `repos`).                                                    |
| `profiles/<platform>/<name>/`             | A profile. Data-only — no scripting logic.                                      |

## Plugin system

Plugins are shell scripts in `plugins/` that read their data from the active profile via `$DOTKIT_PROFILE_DIR`. The platform's `provision.sh` is a thin orchestrator — it runs plugins in a fixed category order and autodiscovers anything extra.

> **Note:** The `plugins/` folder is bundled in this repo for convenience. In future, plugins will be downloaded automatically from the upstream dotkit plugins project based on what the profile needs — so you won't need to maintain them yourself.

**Category order:** `packages` → `dotfiles` → `configs` → `extras`

Within `packages`, what runs is determined entirely by what `.txt` files exist in the profile's `packages/` folder — one file per package manager plugin, matched by filename. An ordered list in `provision.sh` controls their relative order; anything not in the list runs after in discovered order.

**To enable or disable a plugin**, add or remove the corresponding `.txt` file from your profile's `packages/` folder. For plugins with no data file (e.g. `brew_cli`, `fnm`), an empty `.txt` acts as an opt-in marker. For `extras`, add or remove the subdirectory under `extras/`.

`extras` are fully autodiscovered: any `.txt` file under `profiles/<platform>/<name>/extras/` is matched to a plugin in `plugins/extras/` by filename.

**To add a new plugin:**

1. Create `plugins/<category>/<name>.sh` with the install/setup logic. Use `$DOTKIT_PROFILE_DIR` to locate data files and `$DOTKIT_DIR` for shared utilities.
2. Add the corresponding data file or folder in your profile (e.g. `profiles/<platform>/<name>/packages/<name>.txt`).
3. If order matters within a category, add it to the ordered list in the platform's `provision.sh`. Otherwise it autodiscovers.

## Platform detection

`scripts/profile.sh` detects the current platform from `uname` and `/etc/os-release`, then lists only the profiles available for that platform. Supported platforms: `macos`, `fedora-silverblue`, `fedora`, `ubuntu`, `debian`.

## Profile structure

Profiles live at `profiles/<platform>/<name>/` and contain only data — no scripting logic.

| Path            | Purpose                                                                |
| --------------- | ---------------------------------------------------------------------- |
| `dotfiles/`     | Dotfiles to symlink into `~/`.                                         |
| `packages/`     | One `.txt` file per package manager. Matched to a plugin by filename. |
| `configs/`      | Platform-specific config scripts (system prefs, UI tweaks, etc).      |
| `extras/`       | One `.txt` file per extra plugin (e.g. `extras/repos.txt`).           |

## Doorknock (optional)

An optional passphrase check before doing anything. Leave it empty to disable. Set `PASSPHRASE_HASH` to the md5sum of your passphrase to enable it — anyone who runs the bootstrap URL without the passphrase will be rejected.

Generate the hash:

```shell
echo -n "passphrase" | md5sum | cut -d' ' -f1
```

> **Note: This is not at all a security measure.**
>
> Ignoring already that MD5 hashes are trivially reversible via pre-computed rainbow tables, anyone can simply download `run.sh` and edit out the check before running it.
>
> This option is purely a small deterrent against mindless execution of a URL piped to `sh`.

## SSH key setup (optional)

**SSH keys should be very strongly guarded.**

For this program, they are stored encrypted in a separate private GitHub repo (i.e. `private-ssh-key`). The bootstrap script uses a PAT to download the keys and then decrypts them using the `age` binaries bundled in `bin/age-v1.3.1/`.

Someone would need both the PAT and `age` passphrase to be able to unlock these SSH keys. One way the PAT could be circumvented is if your entire GitHub account were to be hacked into (which gives access to the private repo), so it's strongly recommended to have 2FA on your GitHub account. Even if they gained access to the private repo, they would still need the `age` passphrase to decrypt the keys, so there is still that layer of protection.

Both of the GitHub PAT and age passphrase should be saved securely in a locked note or password manager (e.g. Apple Notes or Bitwarden). Again, if someone gained access to these, it would spell trouble. You could even print out the PAT and age passphrase and store it in a locked vault. Level of security is up to you.

If you do not prefer this arrangement, you may skip the SSH restoration step in `run.sh`, and roll your own method. Perhaps you save your encrypted SSH keys on a thumbdrive or NAS. Though most experts seem to recommend you to use new SSH keys per machines for security purposes. So you may want to create new SSH keys for every machine you provision.

**Private repo structure:**

Any number of `.age` files — `run.sh` discovers them automatically. For example:

```shell
private-ssh-key/
  id_ed25519.age
  id_ed25519.pub.age
```

Each file is downloaded to `~/.ssh/` and decrypted in place (stripping the `.age` extension).

**To encrypt your keys** (run from any directory, then push all `.age` files to the private repo):

All files use the **same passphrase** — `run.sh` reads it once and uses it for every file.

Set the age binary path:
```shell
AGE_DIR="$HOME/dev/dotkit/bin/age-v1.3.1/darwin-arm64"  # or linux-amd64 / linux-arm64
chmod +x "$AGE_DIR/age" "$AGE_DIR/age-plugin-batchpass"
```

Navigate to your SSH folder and back up any existing `.age` files from a previous run:
```shell
cd ~/.ssh
for f in *.age; do
  [ -f "$f" ] && mv "$f" "$f.bak.$(date +%Y%m%d%H%M%S)"
done
```

Read the passphrase and encrypt everything that isn't already an `.age` or `.age.bak.*` file:
```shell
printf "age passphrase: "; read -r AGE_PASSPHRASE
export AGE_PASSPHRASE
export PATH="$AGE_DIR:$PATH"

for f in *; do
  [ -f "$f" ] || continue
  case "$f" in *.age|*.age.bak.*) continue ;; esac
  "$AGE_DIR/age" -e -j batchpass -o "$f.age" "$f"
  echo "Encrypted: $f → $f.age"
done
```

**To verify** all encrypted files decrypt correctly:

```shell
printf "age passphrase: "; read -r AGE_PASSPHRASE
export AGE_PASSPHRASE
export PATH="$AGE_DIR:$PATH"

for f in *.age; do
  [ -f "$f" ] || continue
  original="${f%.age}"
  [ -f "$original" ] || continue
  "$AGE_DIR/age" -d -j batchpass "$f" | diff - "$original" \
    && echo "OK: $f" || echo "FAIL: $f"
done
```

**Generating a PAT (Personal Access Token)**

Go to [GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens](https://github.com/settings/personal-access-tokens) → Generate new token.

- Set a name like "Private SSH Key".
- Set the resource owner to your account.
- Select only your private SSH repo (i.e. `private-ssh-key`) under Repository access
- Add permissions to grant **Contents: Read-only**.
- Copy the token — it is shown only once. Store it in a secure note or password manager (e.g. password locked Apple note or Bitwarden).

**Updating age binaries**

As the age binary is improved, it is important to always save the binary you will be using to encrypt/decrypt in the `dotkit/bin` folder and to update the two keys in the private repo accordingly. If using a new passphrase, be sure to update that as well in your secure note / password manager.
