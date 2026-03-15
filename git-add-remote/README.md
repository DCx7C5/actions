# git-add-remote

Composite GitHub Action to add a Git remote in the current repository workspace.

## What this action does

- Reads remote name and URL from inputs.
- Checks whether a remote with the same name already exists.
- Adds the remote when missing.
- Returns success without changes when remote already exists.

## Inputs

| Input         | Required | Default    | Description                   |
|---------------|----------|------------|-------------------------------|
| `remote_url`  | yes      | -          | Remote repository URL to add. |
| `remote_name` | no       | `upstream` | Name of the remote to create. |

## Outputs

This action does not define outputs.

## Dependencies

- `bash`
- `git`
- valid Git repository in current working directory

## Operation flow

1. Read `remote_name` and `remote_url` from inputs.
2. Check existing remotes via `git remote`.
3. If remote exists, emit warning and exit successfully.
4. If missing, execute `git remote add <name> <url>`.
5. Emit notice confirming added remote.

## Examples

## Example: add upstream remote

```yaml
- name: Add upstream remote
  uses: ./git-add-remote
  with:
    remote_name: upstream
    remote_url: https://github.com/example/upstream-repo.git
```

## Example: add mirror remote

```yaml
- name: Add mirror remote
  uses: ./git-add-remote
  with:
    remote_name: mirror
    remote_url: git@github.com:example/mirror-repo.git
```

## Common failures

- Current directory is not a Git repository.
- `remote_url` is invalid or malformed.
- Insufficient permissions to update local Git config.

## Quick verification

```yaml
- name: Verify configured remotes
  shell: bash
  run: git remote -v | cat
```

