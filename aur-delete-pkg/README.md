# aur-delete-pkg

Composite GitHub Action to remove a package directory and its entry from `.ci/packages.json`.

## What this action does

- Deletes the package directory with `rm -rf`.
- Removes the package entry from `.ci/packages.json` via `./json-packages`.
- Optionally stages deleted files and JSON changes via `./git-stage-changes`.
- Exposes whether staging happened and which files were staged.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `pkg_name` | yes | - | Package directory/name to delete. |
| `stage_changes` | no | `true` | If `true`, stages deletion changes after removal. |
| `packages_json_path` | no | `${{ github.workspace }}/.ci/packages.json` | Path to the package metadata file that should be updated. |

## Outputs

| Output | Description |
|---|---|
| `changed` | `true` when deletion produced changes (staged changes if staging is enabled, otherwise unstaged workspace changes). |
| `staged_files` | Newline-separated staged file list when staging is enabled; empty when `stage_changes` is `false`. |

## Dependencies

- `bash`
- `rm`
- `git`
- Nested actions: `./json-packages`, `./git-stage-changes`

## Operation flow

1. Validate `pkg_name` is non-empty.
2. Delete package directory with `rm -rf -- <pkg_name>`.
3. Remove package metadata from `packages_json_path`.
4. If `stage_changes` is `true`, stage `<pkg_name>` and `packages_json_path`.
5. Finalize outputs so `changed` is still meaningful when staging is disabled.

## Examples

## Example: delete package and stage changes

```yaml
- name: Delete package
  id: del
  uses: ./aur-delete-pkg
  with:
    pkg_name: old-package
    stage_changes: 'true'

- name: Show staged files
  run: echo "${{ steps.del.outputs.staged_files }}"
```

## Example: delete without staging

```yaml
- name: Delete package without staging
  uses: ./aur-delete-pkg
  with:
    pkg_name: temp-package
    stage_changes: 'false'
```

## Example: use custom packages.json location

```yaml
- name: Delete package with custom metadata path
  uses: ./aur-delete-pkg
  with:
    pkg_name: old-package
    packages_json_path: ${{ github.workspace }}/config/packages.json
```

## Common failures

- `pkg_name` is empty.
- `packages_json_path` does not exist or is invalid JSON.
- Token/permissions are insufficient for later commit/push steps in your workflow.

## Known caveats

- `staged_files` is intentionally empty when `stage_changes` is `false` because no staging step runs.

## Quick verification

```yaml
- name: Verify deletion results
  shell: bash
  run: |
    test ! -d "${{ github.workspace }}/old-package"
    jq -e 'has("old-package") | not' "${{ github.workspace }}/.ci/packages.json"
```

