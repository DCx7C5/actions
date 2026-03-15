# upload-assets

Composite GitHub Action to upload one or more files as assets to an existing GitHub Release tag.

## What this action does

- Reads a newline-separated list of asset paths.
- Uploads each existing file to a release tag via `gh release upload`.
- Uses `--clobber` to overwrite assets with the same name.
- Skips missing files with warnings instead of failing immediately.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `release_tag` | yes | - | Tag name/version for the target release. |
| `assets` | no | `""` | Newline-separated list of file paths to upload. |
| `github_token` | no | `""` | Token for GitHub API/CLI. Falls back to `env.GITHUB_TOKEN` or `${{ github.token }}`. |

## Outputs

This action does not define outputs.

## Dependencies

- `bash`
- `gh` (GitHub CLI)
- Existing release for `release_tag`

## Operation flow

1. Read `assets` line by line.
2. Ignore empty lines.
3. For each path:
   - if file exists, upload to release using `gh release upload <tag> <file> --clobber`.
   - if file is missing, emit warning and continue.
4. Finish without failing on missing files.

## Examples

## Example: upload two artifacts

```yaml
- name: Upload release assets
  uses: ./upload-assets
  with:
    release_tag: v1.2.3
    assets: |
      dist/dystopian-linux-x86_64.tar.gz
      dist/checksums.txt
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Example: upload after release creation

```yaml
- name: Create release
  uses: ./gh-create-release
  with:
    release_tag: v1.2.3

- name: Upload debug symbols
  uses: ./upload-assets
  with:
    release_tag: v1.2.3
    assets: |
      dist/dystopian-linux-x86_64.debug
```

## Common failures

- Target release tag does not exist.
- Token does not have release write permissions.
- `gh` is missing or not authenticated on the runner.
- `assets` points to directories or unresolved glob patterns (not regular files).

## Quick verification

```yaml
- name: Verify uploaded assets
  shell: bash
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: gh release view v1.2.3 --json assets --jq '.assets[].name' | cat
```

