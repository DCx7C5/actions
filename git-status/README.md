# git-status

Composite GitHub Action to print repository status and recent commit graph for troubleshooting/debug workflows.

## What this action does

- Changes to a configurable repository path.
- Validates that the target path is a Git repository.
- Prints short status output (`git status --short`).
- Prints a recent decorated commit graph (`git log --oneline --graph --decorate HEAD~5`).

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `workspace_path` | no | `.` | Path to the Git repository to inspect. |

## Outputs

This action does not define outputs.

## Dependencies

- `bash`
- `git`
- A valid Git repository at `workspace_path`

## Operation flow

1. Change directory to `workspace_path`.
2. Validate repository context with `git rev-parse --is-inside-work-tree`.
3. Emit a notice showing inspected path.
4. Print short status and recent commit history.

## Examples

## Example: show status for current workspace

```yaml
- name: Show git status
  uses: ./git-status
```

## Example: show status for subdirectory repository

```yaml
- name: Show git status in nested repo
  uses: ./git-status
  with:
    workspace_path: ./pkgbuilds
```

## Common failures

- `workspace_path` does not exist.
- `workspace_path` is not a Git repository.
- `HEAD~5` is not resolvable in very small or newly initialized repositories.

## Quick verification

```yaml
- name: Run and inspect logs
  uses: ./git-status
  with:
    workspace_path: .
```

