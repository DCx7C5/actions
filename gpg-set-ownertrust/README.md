# gpg-set-ownertrust

Composite GitHub Action to set ownertrust level for an imported GPG key.

## What this action does

- Validates required trust inputs.
- Resolves `GNUPGHOME` from input or environment.
- Runs non-interactive `gpg --edit-key` trust commands.
- Sets trust level for the given key fingerprint.

## Inputs

| Input         | Required | Default | Description                                                                             |
|---------------|----------|---------|-----------------------------------------------------------------------------------------|
| `fingerprint` | yes      | -       | Fingerprint of the GPG key to update trust for.                                         |
| `trust_level` | no       | `5`     | Trust level value passed to GPG (`5` = ultimate/owner trust in this flow).              |
| `gpg_home`    | no       | `''`    | Path to `GNUPGHOME`; falls back to `env.GNUPGHOME` or `${{ github.workspace }}/.gnupg`. |

## Outputs

This action does not define outputs.

## Dependencies

- `bash`
- `gpg`
- Key with matching `fingerprint` already present in keyring

## Operation flow

1. Validate `fingerprint` and `trust_level` are non-empty.
2. Resolve `GNUPGHOME` from `gpg_home` / environment fallback.
3. Pipe trust commands to `gpg --edit-key <fingerprint>` in batch mode.
4. Fail on GPG error; otherwise emit success notice.

## Examples

## Example: set owner trust for imported key

```yaml
- name: Set ownertrust
  uses: ./gpg-set-ownertrust
  with:
    fingerprint: ABCDEF1234567890ABCDEF1234567890ABCDEF12
    trust_level: '5'
    gpg_home: ${{ github.workspace }}/.gnupg
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

