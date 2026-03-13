# Git Merge Action

Merge a specified branch or ref into the current branch with configurable merge strategies.

## Features

- **Multiple strategies**: `merge`, `ff-only`, `no-ff`, `squash`
- **Safety checks**: Verifies clean working tree and source ref existence
- **Flexible**: Merge any branch, tag, or remote-tracking branch
- **Unrelated histories**: Optional flag for merging repos without common ancestor

## Usage

### Fast-forward only merge
```yaml
- uses: ./actions/git-merge
  with:
    source: origin/main
    strategy: ff-only
```

### Standard merge with custom message
```yaml
- uses: ./actions/git-merge
  with:
    source: feature/new-feature
    strategy: merge
    message: "Merge feature/new-feature into main"
```

### No-fast-forward merge (always create merge commit)
```yaml
- uses: ./actions/git-merge
  with:
    source: origin/develop
    strategy: no-ff
```

### Squash merge (combine all commits)
```yaml
- uses: ./actions/git-merge
  with:
    source: feature/fixes
    strategy: squash
    message: "Apply all fixes from feature branch"
```
**Note**: Squash merge stages changes but does not commit automatically. You must commit manually after.

### Merge unrelated histories
```yaml
- uses: ./actions/git-merge
  with:
    source: upstream/main
    strategy: merge
    allow_unrelated: true
```

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `source` | ✅ | - | Source branch/ref to merge (e.g., `origin/main`, `feature/xyz`) |
| `strategy` | ❌ | `merge` | Merge strategy: `merge`, `ff-only`, `no-ff`, `squash` |
| `message` | ❌ | `` | Custom merge commit message |
| `allow_unrelated` | ❌ | `false` | Allow merging unrelated histories |

## Strategies Explained

- **`merge`**: Standard Git merge (fast-forward if possible, merge commit otherwise)
- **`ff-only`**: Only succeeds if fast-forward is possible; fails otherwise
- **`no-ff`**: Always creates a merge commit, even if fast-forward is possible
- **`squash`**: Combines all source commits into staged changes (manual commit required)

## Error Handling

The action fails with clear error messages if:
- Working tree has uncommitted changes
- Source ref does not exist (hint: run `git fetch` first)
- Invalid strategy specified
- Fast-forward not possible with `ff-only` strategy

## Comparison: `git-merge` vs `git-pull-changes`

| Aspect | `git-merge` | `git-pull-changes` |
|--------|-------------|-------------------|
| **Control** | Explicit: merge any ref | Implicit: fetch + merge/rebase |
| **Flexibility** | Any branch/tag/ref | Only remote-tracking branch |
| **Multi-remote** | ✅ Supports | ❌ Single remote focus |
| **Strategy** | 4 options | 2 options (rebase/ff-only) |
| **Use case** | Complex workflows | Simple "get latest" |

**Recommendation**: Use `git-merge` for CI/CD pipelines where you need precise control; use `git-pull-changes` for quick updates.

## Author

DCx7C5

