# git-configure-gnupg

[![Test GPG Import](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml)

> Composite GitHub Action to discover a signing key in `GNUPGHOME` and configure `git`/`gh` for GPG-signed commits and tags.

## What this action does

- Optionally masks provided key input.
- Detects the selected or default secret GPG key.
- Extracts fingerprint, identity name/email, and keygrips.
- Configures global Git signing settings with a loopback GPG wrapper.
- Optionally sets `gh` git protocol to HTTPS when `gh` is available.

## Inputs

| Input      | Required | Default | Description                                                                  |
|------------|----------|---------|------------------------------------------------------------------------------|
| `key-id`   | no       | `''`    | Key ID or fingerprint to use. If empty, first secret key in keyring is used. |
| `gpg-home` | no       | `''`    | Path to `GNUPGHOME`. Falls back to existing `GNUPGHOME` environment.         |
| `gpg-name` | no       | `''`    | Name for Git commit author (auto-detected from key UID if empty).            |
| `gpg-mail` | no       | `''`    | Email for Git commit author (auto-detected from key UID if empty).           |
| `gh-token` | no       | `''`    | GitHub token for optional `gh` client config usage.                          |

## Outputs

| Output        | Description                                                          |
|---------------|----------------------------------------------------------------------|
| `fingerprint` | Fingerprint of key chosen for signing.                               |
| `name`        | Parsed display name from key UID (fallback: `GitHub Actions`).       |
| `email`       | Parsed email from key UID (fallback: `actions@github.com`).          |
| `key_grips`   | Newline-separated keygrips from selected (or available) secret keys. |

## Dependencies

- `bash`
- `gpg`
- `git`
- optional `gh` CLI
- secret key material in `GNUPGHOME`

## Operation flow

1. Mask sensitive input values when `key_id` is provided.
2. Parse key material from `GNUPGHOME` (`inputs.gpg_home` or env fallback).
3. Resolve key fingerprint (provided key or default secret key).
4. Extract UID-derived name/email and keygrips.
5. If secret keys exist, create loopback wrapper and configure global Git signing options.

## Examples

### Configure with default secret key

```yaml
- name: Configure git signing
  id: gpgcfg
  uses: ./git-configure-gnupg
  with:
    gpg-home: ${{ github.workspace }}/.gnupg
```

### Configure with explicit key

```yaml
- name: Configure git signing with selected key
  id: gpgcfg
  uses: ./git-configure-gnupg
  with:
    key-id: ${{ vars.GPG_KEY_ID }}
    gpg-home: ${{ github.workspace }}/.gnupg
    gh-token: ${{ secrets.GITHUB_TOKEN }}
```

## Common failures

- No secret key is available in `GNUPGHOME` when an explicit `key-id` is requested.
- Provided `key-id` cannot be found in the keyring.
- `GNUPGHOME` points to wrong location or has missing permissions.
- `gpg` or `git` is not available on the runner.

## Quick verification

```yaml
- name: Verify git signing config
  shell: bash
  run: |
    git config --global --get user.signingkey
    git config --global --get commit.gpgsign
    gpg --with-colons --list-secret-keys | cat
```
