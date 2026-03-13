# Git Fetch Action

Fetch references and objects from a remote repository without merging.

## Features

- **Selective fetching**: Fetch all refs or a specific branch/tag
- **Prune support**: Automatically remove stale remote-tracking branches
- **Tag control**: Fetch all tags, no tags, or auto (default behavior)
- **Shallow fetch**: Limit history depth for faster CI/CD
- **Safety checks**: Verifies Git repo and remote configuration

## Usage

### Fetch all refs from origin
```yaml
- uses: ./actions/git-fetch
  with:
    remote: origin
```

### Fetch specific branch
```yaml
- uses: ./actions/git-fetch
  with:
    remote: origin
    ref: main
```

### Fetch with pruning (remove deleted remote branches)
```yaml
- uses: ./actions/git-fetch
  with:
    remote: origin
    prune: true
```

### Fetch all tags
```yaml
- uses: ./actions/git-fetch
  with:
    remote: origin
    tags: all
```

### Shallow fetch (CI optimization)
```yaml
- uses: ./actions/git-fetch
  with:
    remote: origin
    depth: 50
```

### Fetch from upstream
```yaml
- uses: ./actions/git-fetch
  with:
    remote: upstream
    ref: main
    prune: true
```

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `remote` | ❌ | `origin` | Remote name to fetch from |
| `ref` | ❌ | `` | Specific ref to fetch (empty = fetch all refs) |
| `prune` | ❌ | `false` | Remove remote-tracking refs that no longer exist on remote |
| `tags` | ❌ | `auto` | Fetch tags: `auto`, `all`, `none` |
| `depth` | ❌ | `` | Limit fetching to N commits (shallow fetch) |

## Tags Options

- **`auto`**: Default Git behavior (fetch tags that point to fetched objects)
- **`all`**: Fetch all tags from remote
- **`none`**: Don't fetch any tags

## Why Use Fetch Separately?

Separating `fetch` from `merge`/`pull` gives you:

1. **Inspect before merge**: Review changes with `git log HEAD..origin/main`
2. **Multi-remote workflows**: Fetch from multiple remotes, then merge selectively
3. **Error isolation**: If fetch fails, you know it's a network/remote issue, not a merge conflict
4. **Automation flexibility**: Fetch on schedule, merge on demand

## Example: Fetch → Inspect → Merge Workflow

```yaml
- name: Fetch latest changes
  uses: ./actions/git-fetch
  with:
    remote: origin
    prune: true

- name: Check for updates
  id: check
  run: |
    if git rev-list HEAD..origin/main --count | grep -q '^0$'; then
      echo "up_to_date=true" >> "$GITHUB_OUTPUT"
    else
      echo "up_to_date=false" >> "$GITHUB_OUTPUT"
    fi

- name: Merge if updates available
  if: steps.check.outputs.up_to_date == 'false'
  uses: ./actions/git-merge
  with:
    source: origin/main
    strategy: ff-only
```

## Author

DCx7C5

