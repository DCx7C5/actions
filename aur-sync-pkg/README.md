# aur-sync-pkg

Composite GitHub Action to sync package directory changes from an upstream repository into this PKGBUILDs repository.

## What this action does

- Routes to `sync-custom-pkg` when `is_custom` is `true`.
- Routes to `sync-pkg` when `is_custom` is `false`.
- Supports `add` and `update` sync modes.
- Updates `.ci/packages.json` on `add` using `./json-packages`.
- Optionally stages package and metadata changes.
- Exposes high-level `changed` / `commit_sha` outputs.

## Inputs

| Input          | Required | Default                  | Description                                                                      |
|----------------|----------|--------------------------|----------------------------------------------------------------------------------|
| `pkg_name`     | yes      | -                        | Target package name in this repository.                                          |
| `dir_name`     | no       | `${{ inputs.pkg_name }}` | Upstream source directory for custom syncs.                                      |
| `sync_type`    | yes      | -                        | Sync mode. Supported by this action path: `add`, `update`.                       |
| `is_custom`    | yes      | `false`                  | If `true`, use `./aur-sync-pkg/sync-custom-pkg`; else `./aur-sync-pkg/sync-pkg`. |
| `remote_name`  | yes      | `upstream`               | Git remote name used for upstream fetch/diff.                                    |
| `remote_ref`   | yes      | -                        | Git ref on remote to compare against (for example `main`).                       |
| `remote_repo`  | yes      | -                        | Upstream repository in `<owner/repo>` format.                                    |
| `stage_change` | no       | `true`                   | If `true`, stages package directory and `.ci/packages.json`.                     |

## Outputs

| Output       | Description                                          |
|--------------|------------------------------------------------------|
| `changed`    | Reports whether sync step detected/applied changes.  |
| `commit_sha` | Intended commit SHA output from delegated sync step. |

## Dependencies

- `bash`
- `git`
- Nested actions: `./aur-sync-pkg/sync-custom-pkg`, `./aur-sync-pkg/sync-pkg`, `./json-packages`

## Operation flow

1. Evaluate `is_custom` + `sync_type` and run exactly one sync sub-action (`sync-custom-pkg` or `sync-pkg`) for `add`/`update`.
2. If `sync_type` is `add`, append package metadata to `.ci/packages.json`.
3. If `stage_change` is `true`, stage the package directory and `.ci/packages.json`.
4. In `Finalize outputs`, forward `changed` and `commit_sha` from the selected sync step.

## Examples

## Example: sync regular package from upstream

```yaml
- name: Sync non-custom package
  id: sync_pkg
  uses: ./aur-add-pkg
  with:
    pkg_name: my-package
    sync_type: update
    is_custom: 'false'
    remote_name: upstream
    remote_ref: main
    remote_repo: owner/upstream-pkgbuilds
    stage_change: 'true'
```

## Example: sync custom package from different upstream directory

```yaml
- name: Sync custom package
  uses: ./aur-add-pkg
  with:
    pkg_name: my-custom-package
    dir_name: base-package
    sync_type: add
    is_custom: 'true'
    remote_name: upstream
    remote_ref: main
    remote_repo: owner/upstream-pkgbuilds
```

## Common failures

- `sync_type` is not `add` or `update`.
- Upstream remote/ref is missing or not fetched.
- For custom sync, upstream directory does not contain `PKGBUILD`.
- `.ci/packages.json` is missing/invalid when `sync_type: add` is used.

## Known caveats

- `commit_sha` is declared, but delegated sync actions currently only set `changed`; `commit_sha` may be empty.
- Finalize step contains a `delete` output branch (`steps.commit_delete`) that is not implemented in this action.
- `dir_name` default references another input in metadata; set it explicitly if your runner setup does not resolve that default as expected.

## Quick verification

```yaml
- name: Verify staged package changes
  shell: bash
  run: |
    git status --short
    test -d "${{ github.workspace }}/my-package"
```

