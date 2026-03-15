# arch-run-cmd

Docker-based GitHub Action that runs a command inside a minimal Arch Linux container prepared for package building, GPG usage, and optional ccache reuse.

## What this action does

1. Starts a custom Arch Linux container image built from the included `Dockerfile`.
2. Exposes the GitHub workspace inside the container and switches into the selected working directory.
3. Resolves and exports `GNUPGHOME` for signing-related commands.
4. Optionally presets a GPG passphrase in `gpg-agent` before command execution.
5. Runs the requested shell command either directly or via `sudo -u builder`.
6. Performs best-effort post-run cleanup of cached GPG passphrases and temporary sensitive files.

## Inputs

| Input               | Required | Default                           | Description                                                                                       |
|---------------------|----------|-----------------------------------|---------------------------------------------------------------------------------------------------|
| `run`               | yes      | -                                 | Command or script to execute inside the container.                                                |
| `working_directory` | no       | `''`                              | Working directory inside the container. Falls back to `${{ github.workspace }}`.                  |
| `gpg_home`          | no       | `''`                              | GPG home directory, typically inside the mounted workspace.                                       |
| `ccache_dir`        | no       | `${{ github.workspace }}/.ccache` | ccache directory intended for build cache reuse.                                                  |
| `enable_ccache`     | no       | `true`                            | Declared switch for ccache support.                                                               |
| `github_token`      | no       | `''`                              | Token exposed as `GH_TOKEN` inside the container. Falls back to `env.GH_TOKEN` or `github.token`. |
| `gpg_key_id`        | no       | `''`                              | GPG key ID or fingerprint used for passphrase preset lookup.                                      |
| `gpg_passhphrase`   | no       | `''`                              | GPG passphrase used for cache preset before execution.                                            |
| `preset_cache`      | no       | `true`                            | Whether to pre-cache the GPG passphrase in `gpg-agent`.                                           |
| `run_with_sudo`     | no       | `false`                           | Run the command as `builder` via `sudo -u builder`.                                               |

## Outputs

This action currently defines no outputs.

## Environment variables inside the container

The action exports these variables through `runs.env`:

- `CI=true`
- `GITHUB_ACTIONS=true`
- `GH_TOKEN`
- `MAKEFLAGS=-j${{ runner.cpu_count }}`
- `CCACHE_DIR`
- `GNUPGHOME`
- `CCACHE_MAXSIZE=2G`
- `CCACHE_COMPRESS=1`
- `CCACHE_COMPRESSLEVEL=6`
- `DISABLE_TELEMETRY=1`
- `PYTHONDONTWRITEBYTECODE=1`
- `RUN_WITH_SUDO`

The runtime script also respects or derives:

- `PACKAGER`
- `GPGSIGN_KEY`
- `LANG`
- `TERM`
- `USER`

## Container behavior

The bundled image is assembled from the included `Dockerfile` and contains:

- Arch Linux userland bootstrapped from Alpine during image build
- `base`, `base-devel`, `git`, `gnupg`, `curl`, `mold`, `ccache`
- a non-root `builder` user
- `sudo` permissions for `builder`
- an optimized `makepkg.conf`
- a default workspace of `/github/workspace`

At runtime, `entrypoint.sh`:

- resolves the work directory from the first action argument
- resolves `GNUPGHOME` from the second argument or falls back to `<workdir>/.gnupg`
- initializes GPG if needed
- emits warnings when no keys are present in CI
- executes the requested command with `bash -c ...`

## GPG passphrase preset flow

When all of the following are true, the action attempts to preset the GPG passphrase before the main command runs:

- `GNUPGHOME` points to an existing directory
- `gpg_key_id` is non-empty
- `gpg_passhphrase` is non-empty
- `preset_cache == 'true'`

It then looks up matching keygrips and calls `gpg-preset-passphrase --preset` for each one.

## Examples

### Example: run makepkg in the current workspace

```yaml
- name: Build package in Arch container
  uses: ./arch-run-cmd
  with:
    run: makepkg -sfc --noconfirm
```

### Example: run from a specific package directory

```yaml
- name: Build package from subdirectory
  uses: ./arch-run-cmd
  with:
    working_directory: ${{ github.workspace }}/pkgbuilds/my-package
    run: makepkg -sfc --noconfirm
```

### Example: use mounted GPG home for signing

```yaml
- name: Build and sign package
  uses: ./arch-run-cmd
  with:
    working_directory: ${{ github.workspace }}/pkgbuilds/my-package
    gpg_home: ${{ github.workspace }}/.gnupg
    gpg_key_id: ${{ vars.GPG_KEY_ID }}
    gpg_passhphrase: ${{ secrets.GPG_PASSPHRASE }}
    preset_cache: 'true'
    run: makepkg -sfc --sign --noconfirm
```

### Example: run command as builder user via sudo

```yaml
- name: Run as builder
  uses: ./arch-run-cmd
  with:
    run_with_sudo: 'true'
    run: whoami && pwd
```

## Common failures

- Invalid `working_directory`: the container cannot `cd` into the requested path.
- Missing GPG key material in `GNUPGHOME`: signing commands fail even though the container starts correctly.
- `gpg-preset-passphrase` unavailable or unusable: passphrase preset is best-effort and may silently not populate cache.
- Command-specific failures from `makepkg`, `pacman`, `git`, or other tooling inside the container.

## Known caveats

- The input name is spelled `gpg_passhphrase` in `action.yml` and must be used exactly as declared.
- `enable_ccache` is declared but not directly consumed by `entrypoint.sh`; ccache-related environment is still exported.
- `entrypoint.sh` forces `CCACHE_DIR` to `<working_directory>/.ccache`, which can differ from the declared `ccache_dir` input.
- `post_entrypoint.sh` references `GPG_KEY_ID`, but that variable is not explicitly exported through `runs.env`.
- `post_entrypoint.sh` uses `shread` instead of `shred`, so that cleanup command is effectively a no-op.

## Quick verification

A minimal smoke check in a workflow can validate directory resolution and basic tools:

```yaml
- name: Verify Arch container environment
  uses: ./arch-run-cmd
  with:
    run: |
      uname -a
      pacman --version
      gpg --version
      echo "$GNUPGHOME"
```

