# git-stage-changes

Composite GitHub Action to stage Git changes with optional path filtering and untracked-file control.

## What this action does

- Validates that the current directory is a Git repository.
- Optionally stages only selected paths (newline-separated).
- Supports staging tracked-only changes or tracked+untracked changes.
- Exposes whether anything ended up staged and which files are staged.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `paths` | no | `""` | Newline-separated list of paths to stage. Empty means whole workspace. |
| `include_untracked` | no | `"true"` | `true` stages untracked files too; `false` stages tracked changes only. |

## Outputs

| Output | Description |
|---|---|
| `staged` | `true` if there are staged changes after this action, otherwise `false`. |
| `staged_files` | Newline-separated list of staged file paths (`git diff --cached --name-only`). |

## Dependencies

- `bash`
- `git`
- A valid Git repository in the current working directory

## Operation flow

1. Validate repository context with `git rev-parse --is-inside-work-tree`.
2. Validate `include_untracked` value (`true` or `false`).
3. If `paths` is provided, trim and stage only valid non-empty path entries.
4. If `paths` is empty, stage whole workspace.
5. Collect staged files and export `staged` + `staged_files` outputs.

## Examples

## Example: stage everything including untracked files

```yaml
- name: Stage all changes
  id: stage_all
  uses: ./git-stage-changes
  with:
    include_untracked: 'true'
```

## Example: stage only selected paths

```yaml
- name: Stage package and metadata
  id: stage_paths
  uses: ./git-stage-changes
  with:
    include_untracked: 'false'
    paths: |
      pkgbuilds/my-package
      .ci/packages.json
```

## Common failures

- Action runs outside a Git repository.
- `include_untracked` is not `true` or `false`.
- Provided paths are invalid for the current workspace context.

## Quick verification

```yaml
- name: Verify staged files output
  shell: bash
  run: |
    echo "staged=${{ steps.stage_paths.outputs.staged }}"
    echo "${{ steps.stage_paths.outputs.staged_files }}"
```

