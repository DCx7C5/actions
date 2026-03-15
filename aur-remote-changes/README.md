# aur-remote-changes

Composite GitHub Action to detect new, changed, and removed PKGBUILD package directories compared to a remote ref.

## What this action does

- Compares `HEAD` against `<remote_name>/<remote_ref>`.
- Detects removed package dirs from deleted `PKGBUILD` files.
- Detects new package dirs from added `PKGBUILD` files.
- Detects changed package dirs from modified `PKGBUILD` files.
- Exposes plain newline lists and GitHub-matrix JSON (`include`) outputs.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `remote_name` | no | `upstream` | Git remote name to compare against. |
| `remote_ref` | no | `main` | Git ref on remote to compare against. |
| `exclude_paths_delete` | no | `""` | Newline-separated paths to exclude from the **removed** file comparison via `:(exclude)`. |
| `exclude_paths_new` | no | `""` | Newline-separated paths to exclude from the **new** file comparison via `:(exclude)`. |
| `exclude_paths_changed` | no | `""` | Newline-separated paths to exclude from the **changed** file comparison via `:(exclude)`. |

## Outputs

| Output | Description |
|---|---|
| `has_updates` | `true` when `new_dirs` or `changed_dirs` is non-empty. |
| `has_removed` | `true` when `removed_dirs` is non-empty. |
| `new_dirs` | Newline-separated package directories with added `PKGBUILD`. |
| `new_dirs_matrix` | JSON matrix in format `{"include":[{"dir":"..."}]}` for `new_dirs`. |
| `changed_dirs` | Newline-separated package directories with modified `PKGBUILD`. |
| `changed_dirs_matrix` | JSON matrix in format `{"include":[{"dir":"..."}]}` for `changed_dirs`. |
| `removed_dirs` | Newline-separated package directories with deleted `PKGBUILD`. |
| `removed_dirs_matrix` | JSON matrix in format `{"include":[{"dir":"..."}]}` for `removed_dirs`. |

## Dependencies

- `bash`
- `git`
- `awk`, `sort`
- `jq` (for matrix JSON generation)
- A fetched remote ref at `<remote_name>/<remote_ref>`

## Operation flow

1. Build optional `exclude_args` per step from `exclude_paths_delete`, `exclude_paths_new`, and `exclude_paths_changed`.
2. Compute removed files with `git diff --diff-filter=D ...` and derive `removed_dirs`.
3. Compute new files with `git diff --diff-filter=A ...` and derive `new_dirs`.
4. Compute changed files with `git diff --diff-filter=M ...` and derive `changed_dirs`.
5. Publish plain list outputs and `{include:[{dir:...}]}` matrix outputs.

## Examples

## Example: detect upstream changes

```yaml
- name: Detect remote package changes
  id: changes
  uses: ./aur-remote-changes
  with:
    remote_name: upstream
    remote_ref: main
```

## Example: exclude paths per comparison type

```yaml
- name: Detect remote package changes
  id: changes
  uses: ./aur-remote-changes
  with:
    remote_name: upstream
    remote_ref: main
    exclude_paths_delete: |
      .ci/
      .github/
    exclude_paths_new: |
      .ci/
    exclude_paths_changed: |
      .ci/
      docs/
```

## Example: use matrix for new packages

```yaml
- name: Detect changes
  id: changes
  uses: ./aur-remote-changes

- name: Build newly added packages
  if: steps.changes.outputs.new_dirs != ''
  strategy:
    matrix: ${{ fromJson(steps.changes.outputs.new_dirs_matrix) }}
  shell: bash
  run: |
    echo "Build package dir: ${{ matrix.dir }}"
```


## Common failures

- Remote ref `<remote_name>/<remote_ref>` is not fetched or does not exist.
- Action is executed outside a Git repository.
- `jq` is missing (matrix outputs fail to generate).
- Path exclusions are malformed and filter out expected files.

## Quick verification

```yaml
- name: Print detected directories and matrices
  shell: bash
  run: |
    echo "new_dirs:"
    echo "${{ steps.changes.outputs.new_dirs }}"
    echo "changed_dirs:"
    echo "${{ steps.changes.outputs.changed_dirs }}"
    echo "removed_dirs:"
    echo "${{ steps.changes.outputs.removed_dirs }}"
    echo "new_dirs_matrix=${{ steps.changes.outputs.new_dirs_matrix }}"
    echo "changed_dirs_matrix=${{ steps.changes.outputs.changed_dirs_matrix }}"
    echo "removed_dirs_matrix=${{ steps.changes.outputs.removed_dirs_matrix }}"
```

