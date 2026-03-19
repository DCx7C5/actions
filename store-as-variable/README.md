# store-as-variable

Composite GitHub Action to create or update GitHub Actions variables using `gh variable set`.

## What this action does

- Checks out the repository.
- Sets up GitHub CLI authentication.
- Stores a value as a repository, organization, or environment variable.
- Uses `gh variable set` with `--visibility all` for supported scopes.

## Inputs

| Input           | Required | Default                      | Description                                          |
|-----------------|----------|------------------------------|------------------------------------------------------|
| `value`         | yes      | -                            | Variable value to store (supports multiline values). |
| `variable_name` | yes      | -                            | Variable name to create or update.                   |
| `token`         | no       | `${{ secrets.GITHUB_TOKEN }} |                                                      | ${{ github.token }}` | Token used to authenticate GitHub CLI. |
| `variable_type` | no       | `org`                        | Target scope: `env`, `repo`, or `org`.               |

## Outputs

This action does not define outputs.

## Dependencies

- `actions/checkout@v4`
- `actions4gh/setup-gh@v1`
- `gh` (GitHub CLI)
- Token with permissions to manage variables at the chosen scope

## Operation flow

1. Checkout repository using provided token.
2. Setup/authenticate GitHub CLI with `token`.
3. Depending on `variable_type`, call one of:
   - `gh variable set <name> --repo <owner/repo> --visibility all`
   - `gh variable set <name> --org <owner> --visibility all`
   - `gh variable set <name> --env <environment> --visibility all`

## Examples

## Example: store repository variable

```yaml
- name: Store repo variable
  uses: ./store-as-variable
  with:
    variable_name: BUILD_CHANNEL
    value: stable
    token: ${{ secrets.GITHUB_TOKEN }}
    scope: repo
```

## Example: store environment variable

```yaml
- name: Store environment variable
  uses: ./store-as-variable
  with:
    variable_name: DEPLOY_REGION
    value: eu-central
    token: ${{ secrets.GITHUB_TOKEN }}
    scope: env
```

## Common failures

- Token does not have permission for variable management at selected scope.
- Environment variable requested but workflow environment is not set.
- `gh` auth/setup fails on the runner.
- Invalid or empty variable name/value.

## Quick verification

```yaml
- name: Verify repository variable exists
  shell: bash
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: gh variable list --repo "${{ github.repository }}" | cat
```

