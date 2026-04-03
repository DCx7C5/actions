# arch-run-cmd

[![Test Arch Run Cmd](https://github.com/DCx7C5/actions/actions/workflows/test_arch_run_cmd.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_arch_run_cmd.yml)

> Docker-based GitHub Action to run commands inside a minimal, secure Arch Linux container with GPG & ccache support.

## What this action does

- Runs an arbitrary command/script inside an Arch Linux Docker container.
- Mounts the workspace, GPG home, and ccache directories automatically.
- Supports GPG signing, passphrase caching, and optional sudo execution.

## Inputs

| Input                     | Required | Default | Description                                                |
|---------------------------|----------|---------|------------------------------------------------------------|
| `command`                 | **yes**  | –       | Command/script to execute inside container.                |
| `working-directory`       | no       | `''`    | Working directory inside container.                        |
| `gpg-home`                | no       | `''`    | GPG home directory (auto-mounted via workspace volume).    |
| `ccache-dir`              | no       | `''`    | ccache directory for build caching.                        |
| `enable-ccache`           | no       | `true`  | Enable ccache for faster incremental builds.               |
| `gh-token`                | no       | `''`    | GitHub token for API access.                               |
| `gpg-key-id`              | no       | `''`    | GPG key ID or fingerprint for signing.                     |
| `gpg-keygrips`            | no       | `''`    | Keygrips of GPG keys to preset in gpg-agent cache.         |
| `gpg-passphrase`          | no       | `''`    | Passphrase for GPG key.                                    |
| `preset-passphrase-cache` | no       | `false` | Whether to preset GPG passphrase in gpg-agent cache.       |
| `run-with-sudo`           | no       | `false` | Whether to run the command with sudo inside the container. |

## Outputs

This action currently does not define outputs.

## Example

```yaml
- name: Run command in Arch Linux container
  uses: ./arch-run-cmd
  with:
    command: 'makepkg -s --noconfirm'
    gh-token: ${{ secrets.GITHUB_TOKEN }}
    gpg-key-id: ${{ steps.gpg.outputs.fingerprint }}
    gpg-home: ${{ steps.gpg.outputs.gpg_home }}
    run-with-sudo: 'true'
```

