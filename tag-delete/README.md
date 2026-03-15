# tag-delete

Composite GitHub Action to delete a Git tag locally and remotely, with optional deletion of the matching GitHub release.

## What this action does

1. Optionally deletes the GitHub release associated with the tag via `gh release delete`.
2. Deletes the tag locally if it exists.
3. Attempts to delete the tag from `origin`.
4. Reports whether anything was deleted and whether the remote push succeeded.

## Inputs

| Input            | Required | Default | Description                                                  |
|------------------|----------|---------|--------------------------------------------------------------|
| `tag_name`       | yes      | -       | Tag name/version to delete.                                  |
| `delete_release` | no       | `false` | Whether to also delete the matching GitHub release via `gh`. |

## Outputs

| Output        | Description                                                         |
|---------------|---------------------------------------------------------------------|
| `deleted`     | `true` if the tag was deleted locally or remotely.                  |
| `tag_existed` | `true` if the tag existed locally before deletion.                  |
| `pushed`      | `true` if remote deletion via `git push origin --delete` succeeded. |

## Environment and dependencies

The runner must provide:

- `git`
- `gh` if `delete_release == 'true'`

For release deletion, the action uses a GitHub token from:

- `env.GITHUB_TOKEN`, or
- `github.token`

## Deletion flow

### Optional release deletion

When `delete_release == 'true'`, the action:

1. looks up the release by tag with `gh release view`
2. deletes it with `gh release delete --yes` if it exists
3. continues if no release was found

### Tag deletion

The action then:

1. checks whether the tag exists locally
2. deletes it locally if present
3. attempts `git push origin --delete <tag>`
4. returns success if either local or remote deletion happened

## Example: delete tag only

```yaml
- name: Delete tag
  id: tag_delete
  uses: ./tag-delete
  with:
    tag_name: v1.2.3
```

## Example: delete tag and matching release

```yaml
- name: Delete tag and release
  id: tag_delete
  uses: ./tag-delete
  with:
    tag_name: v1.2.3
    delete_release: 'true'
```

## Common failures

- `tag_name input is required and cannot be empty`: missing tag name.
- `Failed to delete release`: `gh` CLI failed or token/permissions were insufficient.
- `Failed to delete local tag`: local Git deletion failed.
- Remote deletion can fail if credentials are missing or the tag does not exist on `origin`.

## Known caveats

- `inputs.github_token` is referenced in the release deletion step, but no such input is declared in `action.yml`.
- Release deletion depends on `gh` being installed and authenticated.
- Remote deletion is best-effort: the action can still succeed even if remote deletion fails.
- The action always targets the `origin` remote.

## Verification

Inspect outputs in a later step:

```yaml
- name: Show delete results
  run: |
    echo "deleted=${{ steps.tag_delete.outputs.deleted }}"
    echo "tag_existed=${{ steps.tag_delete.outputs.tag_existed }}"
    echo "pushed=${{ steps.tag_delete.outputs.pushed }}"
```

