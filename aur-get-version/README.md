# aur-get-version

Composite GitHub Action to extract the version metadata from a given PKGBUILD file.

## What this action does

- Reads the specified PKGBUILD file.
- Extracts the `pkgver` and optionally `pkgrel` values.
- Outputs the version string for use in workflows.

## Inputs

| Input           | Required | Default | Description                        |
|-----------------|----------|---------|------------------------------------|
| `pkgbuild_path` | yes      | -       | Path to the PKGBUILD file.         |

## Outputs

| Output    | Description                        |
|-----------|------------------------------------|
| `version` | The extracted version string.       |

## Dependencies

- `bash`
- `awk` or `grep` (for parsing PKGBUILD)

## Operation flow

1. Read the PKGBUILD file at `pkgbuild_path`.
2. Parse and extract `pkgver` and `pkgrel`.
3. Output the version string (e.g., `1.2.3-1`).

## Examples

### Example: extract version from PKGBUILD

```yaml
- name: Get package version
  id: getver
  uses: ./aur-get-version
  with:
    pkgbuild_path: ./PKGBUILD
```

## Common failures

- `pkgbuild_path` does not exist or is not readable.
- PKGBUILD is malformed or missing `pkgver`.

## Quick verification

```yaml
- name: Print version
  run: echo "${{ steps.getver.outputs.version }}"
```
