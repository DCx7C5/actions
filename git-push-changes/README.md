# git-push-changes

Composite GitHub Action to push local Git changes to a GitHub repository with optional token-based HTTPS authentication.

## What this action does

- Resolves push target from `repository`, `ref`, and `branch` inputs.
- Uses a token-authenticated HTTPS remote URL when `github_token` is provided.
- Falls back to pushing to `origin` when no token is available.
- Handles `ref: HEAD` by pushing to `branch` (or auto-detected current branch).
- Fails early for detached HEAD when `ref` is `HEAD`.

## Inputs

| Input          | Required | Default                    | Description                                                                         |
|----------------|----------|----------------------------|-------------------------------------------------------------------------------------|
| `repository`   | no       | `${{ github.repository }}` | Target repository in `owner/repo` format.                                           |
| `branch`       | no       | `${{ github.ref_name }}`   | Branch target used when `ref` is `HEAD`.                                            |
| `ref`          | no       | `HEAD`                     | Git ref/refspec to push. `HEAD` triggers auto current-branch push.                  |
| `github_token` | no       | `''`                       | Token for authenticated HTTPS push. Falls back to `env.GH_TOKEN` or `github.token`. |

## Outputs

This action does not define outputs.

## Dependencies

- `bash`
- `git`
- Write access to target repository/branch
- Valid auth method (token or preconfigured remote credentials)

## Operation flow

1. Resolve auth context from `github_token` (or fallback token sources).
2. If token exists, mask it and build HTTPS remote URL:
   - `https://x-access-token:<token>@github.com/<repository>.git`
3. If no token exists, use `origin` as push target.
4. If `ref == HEAD`, resolve target branch:
   - use `branch` input when set,
   - otherwise auto-detect current branch.
5. Push with `HEAD:refs/heads/<target_branch>`.
6. If no valid target branch can be resolved (detached HEAD + no branch input), fail with error.
7. If `ref != HEAD`, push provided ref/refspec as-is.

## Examples

## Example: push current branch to current repository

```yaml
- name: Push changes
  uses: ./git-push-changes
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Example: push explicit refspec

```yaml
- name: Push explicit refspec
  uses: ./git-push-changes
  with:
    repository: owner/target-repo
    ref: HEAD:refs/heads/main
    github_token: ${{ secrets.PAT_PUSH }}
```

## Common failures

- Runner is in detached HEAD and `ref` is left as `HEAD`.
- Token is missing or lacks push permission for the target repository.
- Branch protection or required checks prevent push.
- `repository` value is invalid or points to inaccessible repository.

## Quick verification

```yaml
- name: Verify branch and remote before push
  shell: bash
  run: |
    git rev-parse --abbrev-ref HEAD
    git remote -v | cat
```


