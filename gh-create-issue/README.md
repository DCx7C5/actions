# gh-create-issue

Composite GitHub Action to create a new GitHub Issue in the specified repository.

## What this action does

- Uses the GitHub CLI (`gh`) to create an issue.
- Accepts title, body, and repository as inputs.
- Outputs the created issue URL.

## Inputs

| Input      | Required | Default | Description                                 |
|------------|----------|---------|---------------------------------------------|
| `title`    | yes      | -       | Title of the issue.                         |
| `body`     | no       | `""`    | Description/body of the issue.              |
| `repo`     | yes      | -       | Target repository in `owner/repo` format.   |
| `labels`   | no       | `""`    | Comma-separated list of labels.             |
| `assignees`| no       | `""`    | Comma-separated list of assignees.          |
| `github_token` | no   | `${{ github.token }}` | Token for authentication.         |

## Outputs

| Output     | Description                        |
|------------|------------------------------------|
| `issue_url`| URL of the created issue.           |

## Dependencies

- `bash`
- `gh` (GitHub CLI)

## Operation flow

1. Authenticate with GitHub CLI using `github_token`.
2. Run `gh issue create` with the provided inputs.
3. Output the created issue URL.

## Examples

### Example: create a new issue

```yaml
- name: Create issue
  id: issue
  uses: ./gh-create-issue
  with:
    title: "Fehlerbericht"
    body: "Beschreibung des Fehlers."
    repo: "user/repo"
    labels: bug,urgent
    assignees: user1,user2
```

## Common failures

- Token does not have permission to create issues.
- Repository does not exist or is not accessible.
- `gh` is missing or not authenticated.

## Quick verification

```yaml
- name: Print issue URL
  run: echo "${{ steps.issue.outputs.issue_url }}"
```
