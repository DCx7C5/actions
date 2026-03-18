# tar-create

Composite GitHub Action to create a tar archive from selected files or directories.

## What this action does

- Accepts a list of input paths (files or directories).
- Creates a tar archive at the specified output path.
- Fails if any input path does not exist.

## Inputs

| Input         | Required | Default | Description                                 |
|---------------|----------|---------|---------------------------------------------|
| `input_paths` | yes      | -       | Newline-separated list of files/directories.|
| `output`      | yes      | -       | Path to the resulting tar archive.          |

## Outputs

| Output      | Description                        |
|-------------|------------------------------------|
| `archive`   | Path to the created tar archive.    |

## Dependencies

- `bash`
- `tar`

## Operation flow

1. Validate all `input_paths` exist.
2. Run `tar -czf <output> <input_paths...>`.
3. Set output `archive` to the resulting file.

## Example

```yaml
- name: Create tar archive
  uses: ./tar-create
  with:
    input_paths: src/
    output: dist/app.tar.gz
```

## Common failures

- One or more input paths do not exist.
- Output path is not writable.
- `tar` command fails due to permission or disk issues.

## Quick verification

```yaml
- name: Verify archive exists
  shell: bash
  run: |
    test -f dist/app.tar.gz
    tar -tzf dist/app.tar.gz | head -n 5
```
