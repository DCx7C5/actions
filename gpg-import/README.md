# gpg-import

[![Test GPG Import](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml)

> Composite GitHub Action for importing GPG keys from inline secrets, file paths, or keyservers.

Auto-detects input type, imports the key, and exposes key metadata as action outputs.

---

## Features

- **Auto-detection** – Classifies `key` as inline content, file path, or fingerprint/key-id automatically.
- **OpenSSL decryption** – Transparently decrypts `Salted__` / base64-encoded OpenSSL payloads before import.
- **Isolated GPG home** – Optionally creates a temporary `GNUPGHOME` for secure, isolated imports.
- **Git integration** – Configures Git to sign commits and tags with the imported key.
- **Passphrase caching** – Presets the passphrase in `gpg-agent` so subsequent operations don't prompt.

## How it works

1. Masks sensitive inputs (`key`, `gpg-pass`, `ssl-pass`).
2. Optionally creates an isolated `GNUPGHOME` (`initialize-home`).
3. Validates and classifies the `key` input via `gpg-validate-import`.
4. Optionally decrypts OpenSSL-encrypted payloads via `ssl-decrypt`.
5. Dispatches to the appropriate sub-action:
   - **inline** → `gpg-import-inline`
   - **file** → `gpg-import-file`
   - **keyserver** → `gpg-import-keyserver`
6. Aggregates outputs (`fingerprint`, key counts, `key_grips`).
7. Optionally sets owner trust for private keys (`owner-trust-level`).
8. Optionally configures Git for GPG signing (`configure-git`).
9. Optionally presets passphrase in `gpg-agent` (`preset-passphrase-cache`).

---

## Inputs

| Input                     | Required | Default                   | Description                                                                             |
|---------------------------|:--------:|---------------------------|-----------------------------------------------------------------------------------------|
| `key`                     | **yes**  | –                         | Inline key content, file path, or key fingerprint/id                                    |
| `gpg-pass`                |    no    | `''`                      | Passphrase for the GPG private key (also used as SSL-pass fallback)                     |
| `ssl-pass`                |    no    | `''`                      | Passphrase for OpenSSL decryption (if different from `gpg-pass`)                        |
| `keyserver-url`           |    no    | `hkps://keys.openpgp.org` | Keyserver URL for fingerprint-based imports                                             |
| `delete-after-import`     |    no    | `true`                    | Securely shred the key file after a file-based import                                   |
| `import-method`           |    no    | `auto`                    | Import method hint (`auto`, `secret`, `file`, `keyserver`)                              |
| `gpg-home`                |    no    | `''`                      | Explicit GPG home directory (falls back to `GNUPGHOME` env)                             |
| `gpg-type`                |    no    | `auto`                    | Key type hint (`auto`, `private`, `public`)                                             |
| `configure-git`           |    no    | `true`                    | Configure Git to sign commits/tags with the imported key                                |
| `initialize-home`         |    no    | `true`                    | Create and use a temporary GPG home directory for isolation                             |
| `preset-passphrase-cache` |    no    | `true`                    | Preset passphrase in `gpg-agent` for non-interactive operations                         |
| `owner-trust-level`       |    no    | `6`                       | Owner trust level for imported private keys (`1`–`5`, or `6` = ultimate)                |
| `gpg-name`                |    no    | `''`                      | Name for Git GPG signing config                                                         |
| `gpg-mail`                |    no    | `''`                      | Email for Git GPG signing config                                                        |
| `gh-token`                |    no    | `''`                      | GitHub token for authenticated Git operations (falls back to `GH_TOKEN`/`GITHUB_TOKEN`) |

## Outputs

| Output        | Description                                    |
|---------------|------------------------------------------------|
| `fingerprint` | Fingerprint of the imported key                |
| `keys_total`  | Total number of keys after import              |
| `keys_public` | Number of public keys                          |
| `keys_secret` | Number of secret keys                          |
| `gpg_home`    | Effective `GNUPGHOME` used during import       |
| `key_grips`   | Keygrips of imported secret keys (multi-line)  |

## Environment variables

| Variable    | Description                                                                 |
|-------------|-----------------------------------------------------------------------------|
| `GNUPGHOME` | Used when set; otherwise created by `initialize-home`                       |
| `GH_TOKEN`  | Inherited from environment or set via `gh-token` for Git/GitHub operations  |

---

## Usage examples

### Import a private key from a secret

```yaml
- name: Import GPG private key
  id: gpg
  uses: DCx7C5/actions/gpg-import@v1
  with:
    key: ${{ secrets.GPG_PRIVATE_KEY }}
    gpg-pass: ${{ secrets.GPG_PASSPHRASE }}
    initialize-home: 'true'
    configure-git: 'true'
```

### Import from a key file

```yaml
- name: Import key from file
  uses: DCx7C5/actions/gpg-import@v1
  with:
    key: ./keys/release-private.asc
    gpg-pass: ${{ secrets.GPG_PASSPHRASE }}
    delete-after-import: 'true'
```

### Import a public key from a keyserver

```yaml
- name: Import maintainer public key
  uses: DCx7C5/actions/gpg-import@v1
  with:
    key: AABBCCDDEEFF00112233445566778899AABBCCDD
    keyserver-url: hkps://keys.openpgp.org
    configure-git: 'false'
```

### Verify outputs in a later step

```yaml
- name: Show key stats
  run: |
    echo "Fingerprint : ${{ steps.gpg.outputs.fingerprint }}"
    echo "Public keys : ${{ steps.gpg.outputs.keys_public }}"
    echo "Secret keys : ${{ steps.gpg.outputs.keys_secret }}"
    echo "Total keys  : ${{ steps.gpg.outputs.keys_total }}"
    echo "GPG Home    : ${{ steps.gpg.outputs.gpg_home }}"
```

---

## Sub-actions

| Sub-action                  | Purpose                                              |
|-----------------------------|------------------------------------------------------|
| `gpg-validate-import`       | Validate and classify `key` input                    |
| `gpg-import-inline`         | Import from inline PGP key block                     |
| `gpg-import-file`           | Import from a local file (armored or binary)         |
| `gpg-import-keyserver`      | Fetch and import a public key from a keyserver       |
| `gpg-import-protected`      | Import a passphrase-protected private key            |
| `gpg-import-no-protection`  | Import a key without passphrase protection           |

## Troubleshooting

| Error message                                         | Cause / Fix                                                                |
|-------------------------------------------------------|----------------------------------------------------------------------------|
| `gpg-key input is required`                           | `key` is empty or not provided                                             |
| `Unable to classify gpg_key input`                    | Value is not a file path, armored PGP block, or valid fingerprint/key-id   |
| `Failed to import public key from keyserver`          | Keyserver unreachable, unknown key, or network policy blocking the request |
| GPG import errors for private key                     | Wrong `gpg-pass`, malformed key data, or incompatible GPG version          |
| `Invalid fingerprint. Must be at least 16 characters` | Fingerprint/key-id too short – provide at least 16 hex characters          |

## Notes

- Import routing is **classification-driven**: `import-method` is a hint and can usually be left at `auto`.
- Keyserver imports are **public-key only** – private keys cannot be fetched from keyservers.
- `delete-after-import` uses `shred` (falls back to `rm`) for secure file deletion.
- Output names use underscores (e.g., `keys_total`) for compatibility with GitHub Actions expression syntax.
