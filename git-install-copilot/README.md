# git-install-copilot

Composite GitHub Action to install the GitHub Copilot CLI binary from GitHub Releases.

## What this action does

- Masks provided GitHub token in logs.
- Detects current platform and architecture.
- Queries release metadata for requested version (`latest` or explicit tag).
- Downloads matching Copilot CLI binary and marks it executable.
- Optionally attempts `gh` authentication with provided token.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `version` | no | `latest` | Copilot CLI version to install (`latest` or release tag). |
| `install_path` | no | `/usr/local/bin/copilot` | Destination path for installed executable. |
| `github_token` | no | `${{ github.token }}` | Token used for GitHub API calls and optional `gh` auth step. |

## Outputs

This action does not define outputs.

## Dependencies

- `bash`
- `curl`
- `jq`
- optional `gh` CLI (for final auth step)
- write permission to directory containing `install_path`

## Operation flow

1. Mask token if present.
2. Resolve OS/architecture via `uname`.
3. Build GitHub API URL for `latest` or a specific release tag.
4. Fetch release JSON and select matching asset URL.
5. Download binary to `install_path` and `chmod +x` it.
6. If token is non-empty, run `gh auth login --with-token` step.

## Examples

## Example: install latest Copilot CLI

```yaml
- name: Install Copilot CLI
  uses: ./git-install-copilot
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Example: install specific release tag

```yaml
- name: Install Copilot CLI v1.0.0
  uses: ./git-install-copilot
  with:
    version: v1.0.0
    install_path: /usr/local/bin/copilot
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Common failures

- No compatible release asset exists for current platform/architecture.
- `jq` is not installed, so release parsing fails.
- Token is missing/invalid and API requests are rate-limited or unauthorized.
- Runner cannot write to `install_path`.

## Quick verification

```yaml
- name: Verify Copilot CLI installation
  shell: bash
  run: |
    /usr/local/bin/copilot --version
    command -v copilot || true
```

