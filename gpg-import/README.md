# gpg-import

Composite GitHub Action to import GPG keys from:
- inline secret/value (armored key block)
- file path (armored or binary)
- keyserver (key id / fingerprint)

It auto-detects the input type, imports the key, and exposes key stats as outputs.

## What this action does

1. Optionally creates an isolated `GNUPGHOME`.
2. Validates and classifies `gpg_key`.
3. Optionally decrypts OpenSSL-encrypted payloads (`Salted__`, armored OpenSSL payloads).
4. Imports the key via inline/file/keyserver sub-action.
5. Aggregates outputs (`fingerprint`, key counts, `key_grips`).
6. Optionally configures Git for GPG signing.
7. Optionally presets passphrase in `gpg-agent`.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `gpg_key` | yes | - | Inline key content, file path, or key id/fingerprint |
| `gpg_pass` | no | `''` | Passphrase for GPG key (also used as SSL pass fallback) |
| `ssl_pass` | no | `''` | Passphrase for OpenSSL decryption |
| `keyserver_url` | no | `hkps://keys.openpgp.org` | Keyserver URL |
| `delete_after_import` | no | `true` | Securely delete key file after file import |
| `method` | no | `auto` | Declared import method hint (`secret`, `file`, `keyserver`, `auto`) |
| `gpg_home` | no | `''` | Explicit GPG home directory |
| `gpg_type` | no | `auto` | Key type hint (`auto`, `private`, `public`) |
| `configure_git` | no | `true` | Configure Git to sign commits/tags with imported key |
| `setup_home` | no | `true` | Create and use temporary GPG home |
| `preset_pass` | no | `true` | Preset passphrase with `gpg-agent` |
| `github_token` | no | `''` | Token for git/GitHub auth when configuring Git |

## Outputs

| Output | Description |
|---|---|
| `fingerprint` | Fingerprint of imported key (or keyserver key id) |
| `keys_total` | Total keys available |
| `keys_public` | Number of public keys |
| `keys_secret` | Number of secret keys |
| `gpg_home` | Effective GPG home directory |
| `key_grips` | Keygrips (if available) |

## Environment variables

- `GNUPGHOME`: used when provided; otherwise can be set by `setup_home`.
- `GH_TOKEN`: set internally from `inputs.github_token` (or inherited from environment) for Git/GitHub-related setup.

## Notes

- Input routing is primarily auto-detected from `gpg_key` content/path shape.
- `method` exists as a hint/compat input, but import dispatch is currently classification-driven.
- Keyserver import is public-key oriented.

## Example: inline private key from secret

```yaml
- name: Import private key
  uses: ./gpg-import
  with:
    gpg_key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg_pass: ${{ secrets.GPG_PASSPHRASE }}
    setup_home: 'true'
    configure_git: 'true'
```

## Example: import from key file

```yaml
- name: Import key from file
  uses: ./gpg-import
  with:
    gpg_key: ./keys/release-private.asc
    gpg_pass: ${{ secrets.GPG_PASSPHRASE }}
    delete_after_import: 'true'
```

## Example: import public key from keyserver

```yaml
- name: Import maintainer pubkey from keyserver
  uses: ./gpg-import
  with:
    gpg_key: AABBCCDDEEFF00112233445566778899AABBCCDD
    keyserver_url: hkps://keys.openpgp.org
    configure_git: 'false'
```

## Common failures

- `gpg_key input is required`: missing or empty `gpg_key`.
- `Unable to classify gpg_key input`: value is not file path, armored key block, or valid key id/fingerprint.
- `Failed to import public key from keyserver`: keyserver unreachable, unknown key, or network policy issue.
- GPG import errors for private key: wrong `gpg_pass` or malformed key data.

## Quick verification

After import, verify action outputs in a later step:

```yaml
- name: Show key stats
  run: |
    echo "FP=${{ steps.gpg_import.outputs.fingerprint }}"
    echo "PUB=${{ steps.gpg_import.outputs.keys_public }}"
    echo "SEC=${{ steps.gpg_import.outputs.keys_secret }}"
    echo "TOT=${{ steps.gpg_import.outputs.keys_total }}"
```

