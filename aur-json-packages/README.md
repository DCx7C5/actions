# aur-json-packages

[![Test JSON Packages](https://github.com/DCx7C5/actions/actions/workflows/test_json_pkgs.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_json_pkgs.yml)

> Composite GitHub Action to manage a JSON packages dictionary stored as a GitHub Variable.

## What this action does

- Supports `get`, `add`, `update`, `remove`, and `count` actions.
- Retrieves, filters, adds, updates, or removes package entries from a JSON dictionary.
- Stores the dictionary as a GitHub organization/repository/environment variable.
- Supports multi-line inputs for batch operations on multiple packages/keys/values.

## Inputs

| Input              | Required | Default         | Description                                                                        |
|--------------------|----------|-----------------|------------------------------------------------------------------------------------|
| `action`           | no       | `get`           | Operation: `get`, `add`, `update`, `remove`, `count`.                              |
| `var-name`         | no       | `JSON_PACKAGES` | Name of the GitHub Variable storing the JSON dictionary.                           |
| `pkg-name`         | no       | `''`            | Newline-separated list of package names to query or mutate.                        |
| `key`              | no       | `''`            | Newline-separated list of keys for add/update/remove/filter operations.            |
| `value`            | no       | `''`            | Newline-separated list of values for add/update operations (JSON or plain string). |
| `env`              | no       | `''`            | Target deployment environment for the variable.                                    |
| `org`              | no       | `''`            | Organization to store the variable in.                                             |
| `repo`             | no       | `''`            | Repository to store the variable in (defaults to current repository).              |
| `gh-token`         | no       | `''`            | GitHub Token with permissions to manage variables.                                 |
| `output-structure` | no       | `dict`          | Output format for `get` action: `dict` (default) or `list`.                        |

## Outputs

| Output         | Description                                                   |
|----------------|---------------------------------------------------------------|
| `out`          | Action result — JSON data for `get`, `saved` for mutations.   |
| `debug-args`   | Debug: generated jq arguments.                                |
| `debug-filter` | Debug: generated jq filter expression.                        |

## Dependencies

- `bash`
- `jq`
- `gh` CLI (for reading/writing GitHub Variables)

## Examples

### List all packages

```yaml
- name: Read packages
  id: pkgs
  uses: ./aur-json-packages
  with:
    action: get
    org: MyOrg
    gh-token: ${{ secrets.GITHUB_TOKEN }}
    var-name: JSON_PACKAGES

- name: Print result
  run: echo '${{ steps.pkgs.outputs.out }}'
```

### Add a package with keys

```yaml
- name: Add package entry
  uses: ./aur-json-packages
  with:
    action: add
    org: MyOrg
    gh-token: ${{ secrets.GITHUB_TOKEN }}
    var-name: JSON_PACKAGES
    pkg-name: my-package
    key: |
      submodule
      custom
    value: |
      false
      true
```

### Remove packages

```yaml
- name: Remove packages
  uses: ./aur-json-packages
  with:
    action: remove
    org: MyOrg
    gh-token: ${{ secrets.GITHUB_TOKEN }}
    var-name: JSON_PACKAGES
    pkg-name: |
      package-a
      package-b
```

## Common failures

- `gh` CLI not authenticated or token missing required permissions.
- Variable does not exist or contains invalid JSON.
- Invalid input combinations (`key`+`value` with unsupported `action`).
- Only one of `env`, `repo`, or `org` may be set at a time.
