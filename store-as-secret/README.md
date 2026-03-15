# store-as-secret

Composite GitHub Action to create or update GitHub Secrets using `gh secret set`.

## What this action does

- Checks out the repository.
- Sets up GitHub CLI authentication.
- Stores a value as a repository, organization, or environment secret.
- Uses `gh secret set` with the selected target scope.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `value` | yes | - | Secret value to store (supports multiline values). |
| `secret_name` | yes | - | Secret name to create or update. |
| `token` | no | `${{ secrets.GITHUB_TOKEN }} || ${{ github.token }}` | Token used to authenticate GitHub CLI. |
| `secret_type` | no | `org` | Intended target scope: `repo`, `org`, or `env`. |

## Outputs

This action does not define outputs.

## Dependencies

- `actions/checkout@v4`
- `actions4gh/setup-gh@v1`
- `gh` (GitHub CLI)
- Token with permissions to manage secrets at the chosen scope

## Operation flow

1. Checkout repository.
2. Setup/authenticate GitHub CLI with `token`.
3. Depending on selected type, call one of:
   - `gh secret set <name> --repo <owner/repo>`
   - `gh secret set <name> --org <owner>`
   - `gh secret set <name> --env <environment>`

## Examples

## Example: store repository secret

```yaml
- name: Store repo secret
  uses: ./store-as-secret
  with:
    secret_name: MY_TOKEN
    value: ${{ secrets.MY_TOKEN_VALUE }}
    token: ${{ secrets.GITHUB_TOKEN }}
    secret_type: repo
```

## Example: store organization secret

```yaml
- name: Store org secret
  uses: ./store-as-secret
  with:
    secret_name: SHARED_SIGNING_KEY
    value: ${{ secrets.SIGNING_KEY }}
    token: ${{ secrets.ORG_ADMIN_TOKEN }}
    secret_type: org
```

## Common failures

- Token does not have permission for the selected scope (`repo`/`org`/`env`).
- Environment secret requested but workflow environment is not set.
- `gh` auth/setup fails on the runner.
- Invalid or empty secret name/value.

## Quick verification

```yaml
- name: Verify repository secret exists
  shell: bash
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: gh secret list --repo "${{ github.repository }}" | cat
```


