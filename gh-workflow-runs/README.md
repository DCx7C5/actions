# gh-workflow-delete

Composite GitHub Action to delete GitHub Actions workflow runs by status using the GitHub CLI.

## What this action does

- Accepts one or more workflow run statuses as newline-separated input.
- Lists workflow runs for each status via `gh run list`.
- Deletes each matching run via `gh run delete`.
- Exposes `deleted=true` when at least one run was deleted.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `workflow_status` | yes | - | Newline-separated statuses to delete (for example `failure`, `cancelled`). |

## Outputs

| Output | Description |
|---|---|
| `deleted` | `true` if at least one workflow run was deleted, otherwise `false`. |

## Dependencies

- `bash`
- `gh` (GitHub CLI)
- Repository token available as `${{ github.token }}` (mapped to `GH_TOKEN`)

## Operation flow

1. Initialize `deleted=false`.
2. Read `workflow_status` line by line.
3. Trim whitespace and skip empty lines.
4. For each status, fetch run IDs with:
   - `gh run list --status <status> --json databaseId --jq '.[].databaseId'`
5. Delete each returned run ID with `gh run delete <id>`.
6. Set output `deleted` to `true` when at least one run ID was processed.

## Examples

## Example: delete cancelled runs

```yaml
- name: Delete cancelled workflow runs
  id: cleanup_cancelled
  uses: ./gh-workflow-runs
  with:
    workflow_status: |
      cancelled
```

## Example: delete failed and cancelled runs

```yaml
- name: Delete failed and cancelled workflow runs
  id: cleanup_runs
  uses: ./gh-workflow-runs
  with:
    workflow_status: |
      failure
      cancelled

- name: Print result
  run: echo "deleted=${{ steps.cleanup_runs.outputs.deleted }}"
```

## Common failures

- `gh` is not available on the runner.
- Token permissions are insufficient to delete workflow runs.
- Invalid or unsupported status value is passed to `gh run list`.
- API/network errors interrupt listing or deletion.

## Quick verification

```yaml
- name: Verify no cancelled runs remain
  shell: bash
  env:
    GH_TOKEN: ${{ github.token }}
  run: gh run list --status cancelled --limit 5 | cat
```

