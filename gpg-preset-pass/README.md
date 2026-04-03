# gpg-preset-pass

[![Test GPG Import](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml)

> Composite GitHub Action to preset (or forget) GPG passphrases in `gpg-agent` cache for non-interactive CI steps.

## What this action does

1. Optionally masks sensitive inputs.
2. Resolves keygrips from all secret keys, from a specific key id, or from an explicit keygrip.
3. Calls `gpg-preset-passphrase --preset` for each keygrip (passphrase piped via stdin).
4. Or, when `forget: 'true'`, clears cached passphrases with `--forget`.

## Inputs

| Input      | Required | Default | Description                                                 |
|------------|----------|---------|-------------------------------------------------------------|
| `key-id`   | no       | `''`    | Key ID or fingerprint to scope keygrip discovery.           |
| `pass`     | **yes**  | –       | Passphrase to cache in `gpg-agent`.                         |
| `grip`     | no       | `''`    | Explicit keygrip to target.                                 |
| `gpg-home` | no       | `''`    | GPG home path (fallback to existing `GNUPGHOME`).           |
| `forget`   | no       | `''`    | If `true`, remove cached passphrases instead of presetting. |

## Outputs

This action currently does not define outputs.

## Environment variables

- Uses `GNUPGHOME` from `inputs.gpg-home` or inherited environment.
- Requires access to the `gpg-agent` socket for the selected home.

## Dependencies

- `gpg`
- `/usr/lib/gnupg/gpg-preset-passphrase`

## Example: preset passphrase

```yaml
- name: Pre-cache passphrase
  uses: ./gpg-preset-pass
  with:
    pass: ${{ secrets.GPG_PASSPHRASE }}
    key-id: ${{ vars.GPG_KEY_ID }}
    gpg-home: ${{ steps.gpg_setup.outputs.gpg_home }}
```

## Example: forget cached passphrases

```yaml
- name: Forget cached passphrases
  uses: ./gpg-preset-pass
  with:
    forget: 'true'
    gpg-home: ${{ steps.gpg_setup.outputs.gpg_home }}
    pass: dummy
```

## Common failures

- `gpg-preset-passphrase` binary not present at `/usr/lib/gnupg/gpg-preset-passphrase`.
- No secret keys in selected `GNUPGHOME`, resulting in empty keygrip list.
- Agent permissions/socket issues prevent preset/forget operations.
- `gpg-agent.conf` missing `allow-preset-passphrase` directive.

## Quick verification

```yaml
- name: Verify gpg-agent cache is reachable
  shell: bash
  run: |
    gpg-connect-agent /bye
```
