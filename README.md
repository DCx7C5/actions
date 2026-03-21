[![Test gh-variables and gh-secrets in GitHub Actions](https://github.com/DCx7C5/actions/actions/workflows/test_gh_variables_secrets.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_gh_variables_secrets.yml)

# Dystopian Actions

Central index for the local GitHub Actions in this repository.

## What is in this directory

- Composite actions used by CI/release automation (`./<action-name>`).
- Supporting files for cryptographic and workflow bootstrapping.
- Action-specific documentation in each action folder (`README.md` when available).

## Quick start

Use local actions from workflows with relative paths:

```yaml
jobs:
  example:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Create release
        uses: DCx7C5/actions/gh-create-release@v1
        with:
          release_tag: v1.2.3
          generate_notes: 'true'
          prerelease: 'false'
          assets: |
            dist/app.tar.gz 
```


## Conventions & Documentation

- Inputs that behave like booleans are passed as strings (`'true'` / `'false'`).
- Composite actions call other local actions with `uses: ./<action-name>`.
- Actions should fail with clear `::error::...` messages for invalid input states.
- Each action is self-documented: see the `README.md` in each action folder for a detailed description, input/output tables, dependencies, operation flow, usage examples, common failures, and quick verification steps. All READMEs follow a unified template for consistency and easy onboarding.

## Action catalog

### Release and tags

| Action                                         | Purpose                                                                 |
|------------------------------------------------|-------------------------------------------------------------------------|
| [`gh-create-release`](./gh-create-release)     | Create or verify GitHub release for a tag and optionally upload assets. |
| [`gh-create-issue`](./gh-create-issue)         | Create a new GitHub issue in the repository.                            |
| [`gh-upload-assets`](./gh-upload-assets)       | Upload one or more files to an existing release tag.                    |
| [`gh-workflow-run`](./gh-workflow-run)         | Delete workflow runs by status (`failure`, `cancelled`, ...).           |
| [`gh-delete-release`](./gh-delete-release)     | Delete an existing GitHub release.                                      |
| [`tag-create-and-push`](./tag-create-and-push) | Create and push git tags.                                               |
| [`tag-delete`](./tag-delete)                   | Delete tags locally/remotely.                                           |
| [`tag-get-latest`](./tag-get-latest)           | Resolve latest tag for release/version workflows.                       |

### AUR / PKGBUILD automation

| Action | Purpose |
|---|---|
| [`aur-sync-pkg`](./aur-sync-pkg)         | Sync package content from upstream repository into PKGBUILDs repo. |
| [`aur-delete-pkg`](./aur-delete-pkg)     | Delete package directory and remove metadata entry. |
| [`aur-create-srcinfo`](./aur-create-srcinfo) | Generate `.SRCINFO` from `PKGBUILD`. |
| [`aur-updpkgsums`](./aur-updpkgsums)     | Update checksum fields in `PKGBUILD` via `updpkgsums`. |
| [`aur-build-pkg`](./aur-build-pkg)       | Build package artifacts in Arch environment. |
| [`aur-build-repodb`](./aur-build-repodb) | Build (and optionally sign) repository database via `repo-add`. |
| [`aur-get-pkgbuilds`](./aur-get-pkgbuilds) | Retrieve/prepare PKGBUILD sources from upstream. |
| [`aur-get-version`](./aur-get-version)   | Resolve package version metadata. |
| [`aur-remote-changes`](./aur-remote-changes) | Detect upstream remote changes for package trees. |
| [`aur-validate-pkg`](./aur-validate-pkg) | Validate package structure/required files. |

### Git and repository utilities

| Action                                         | Purpose                                           |
|------------------------------------------------|---------------------------------------------------|
| [`git-add-remote`](./git-add-remote)           | Add/configure git remotes used by automation.     |
| [`git-configure-gnupg`](./git-configure-gnupg) | Configure GnuPG for use with Git.                |
| [`git-fetch`](./git-fetch)                     | Fetch refs from configured remotes.               |
| [`git-find-changed`](./git-find-changed)       | Detect changed files/paths for conditional steps. |
| [`git-stage-changes`](./git-stage-changes)     | Stage selected paths before commit.               |
| [`git-commit`](./git-commit)                   | Create commits from staged changes.               |
| [`git-pull-changes`](./git-pull-changes)       | Pull changes from remote.                         |
| [`git-push-changes`](./git-push-changes)       | Push commits/tags to remote.                      |
| [`git-merge`](./git-merge)                     | Merge branches/refs in automation workflows.      |
| [`git-status`](./git-status)                   | Inspect and expose workspace status.              |
| [`git-clean-workspace`](./git-clean-workspace) | Clean untracked/generated files in workspace.     |
| [`git-create-repo`](./git-create-repo)         | Create repository via GitHub API/CLI flows.       |
| [`git-delete-repo`](./git-delete-repo)         | Delete repository via automation flow.            |

### GPG / crypto helpers

| Action                                       | Purpose                                             |
|----------------------------------------------|-----------------------------------------------------|
| [`gpg-setup-home`](./gpg-setup-home)         | Prepare GnuPG home for CI usage.                    |
| [`gpg-import`](./gpg-import)                 | Import armored/binary key material.                 |
| [`gpg-export-key`](./gpg-export-key)         | Export selected key material.                       |
 | [`gpg-set-pass`](./gpg-set-pass)         | Set passphrase for a key in GPG home.              |
| [`gpg-preset-pass`](./gpg-preset-pass)       | Preload passphrase cache for signing.               |
| [`gpg-create-subkey`](./gpg-create-subkey)   | Create subkeys for CI signing/encryption flows.     |
| [`gpg-set-ownertrust`](./gpg-set-ownertrust) | Set ownertrust for imported keys.                   |
| [`gpg-sign-detached`](./gpg-sign-detached)   | Create detached signatures for artifacts.           |
| [`gpg-decrypt`](./gpg-decrypt)               | Decrypt encrypted files for CI tasks.               |
| [`gpg-cleanup`](./gpg-cleanup)               | Best-effort cleanup of temporary key material.      |
| [`ssl-decrypt`](./ssl-decrypt)               | SSL-related decryption helper for secret workflows. |
| [`ssl-encrypt`](./ssl-encrypt)               | SSL-related encryption helper for secret workflows. |

### Containers, packaging, misc

| Action                                     | Purpose                                                      |
|--------------------------------------------|--------------------------------------------------------------|
| [`arch-run-cmd`](./arch-run-cmd)           | Run commands in a controlled Arch Linux container/toolchain. |
| [`json-packages`](aur-json-packages)       | Query and mutate `.ci/packages.json` with `jq`.              |
| [`tar-create`](./tar-create)               | Build tar archives from selected files.                      |
| [`gh-secrets`](./gh-secrets)               | Store generated values as GitHub secret.                     |
| [`gh-variables`](./gh-variables)           | Store generated values as GitHub Actions variable.           |
| [`gh-upload-assets`](./gh-upload-assets)   | Release asset upload helper (also used by release creation). |
| [`tg-notify`](./tg-notify)                 | Send Telegram notifications.                                 |
| [`tg-notify-release`](./tg-notify-release) | Send Telegram release notifications.                         |

## Notes for maintainers

- Keep `action.yml` descriptions short and explicit; README can hold the detailed behavior.
- When changing action inputs/outputs, update the action README in the same commit.
- Prefer adding small validation guards over silently skipping invalid states.
