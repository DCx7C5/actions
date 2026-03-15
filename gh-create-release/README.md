# gh-release-create

Composite GitHub Action to create (or verify) a GitHub Release for a tag and optionally upload release assets.

## What this action does

- Creates a release for a given tag using `gh release create`.
- Supports custom release title and body.
- Can auto-generate release notes from merged PRs.
- Supports draft and prerelease flags.
- Can fail or continue if the release already exists.
- Optionally delegates asset upload to `./upload-assets`.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `release_tag` | yes | - | Git tag to create the release for (for example `v1.2.3`). |
| `release_name` | no | `""` | Release title. Falls back to `release_tag` when empty. |
| `release_body` | no | `""` | Custom markdown release notes body. |
| `generate_notes` | no | `"false"` | If `true`, uses GitHub-generated release notes. |
| `draft` | no | `"false"` | If `true`, creates the release as draft. |
| `prerelease` | no | `"false"` | If `true`, marks release as prerelease. |
| `assets` | no | `""` | Newline-separated file paths to upload as release assets. |
| `github_token` | no | `""` | Token for GitHub API/CLI. Defaults to `${{ github.token }}`. |
| `fail_if_exists` | no | `"true"` | If `true`, fails when release for tag already exists. |

## Outputs

| Output | Description |
|---|---|
| `created` | `true` if release was created, `false` if already existed and action continued. |
| `release_id` | Numeric ID of the release. |
| `html_url` | Public release page URL. |
| `upload_url` | API upload URL for release assets. |

## Dependencies

- `bash`
- `gh` (GitHub CLI)
- Authenticated token in `GH_TOKEN` (provided through input/default)

## Operation flow

1. Resolve release title: `release_name` if set, otherwise `release_tag`.
2. Check whether a release for `release_tag` already exists.
3. If release exists:
   - fail when `fail_if_exists` is `true`, or
   - emit outputs and exit successfully when `fail_if_exists` is `false`.
4. If release does not exist, build `gh release create` flags from inputs.
5. Create release and emit outputs.
6. If `assets` is not empty, call `./upload-assets` to upload files.

## Examples

## Example: create a standard release

```yaml
- name: Create release
  id: release
  uses: ./gh-create-release
  with:
    release_tag: v1.2.3
    release_name: Dystopian v1.2.3
    release_body: |
      ## Changes
      - Improve installer defaults
      - Fix update hook behavior
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Example: prerelease with generated notes and assets

```yaml
- name: Create prerelease and upload assets
  uses: ./gh-create-release
  with:
    release_tag: v1.3.0-rc1
    generate_notes: "true"
    prerelease: "true"
    fail_if_exists: "false"
    assets: |
      dist/dystopian-linux-x86_64.tar.gz
      dist/checksums.txt
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Common failures

- Tag does not exist in the repository.
- Token does not have permissions to create releases or upload assets.
- `gh` is missing or not authenticated on the runner.
- `fail_if_exists` is `true` and release already exists.

## Known caveats

- `assets` should be concrete file paths. The helper action checks file existence and skips missing files.
- When `generate_notes` is `true`, custom `release_body` is ignored by design.

## Quick verification

```yaml
- name: Verify release exists
  shell: bash
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: gh release view v1.2.3 --json id,url | cat
```

