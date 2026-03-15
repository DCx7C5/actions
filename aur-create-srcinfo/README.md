# aur-create-srcinfo

Composite GitHub Action to generate a `.SRCINFO` file for an AUR package from its `PKGBUILD`.

## What this action does

- Runs inside the shared `./arch-run-cmd` environment.
- Changes into the package directory (`pkg_name`).
- Executes `makepkg --printsrcinfo > .SRCINFO`.
- Writes/overwrites the package `.SRCINFO` file.

## Inputs

| Input               | Required | Default               | Description                                   |
|---------------------|----------|-----------------------|-----------------------------------------------|
| `pkg_name`          | yes      | -                     | Package directory name containing `PKGBUILD`. |
| `working_directory` | no       | `${{ github.workspace |                                               | '.' }}` | Base directory where the command runs before changing into `pkg_name`. |

## Outputs

This action does not define outputs.

## Dependencies

- Nested action: `./arch-run-cmd`
- `makepkg` available in the Arch runtime
- Valid `PKGBUILD` in `<working_directory>/<pkg_name>`

## Operation flow

1. Start `./arch-run-cmd` with `working_directory`.
2. Run `cd "${{ inputs.pkg_name }}"`.
3. Execute `makepkg --printsrcinfo > .SRCINFO`.
4. Leave updated `.SRCINFO` in the package directory.

## Examples

## Example: generate `.SRCINFO` for one package

```yaml
- name: Create SRCINFO
  uses: ./aur-create-srcinfo
  with:
    pkg_name: my-package
    working_directory: ${{ github.workspace }}/pkgbuilds
```

## Common failures

- Package directory does not exist under `working_directory`.
- `PKGBUILD` is missing or invalid.
- `makepkg` command fails in the Arch environment.

## Quick verification

```yaml
- name: Verify .SRCINFO exists
  shell: bash
  run: |
    test -f "${{ github.workspace }}/pkgbuilds/my-package/.SRCINFO"
    head -n 5 "${{ github.workspace }}/pkgbuilds/my-package/.SRCINFO"
```

