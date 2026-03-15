# aur-updpkgsums

Composite GitHub Action to run `updpkgsums` for an AUR package and refresh checksums in `PKGBUILD`.

## What this action does

- Runs inside the shared `./arch-run-cmd` environment.
- Changes into the package directory (`pkg_name`).
- Executes `updpkgsums`.
- Updates checksum entries in `PKGBUILD`.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `pkg_name` | yes | - | Package directory name to update. |
| `working_directory` | no | `${{ github.workspace || '.' }}` | Base directory where the command runs before changing into `pkg_name`. |

## Outputs

This action does not define outputs.

## Dependencies

- Nested action: `./arch-run-cmd`
- `updpkgsums` available in the Arch runtime
- Valid `PKGBUILD` in `<working_directory>/<pkg_name>`

## Operation flow

1. Start `./arch-run-cmd` with `working_directory`.
2. Run `cd "${{ inputs.pkg_name }}"`.
3. Execute `updpkgsums`.
4. Leave updated checksum lines in `PKGBUILD`.

## Examples

## Example: update checksums for one package

```yaml
- name: Update PKGBUILD checksums
  uses: ./aur-updpkgsums
  with:
    pkg_name: my-package
    working_directory: ${{ github.workspace }}/pkgbuilds
```

## Common failures

- Package directory does not exist under `working_directory`.
- `PKGBUILD` is missing or malformed.
- `updpkgsums` fails because source URLs are unreachable.

## Quick verification

```yaml
- name: Verify PKGBUILD changed
  shell: bash
  run: |
    git --no-pager diff -- pkgbuilds/my-package/PKGBUILD | cat
```

