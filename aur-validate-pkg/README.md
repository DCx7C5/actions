# aur-validate-pkg

Composite GitHub Action to validate an AUR package with `namcap` and `makepkg --verifysource` inside the shared Arch container action.

## What this action does

- Runs validation through `./arch-run-cmd`.
- Changes into the target package directory (`pkg_name`).
- Optionally runs `namcap PKGBUILD`.
- Optionally runs `makepkg --verifysource`.
- Fails fast on validation errors and emits notices on success.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `pkg_name` | yes | - | Name of the package directory containing `PKGBUILD`. |
| `working_directory` | no | `${{ github.workspace || '.' }}` | Base directory where the package folder is located. |
| `run_namcap` | no | `true` | Run `namcap PKGBUILD` check. |
| `verify_sources` | no | `true` | Run `makepkg --verifysource` source checksum validation. |

## Outputs

This action does not define outputs.

## Dependencies

- Nested action: `./arch-run-cmd`
- `namcap` available in the nested Arch environment (when `run_namcap` is `true`)
- `makepkg` available in the nested Arch environment (when `verify_sources` is `true`)
- Valid `PKGBUILD` in `<working_directory>/<pkg_name>`

## Operation flow

1. Start `./arch-run-cmd` in `working_directory`.
2. Change directory to `pkg_name`.
3. If `run_namcap == 'true'`, execute `namcap PKGBUILD`.
4. If `verify_sources == 'true'`, execute `makepkg --verifysource --noconfirm --noprogressbar`.
5. Emit success notice when all enabled checks pass.

## Examples

## Example: run full validation

```yaml
- name: Validate package
  uses: ./aur-validate-pkg
  with:
    pkg_name: my-package
    working_directory: ${{ github.workspace }}/pkgbuilds
    run_namcap: 'true'
    verify_sources: 'true'
```

## Example: run only source verification

```yaml
- name: Validate sources only
  uses: ./aur-validate-pkg
  with:
    pkg_name: my-package
    working_directory: ${{ github.workspace }}/pkgbuilds
    run_namcap: 'false'
    verify_sources: 'true'
```

## Common failures

- `pkg_name` directory does not exist under `working_directory`.
- `PKGBUILD` is missing or invalid.
- `namcap` reports policy or packaging issues.
- `makepkg --verifysource` fails due to checksum/source mismatch or unreachable sources.

## Quick verification

```yaml
- name: Validate package path before action
  shell: bash
  run: |
    test -d "${{ github.workspace }}/pkgbuilds/my-package"
    test -f "${{ github.workspace }}/pkgbuilds/my-package/PKGBUILD"
```

