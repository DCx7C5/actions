# json-packages

Composite GitHub Action to read and mutate a `packages.json` document with `jq`.

## What this action does

- Supports `get`, `add`, `update`, and `remove` actions.
- Lists packages, fetches values for a package, filters packages by key/value.
- Adds or updates package keys.
- Removes full package entries or a specific key within a package.

## Inputs

| Input          | Required | Default                                     | Description                                               |
|----------------|----------|---------------------------------------------|-----------------------------------------------------------|
| `path`         | no       | `${{ github.workspace }}/.ci/packages.json` | Path to target JSON file.                                 |
| `action`       | no       | `get`                                       | Operation: `get`, `add`, `update`, `remove`.              |
| `package_name` | no       | `''`                                        | Package name to query or mutate.                          |
| `key`          | no       | `''`                                        | Property key used by add/update/remove/filter operations. |
| `value`        | no       | `''`                                        | Property value used by add/update or filter operations.   |

## Outputs

| Output     | Description                                               |
|------------|-----------------------------------------------------------|
| `packages` | Newline-separated package names for matching `get` paths. |
| `upstream` | `upstream` value of selected package (if any).            |
| `custom`   | `custom` value of selected package (if any).              |
| `refactor` | `refactor` value of selected package (if any).            |
| `success`  | `true` when add/update/remove step reports success.       |

## Dependencies

- `bash`
- `jq`

## Operation flow

1. Validates `action` and selected input combinations.
2. Executes one branch depending on `action` and optional selectors:
   - `get` + no `package_name`: list all package names.
   - any `package_name`: emit `upstream`, `custom`, `refactor` values.
   - `add` / `update`: write key/value into package object.
   - `remove`: remove package or specific key.
   - `get` + `key` (+ optional `value`): filter packages by property.

## Examples

## Example: list all package names

```yaml
- name: Read packages
  id: pkgs
  uses: ./json-packages
  with:
    action: get
    path: ${{ github.workspace }}/.ci/packages.json

- name: Print package list
  run: echo "${{ steps.pkgs.outputs.packages }}"
```

## Example: add package key

```yaml
- name: Add package upstream
  uses: ./json-packages
  with:
    action: add
    package_name: my-package
    key: upstream
    value: https://example.org/repo.git
```

## Example: remove key from package

```yaml
- name: Remove package key
  uses: ./json-packages
  with:
    action: remove
    package_name: my-package
    key: custom
```

## Common failures

- JSON file does not exist at `path`.
- `jq` not installed on runner.
- Invalid input combinations (`key` without `value`, unsupported `action`).

## Known caveats

- Validation step references `JSON_PATH` without defining it in that step environment.
- Validation condition expressions currently contain shell syntax issues and may not enforce combinations as intended.
- Output `custom` references `steps.custom_output.outputs.custom`, but no `custom_output` step exists; value is produced by `get_pkg_value`.
- Output `refactor` references `steps.refactored_output.outputs.refactor`, but no `refactored_output` step exists; value is produced by `get_pkg_value`.

## Quick verification

```yaml
- name: Verify packages.json is valid JSON
  shell: bash
  run: jq -e '.' "${{ github.workspace }}/.ci/packages.json" > /dev/null
```

