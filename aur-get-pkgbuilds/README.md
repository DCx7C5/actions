# aur-get-pkgbuilds

Composite GitHub Action to fetch and prepare PKGBUILD sources from an upstream repository for further processing.

## What this action does

- Clones or fetches the specified upstream repository.
- Copies or links PKGBUILD directories into a target directory.
- Optionally filters or validates the PKGBUILD files.

## Inputs

| Input         | Required | Default | Description                                 |
|---------------|----------|---------|---------------------------------------------|
| `repo_url`    | yes      | -       | URL of the upstream repository to fetch.    |
| `target_dir`  | yes      | -       | Directory where PKGBUILDs are placed.       |
| `branch`      | no       | `main`  | Branch or ref to fetch from upstream.       |

## Outputs

| Output      | Description                        |
|-------------|------------------------------------|
| `success`   | `true` if PKGBUILDs were prepared.  |
| `count`     | Number of PKGBUILD directories.     |

## Dependencies

- `git`
- `bash`

## Operation flow

1. Clone or fetch the upstream repository from `repo_url`.
2. Checkout the specified `branch` (if provided).
3. Copy or link all PKGBUILD directories to `target_dir`.
4. Optionally validate PKGBUILD files.
5. Set outputs for success and count.

## Examples

### Example: fetch PKGBUILDs from upstream

```yaml
- name: Fetch PKGBUILDs
  uses: ./aur-get-pkgbuilds
  with:
    repo_url: https://example.com/repo.git
    target_dir: ./pkgbuilds
    branch: main
```

## Common failures

- `repo_url` is invalid or unreachable.
- `target_dir` is not writable.
- No PKGBUILD files found in upstream.

## Quick verification

```yaml
- name: Verify PKGBUILDs
  shell: bash
  run: |
    ls -1 ./pkgbuilds | grep PKGBUILD
```
