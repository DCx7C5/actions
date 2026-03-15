# aur-build-repodb

Composite GitHub Action to build an Arch repository database with `repo-add`, with optional GPG signing via a dedicated signed path.

## What this action does

- Masks the provided GPG passphrase in workflow logs.
- Runs database creation through `./arch-run-cmd` in the selected working directory.
- Uses an unsigned build step when `gpg_sign != 'true'`.
- Uses a signed build step when `gpg_sign == 'true'` and `gpg_key_id` is set.

## Inputs

| Input               | Required | Default                   | Description                                                                          |
|---------------------|----------|---------------------------|--------------------------------------------------------------------------------------|
| `database_name`     | yes      | -                         | Repository database base name (for example `dystopian`).                             |
| `gpg_sign`          | no       | `false`                   | If `true`, enables the signed build path (requires `gpg_key_id`).                    |
| `gpg_key_id`        | no       | `''`                      | GPG key ID used for signing mode.                                                    |
| `gpg_passphrase`    | no       | `''`                      | Passphrase for signing key (forwarded to nested action signing input).               |
| `github_token`      | no       | `''`                      | Token used by nested `arch-run-cmd`. Falls back to `env.GH_TOKEN` or `github.token`. |
| `working_directory` | no       | `${{ github.workspace }}` | Directory where `repo-add` is executed.                                              |

## Outputs

This action does not define outputs.

## Dependencies

- `bash`
- `repo-add` (provided in Arch build environment)
- Package artifacts matching `*.pkg.tar.zst` in `working_directory`
- Nested action: `./arch-run-cmd`

## Operation flow

1. Mask passphrase (if provided) and emit notices about signing-related inputs.
2. Validate signing inputs: if `gpg_sign == 'true'` and `gpg_key_id` is empty, the action fails immediately.
3. If `gpg_sign != 'true'`, run unsigned mode via `./arch-run-cmd`.
4. If `gpg_sign == 'true' && gpg_key_id != ''`, run signed mode via `./arch-run-cmd`.
5. In either build branch, collect `*.pkg.tar.zst` files first and fail with a clear error when none are found.
6. Run `repo-add` with the resolved package file list and emit a success notice.

## Examples

## Example: build repository database without signing

```yaml
- name: Build repo database
  uses: ./aur-build-repodb
  with:
    database_name: dystopian
    working_directory: ${{ github.workspace }}/repo/x86_64
```

## Example: signed repository database build

```yaml
- name: Build and sign repo database
  uses: ./aur-build-repodb
  with:
    database_name: dystopian
    gpg_sign: 'true'
    gpg_key_id: ${{ vars.GPG_KEY_ID }}
    gpg_passphrase: ${{ secrets.GPG_PASSPHRASE }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
    working_directory: ${{ github.workspace }}/repo/x86_64
```

## Common failures

- No package files are available for `repo-add` in `working_directory`.
- `repo-add` command fails inside the Arch environment.
- Signed mode requested, but key material is missing/unusable in the nested Arch environment.
- Working directory path is incorrect.
- `gpg_sign: 'true'` with empty `gpg_key_id` fails validation before build starts.

## Known caveats

- Signed mode forwards passphrase to nested input `gpg_passhphrase` (note the spelling expected by `./arch-run-cmd`).

## Quick verification

```yaml
- name: Verify repository database output
  shell: bash
  run: |
    ls -lh "${{ github.workspace }}/repo/x86_64"
    test -f "${{ github.workspace }}/repo/x86_64/dystopian.db.tar.gz"
```

