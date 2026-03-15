# gpg-sign-detached

Composite GitHub Action to create detached ASCII-armored OpenPGP signatures for files.

## What this action does

- Selects files from workspace using a pattern/list input.
- Creates detached signatures with configurable extension.
- Optionally signs with a specific key ID.
- Supports passphrase input when passphrase is not pre-cached.
- Exposes created signature files via action output.

## Inputs

| Input                | Required | Default                   | Description                                                    |
|----------------------|----------|---------------------------|----------------------------------------------------------------|
| `files`              | no       | `*.tar.gz`                | File pattern or file list to sign.                             |
| `sig_ext`            | no       | `sig`                     | Extension for generated detached signatures.                   |
| `workspace_dir`      | no       | `${{ github.workspace }}` | Working directory where files are resolved/signed.             |
| `gpg_keyid`          | no       | `""`                      | GPG key ID to use for signing; default key is used when empty. |
| `gpg_passphrase`     | no       | `""`                      | GPG passphrase for loopback signing when needed.               |
| `gpg_pass_precached` | no       | `false`                   | Set to `true` when passphrase is already cached in gpg-agent.  |

## Outputs

| Output         | Description                                                                         |
|----------------|-------------------------------------------------------------------------------------|
| `signed_files` | Space-separated list of created signature files from the signing step output block. |

## Dependencies

- `bash`
- `gpg`
- Signable input files in `workspace_dir`
- Accessible secret/key material for selected signing key

## Operation flow

1. Resolve files to sign from input pattern/list.
2. Exit successfully with warning if no files match.
3. Build `gpg --detach-sign --armor` command per file.
4. Add key selection and optional passphrase loopback args.
5. Verify each signature file exists after signing.
6. Export created signature file list to `signed_files` output.

## Examples

## Example: sign release archives with default key

```yaml
- name: Create detached signatures
  id: sig
  uses: ./gpg-sign-detached
  with:
    files: '*.tar.gz'
    sig_ext: asc
    workspace_dir: ${{ github.workspace }}/dist
```

## Example: sign with explicit key and passphrase

```yaml
- name: Sign artifacts with explicit key
  uses: ./gpg-sign-detached
  with:
    files: |
      app.tar.gz
      checksums.txt
    gpg_keyid: ${{ vars.GPG_KEY_ID }}
    gpg_passphrase: ${{ secrets.GPG_PASSPHRASE }}
    gpg_pass_precached: 'false'
```

## Common failures

- No matching files found for the selected `files` input.
- GPG key is missing or unusable for signing.
- Passphrase is required but incorrect/unavailable.
- `workspace_dir` does not contain the expected files.

## Quick verification

```yaml
- name: Verify detached signatures
  shell: bash
  run: |
    ls -1 dist/*.asc | cat
    gpg --verify dist/app.tar.gz.asc dist/app.tar.gz
```


