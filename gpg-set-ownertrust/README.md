# gpg-set-ownertrust

[![Test GPG Import](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml)

> Composite GitHub Action to set ownertrust level for an imported GPG key.

## What this action does

- Validates required trust inputs.
- Resolves `GNUPGHOME` from input or environment.
- Sets trust level via `gpg --import-ownertrust`.

## Inputs

| Input         | Required | Default | Description                                                                             |
|---------------|----------|---------|-----------------------------------------------------------------------------------------|
| `fingerprint` | **yes**  | –       | Fingerprint of the GPG key to update trust for.                                         |
| `trust-level` | no       | `6`     | Trust level value (`1`–`5`, or `6` = ultimate).                                         |
| `gpg-home`    | no       | `''`    | Path to `GNUPGHOME`; falls back to `env.GNUPGHOME` or `${{ github.workspace }}/.gnupg`. |

## Outputs

This action does not define outputs.

## Dependencies

- `bash`
- `gpg`
- Key with matching `fingerprint` already present in keyring

## Example

```yaml
- name: Set ownertrust
  uses: ./gpg-set-ownertrust
  with:
    fingerprint: ABCDEF1234567890ABCDEF1234567890ABCDEF12
    trust-level: '6'
    gpg-home: ${{ github.workspace }}/.gnupg
```

## Common failures

- Fingerprint does not exist in current keyring.
- `GNUPGHOME` points to wrong/missing key directory.
- Invalid trust level value for current GPG version.
- `gpg` is not available on runner.

## Quick verification

```yaml
- name: Verify ownertrust entry
  shell: bash
  env:
    GNUPGHOME: ${{ github.workspace }}/.gnupg
  run: gpg --export-ownertrust | grep -F "ABCDEF1234567890ABCDEF1234567890ABCDEF12" | cat
```
