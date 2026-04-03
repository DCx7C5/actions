# gpg-setup-home

[![Test GPG Import](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml)

> Composite GitHub Action to create and harden a GnuPG home directory for CI usage.

## What this action does

1. Resolves `GNUPGHOME` from `inputs.gpg-home` or existing environment.
2. Creates a temporary GPG home under the workspace if none is provided.
3. Applies secure directory permissions.
4. Writes hardened `gpg.conf` defaults.
5. Writes `gpg-agent.conf` for non-interactive usage and restarts agent.
6. Exposes the final home path as output and `GITHUB_ENV`.

## Inputs

| Input      | Required | Default | Description                                                             |
|------------|----------|---------|-------------------------------------------------------------------------|
| `gpg-home` | no       | `''`    | Path to GPG home directory. If empty, a temporary directory is created. |

## Outputs

| Output     | Description                                                   |
|------------|---------------------------------------------------------------|
| `gpg_home` | Effective GPG home directory path created/used by the action. |

## Environment variables

- Reads `GNUPGHOME` (if set in environment and `gpg-home` is empty).
- Writes `GNUPGHOME` to `$GITHUB_ENV` for subsequent steps.

## Notes

- Directory permissions are set to `700`.
- `gpg.conf` and `gpg-agent.conf` are written with restrictive permissions (`600`).
- The action is intended to run before key import/signing steps.

## Example

```yaml
- name: Setup isolated GPG home
  id: gpg_setup
  uses: ./gpg-setup-home

- name: Show resulting GPG home
  run: echo "GNUPGHOME=${{ steps.gpg_setup.outputs.gpg_home }}"
```

## Common failures

- GPG tooling missing on runner: `gpg` or `gpgconf` commands fail.
- Permission issues in workspace: cannot create or chmod target directory.

## Quick verification

```yaml
- name: Verify GPG home setup
  shell: bash
  run: |
    test -d "${{ steps.gpg_setup.outputs.gpg_home }}"
    test -f "${{ steps.gpg_setup.outputs.gpg_home }}/gpg.conf"
    test -f "${{ steps.gpg_setup.outputs.gpg_home }}/gpg-agent.conf"
```

