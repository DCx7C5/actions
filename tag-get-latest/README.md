# tag-get-latest

Composite GitHub Action to query the latest GitHub release tag for a repository and expose its `tag_name` as output.

## What this action does

1. Calls the GitHub REST API endpoint for the latest release of a repository.
2. Extracts `.tag_name` from the JSON response with `jq`.
3. Writes the result to the `tag_name` output.

## Inputs

| Input                | Required | Default                    | Description                                                        |
|----------------------|----------|----------------------------|--------------------------------------------------------------------|
| `repository`         | no       | `${{ github.repository }}` | Repository to query, e.g. `owner/name`.                            |
| `exit_if_not_found`  | no       | `false`                    | Declared switch to fail if no tag is found.                        |
| `exit_if_up_to_date` | no       | `false`                    | Declared switch to fail if the latest tag matches the current tag. |

## Outputs

| Output     | Description                                    |
|------------|------------------------------------------------|
| `tag_name` | Latest release tag returned by the GitHub API. |

## Environment and dependencies

The runner must provide:

- `bash`
- `curl`
- `jq`

The action expects:

- `GH_TOKEN` in the environment for authenticated GitHub API access

## Example

```yaml
- name: Get latest release tag
  id: tag_latest
  uses: ./tag-get-latest
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

- name: Show latest tag
  run: |
    echo "Latest tag: ${{ steps.tag_latest.outputs.tag_name }}"
```

## API behavior

The action queries:

- `https://api.github.com/repos/<repository>/releases/latest`

and extracts:

- `.tag_name`

## Common failures

- Missing or invalid `GH_TOKEN`: GitHub API may reject the request or rate-limit it.
- No releases present in the target repository: the API can return an error object instead of a release payload.
- `jq` missing on the runner.

## Known caveats

The current implementation is minimal and has several important caveats:

- `exit_if_not_found` is declared but not implemented.
- `exit_if_up_to_date` is declared but not implemented.
- The second step is named `Fail if latest tag is already up to date`, but it actually runs `exit 0` when `tag_name != 'v1'`.
- API errors are not explicitly checked before reading `.tag_name`.
- The action returns the latest release tag, not necessarily the latest Git tag overall.

This README reflects the current behavior as implemented.

## Verification

A minimal smoke check:

```yaml
- name: Query latest release tag
  id: tag_latest
  uses: ./tag-get-latest
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    repository: ${{ github.repository }}
```


