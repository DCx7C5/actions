# Git Pull Changes Action

Pull the latest changes from a Git repository with configurable strategies.

## Features

- **Two strategies**: `rebase` (default) or `ff-only`
- **Auto branch detection**: Automatically pulls current branch if not specified
- **Safety checks**: Verifies Git repo, remote configuration, and clean working tree
- **Flexible**: Allow dirty working tree with optional flag

## Usage

### Basic pull with rebase (default)
```yaml
- uses: ./actions/git-pull-changes
  with:
    remote: origin
```

### Fast-forward only pull
```yaml
- uses: ./actions/git-pull-changes
  with:
    strategy: ff-only
    remote: origin
```

### Pull specific branch
```yaml
- uses: ./actions/git-pull-changes
  with:
    branch: main
    strategy: rebase
```

### Allow uncommitted changes
```yaml
- uses: ./actions/git-pull-changes
  with:
    allow_dirty: true
    strategy: rebase
```

## Inputs

| Input         | Required | Default  | Description                                 |
|---------------|----------|----------|---------------------------------------------|
| `strategy`    | ❌        | `rebase` | Pull strategy: `rebase` or `ff-only`        |
| `remote`      | ❌        | `origin` | Remote name to pull from                    |
| `branch`      | ❌        | ``       | Branch to pull (defaults to current branch) |
| `allow_dirty` | ❌        | `false`  | Allow pull with local uncommitted changes   |

## Strategies Explained

### Rebase (Default)
- **What it does**: `git pull --rebase`
- **Effect**: Fetches remote changes and replays your local commits on top
- **Result**: Linear history, no merge commits
- **Use when**: You want clean history and have local uncommitted work
- **Warning**: Rewrites local commit hashes (don't use on pushed commits)

### Fast-Forward Only
- **What it does**: `git pull --ff-only`
- **Effect**: Only advances branch pointer if fast-forward is possible
- **Result**: Fails if histories have diverged
- **Use when**: You want guaranteed linear history or safety check
- **Benefit**: Conservative; prevents accidental merges

## Error Handling

The action fails with clear error messages if:
- Current directory is not a Git repository
- Working tree has uncommitted changes (unless `allow_dirty: true`)
- Specified remote is not configured
- Detached HEAD detected without explicit `branch` input
- Invalid strategy specified

## When to Use This vs Other Actions

| Scenario | Recommended Action |
|----------|-------------------|
| **Simple sync** | ✅ `git-pull-changes` |
| **Multi-remote workflow** | ❌ Use `git-fetch` + `git-merge` |
| **Need to inspect changes first** | ❌ Use `git-fetch` + `git-merge` |
| **Complex merge strategies** | ❌ Use `git-merge` directly |
| **Quick CI updates** | ✅ `git-pull-changes` |

## Complete Workflow Example

```yaml
name: Update and Test

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Pull latest changes
        uses: ./actions/git-pull-changes
        with:
          strategy: ff-only
          remote: origin

      - name: Run tests
        run: npm test

      - name: Push if tests pass
        if: success()
        uses: ./actions/git-push-changes
        with:
          ref: HEAD
```

## Comparison: Rebase vs FF-Only

| Aspect | Rebase | FF-Only |
|--------|--------|---------|
| Local commits | Replays on top of remote | Must not exist (or be already pushed) |
| History rewriting | ✅ Yes (local only) | ❌ No |
| Merge commits | Never creates | Never creates |
| Conflict handling | Interactive rebase | Hard failure |
| Safety | Moderate | High |
| Use case | Active development | Strict linear workflows |

## Author

DCx7C5

