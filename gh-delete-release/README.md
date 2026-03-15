# gh-delete-release

Composite GitHub Action to delete a GitHub release by tag, with optional Git tag deletion.

## What this action does

- Looks up the release by `release_tag` using GitHub CLI.
- Deletes the release when found.
- Returns `deleted=false` when no release exists for the tag.
- Optionally tries to delete the corresponding Git tag locally and on `origin`.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `release_tag` | yes | - | Release tag/version to delete. |
| `github_token` | no | `${{ github.token }}` | Token used by GitHub CLI (`gh`) for release operations. |
| `delete_tag` | no | `false` | If `true`, run additional local/remote Git tag deletion logic. |

## Outputs

| Output | Description |
|---|---|
| `deleted` | `true` if release deletion succeeded, `false` when release was not found. |
| `release_id` | ID of deleted release when found; empty otherwise. |

## Dependencies

- `bash`
- `gh` (GitHub CLI)
- `git` (required when `delete_tag` is `true`)
- Authenticated token with release deletion permissions

## Operation flow

1. Validate `release_tag` is non-empty.
2. Resolve release ID via `gh release view <tag>`.
3. If release exists, run `gh release delete <tag> --yes` and export outputs.
4. If release does not exist, set `deleted=false` and continue successfully.
5. If `delete_tag == 'true'`, run local tag deletion and best-effort remote deletion (`git push origin --delete <tag>`).

## Examples

## Example: delete release only

```yaml
- name: Delete release
  id: del_release
  uses: ./gh-delete-release
  with:
    release_tag: v1.2.3
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Example: delete release and tag

```yaml
- name: Delete release and tag
  id: del_release_tag
  uses: ./gh-delete-release
  with:
    release_tag: v1.2.3
    delete_tag: 'true'
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Common failures

- Token does not have permission to delete releases.
- `gh` is missing or not authenticated on runner.
- Local Git repository context is unavailable when `delete_tag` is enabled.
- Remote tag deletion fails because remote does not exist or permissions are insufficient.

## Quick verification

```yaml
- name: Verify release is gone
  shell: bash
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: gh release view v1.2.3 >/dev/null 2>&1 && exit 1 || echo "release removed"
```


