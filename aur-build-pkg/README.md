# aur-build-pkg

Composite GitHub Action to build an Arch/AUR package via `makepkg` inside the shared `./arch-run-cmd` environment.

## What this action does

- Delegates package build execution to `./arch-run-cmd`.
- Enables `ccache` and passphrase preset flow in the nested action.
- Builds package artifacts with `makepkg`.
- Optionally attempts GPG signing when signing-related inputs are set.

## Inputs

| Input             | Required | Default | Description                                                               |
|-------------------|----------|---------|---------------------------------------------------------------------------|
| `pkg_name`        | yes      | -       | Package name/directory to build.                                          |
| `gpg_sign`        | no       | `false` | Whether package signing should be enabled.                                |
| `gpg_key_id`      | no       | `''`    | GPG key ID/fingerprint for signing.                                       |
| `gpg_passhphrase` | no       | `''`    | Passphrase for the GPG key (note current input spelling).                 |
| `gpg_home`        | no       | `''`    | Path to `GNUPGHOME`; falls back to `env.GNUPGHOME` in nested action call. |
| `github_token`    | no       | `''`    | Token forwarded to nested action (`github.token` fallback).               |

## Outputs

This action does not define outputs.

## Dependencies

- Nested action: `./arch-run-cmd`
- `makepkg` toolchain available in the Arch runtime
- Valid `PKGBUILD` in the active working directory of the nested run
- Optional GPG key material for signed builds

## Operation flow

1. Call `./arch-run-cmd` with ccache enabled and passphrase preset enabled.
2. Forward selected GPG/token inputs to the nested action.
3. Validate package directory and change into `pkg_name`.
4. In the nested run script:
   - if `gpg_sign == 'true'` and `gpg_key_id` is set, run `makepkg -sr --sign -C -c --noconfirm --noprogressbar`
   - otherwise run `makepkg -sr -C -c --noconfirm --noprogressbar`
5. Emit notice that package build completed.

## Examples

## Example: standard unsigned package build

```yaml
- name: Build package
  uses: ./aur-build-pkg
  with:
    pkg_name: my-package
    gpg_sign: 'false'
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Example: attempt signed package build

```yaml
- name: Build and sign package
  uses: ./aur-build-pkg
  with:
    pkg_name: my-package
    gpg_sign: 'true'
    gpg_key_id: ${{ vars.GPG_KEY_ID }}
    gpg_passhphrase: ${{ secrets.GPG_PASSPHRASE }}
    gpg_home: ${{ github.workspace }}/.gnupg
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Common failures

- `PKGBUILD` is missing in the effective working directory.
- Build dependencies are not resolvable by `makepkg`.
- Signing requested but key/passphrase/agent setup is not usable.
- Nested `arch-run-cmd` setup fails (tooling, auth, or environment issues).

## Quick verification

```yaml
- name: Verify package artifacts
  shell: bash
  run: |
    ls -lh . | cat
    ls -1 *.pkg.tar.* | cat
```


