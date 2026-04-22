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
dotkit/scripts/dotfiles.sh
dotkit/scripts/profile.sh
dotkit/profiles/macos/provision.sh
```

## Prerequisites

These programs may need to be installed before running the bootstrap. Everything else used by the scripts (`awk`, `grep`, `sed`, `find`, `tr`, `cut`, `md5sum`, etc.) is included in recent macOS and most common distros.

| Cmd              | Pkg              | Notes                                                   |
| ---------------- | ---------------- | ------------------------------------------------------- |
| `curl` or `wget` | `curl` or `wget` | Debian slim and Ubuntu minimal lack both — install one. |
| `git`            | `git`            | Not included on any minimal distro.                     |
| `diff`           | `diffutils`      | Optional. Skipped automatically if absent.              |

## File map

| File                           | Purpose                                                                        |
| ------------------------------ | ------------------------------------------------------------------------------ |
| `run.sh`                       | Bootstrap. Clones repo, fetches and decrypts SSH keys, then runs `profile.sh`. |
| `scripts/profile.sh`           | Lists available profiles and runs the selected one.                            |
| `scripts/lib.sh`               | Shared shell utilities.                                                        |
| `scripts/dotfiles.sh`          | Symlinks a dotfiles directory into `~/`.                                       |
| `profiles/<name>/provision.sh` | Provisioning script for that profile.                                          |

## Profile structure

| Directory   | Purpose                                                |
| ----------- | ------------------------------------------------------ |
| `dotfiles/` | Dotfiles to symlink into `~/`.                         |
| `packages/` | Packages to install (one list per package manager).    |
| `configs/`  | Configs to apply (system preferences, UI tweaks, etc). |

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

**To encrypt your keys** (run once, then push all `.age` files to the private repo):

All files must use the **same passphrase** — `run.sh` reads it once and uses it for every file. Read it into a variable first so it is consistent across all encryption commands:

```shell
# Pick the right binary dir for your platform
AGE_DIR=./bin/age-v1.3.1/darwin-arm64  # or linux-amd64 / linux-arm64
chmod +x "$AGE_DIR/age" "$AGE_DIR/age-keygen" "$AGE_DIR/age-plugin-batchpass"

printf "age passphrase: "; read -r AGE_PASSPHRASE

AGE_PASSPHRASE="$AGE_PASSPHRASE" PATH="$AGE_DIR:$PATH" "$AGE_DIR/age" -e -j batchpass -o id_ed25519.age     ~/.ssh/id_ed25519
AGE_PASSPHRASE="$AGE_PASSPHRASE" PATH="$AGE_DIR:$PATH" "$AGE_DIR/age" -e -j batchpass -o id_ed25519.pub.age ~/.ssh/id_ed25519.pub
```

**To verify** the encrypted files decrypt correctly:

```shell
PATH="$AGE_DIR:$PATH" "$AGE_DIR/age" -d id_ed25519.age     | diff - ~/.ssh/id_ed25519
PATH="$AGE_DIR:$PATH" "$AGE_DIR/age" -d id_ed25519.pub.age | diff - ~/.ssh/id_ed25519.pub
```

**Generating a post-quantum key (optional)**

`age-keygen` supports hybrid post-quantum keys via `-pq`. These use ML-KEM (Kyber) alongside X25519 so that the encryption is secure even against a future quantum computer. If you prefer recipient-based encryption over a passphrase, generate a PQ identity once and encrypt to its public key:

```shell
# Generate a hybrid PQ identity (store identity.txt securely — treat it like a private key)
"$AGE_DIR/age-keygen" -pq -o identity.txt

# Encrypt SSH keys to the PQ public key
"$AGE_DIR/age" -r "$(grep 'public key:' identity.txt | awk '{print $NF}')" -o id_ed25519.age     ~/.ssh/id_ed25519
"$AGE_DIR/age" -r "$(grep 'public key:' identity.txt | awk '{print $NF}')" -o id_ed25519.pub.age ~/.ssh/id_ed25519.pub

# Decrypt
"$AGE_DIR/age" -d -i identity.txt id_ed25519.age     > ~/.ssh/id_ed25519
"$AGE_DIR/age" -d -i identity.txt id_ed25519.pub.age > ~/.ssh/id_ed25519.pub
```

> If you use recipient-based encryption, update `setup_ssh_keys` in `run.sh` to use `-i identity.txt` instead of `-j batchpass`.

**Generating a PAT (Personal Access Token)**

Go to [GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens](https://github.com/settings/personal-access-tokens) → Generate new token.

- Set a name like "Private SSH Key".
- Set the resource owner to your account.
- Select only your private SSH repo (i.e. `private-ssh-key`) under Repository access
- Add permissions to grant **Contents: Read-only**.
- Copy the token — it is shown only once. Store it in a secure note or password manager (e.g. password locked Apple note or Bitwarden).

**Updating age binaries**

As the age binary is improved, it is important to always save the binary you will be using to encrypt/decrypt in the `dotkit/bin` folder and to update the two keys in the private repo accordingly. If using a new passphrase, be sure to update that as well in your secure note / password manager.
