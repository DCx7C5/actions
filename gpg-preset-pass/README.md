# gpg-preset-pass

Composite GitHub Action to preset (or forget) GPG passphrases in `gpg-agent` cache for non-interactive CI steps.

## What this action does

1. Optionally masks sensitive inputs.
2. Resolves keygrips from all secret keys, from a specific key id, or from an explicit keygrip.
3. Calls `gpg-preset-passphrase --preset` for each keygrip.
4. Or, when `forget: 'true'`, clears cached passphrases with `--forget`.

## Inputs

| Input      | Required | Default | Description                                                 |
|------------|----------|---------|-------------------------------------------------------------|
| `key_id`   | no       | `''`    | Key ID or fingerprint to scope keygrip discovery.           |
| `pass`     | yes      | -       | Passphrase to cache in `gpg-agent`.                         |
| `grp`      | no       | `''`    | Explicit keygrip to target.                                 |
| `gpg_home` | no       | `''`    | GPG home path (fallback to existing `GNUPGHOME`).           |
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
    key_id: ${{ vars.GPG_KEY_ID }}
    gpg_home: ${{ steps.gpg_setup.outputs.gpg_home }}
```

## Example: forget cached passphrases

```yaml
- name: Forget cached passphrases
  uses: ./gpg-preset-pass
  with:
    forget: 'true'
    gpg_home: ${{ steps.gpg_setup.outputs.gpg_home }}
    pass: dummy
```

## Common failures

- `gpg-preset-passphrase` binary not present at `/usr/lib/gnupg/gpg-preset-passphrase`.
- No secret keys in selected `GNUPGHOME`, resulting in empty keygrip list.
- Agent permissions/socket issues prevent preset/forget operations.

## Known caveat

The current implementation references `inputs.gpg_pass` and `inputs.gpg_grp` internally, while declared inputs are `pass` and `grp`. This can affect masking and keygrip selection behavior until aligned in the action code.

## Quick verification

```yaml
- name: Verify gpg-agent cache is reachable
  shell: bash
  run: |
    gpg-connect-agent /bye
```

