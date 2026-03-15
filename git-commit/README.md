# git-commit

Composite GitHub Action to create (or amend) Git commits with optional GPG signing and optional Copilot-generated commit messages.

## What this action does

- Optionally installs GitHub Copilot CLI and generates a commit message.
- Prepares commit arguments (`--amend`, `--signoff`, signing-related flags).
- Optionally skips commit when no staged changes are present.
- Creates the commit and exports commit metadata outputs.
- Always emits final outputs for downstream workflow steps.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `message` | no | `''` | Commit message to use. |
| `copilot` | no | `false` | If `true`, enable Copilot CLI support for commit message generation. |
| `amend` | no | `false` | If `true`, amend previous commit instead of creating a new one. |
| `signoff` | no | `false` | If `true`, add `Signed-off-by` line. |
| `allow_empty` | no | `false` | If `true`, allow creating an empty commit. |
| `no_verify` | no | `false` | If `true`, bypass commit hooks (`--no-verify`). |
| `gpg_sign` | no | `false` | If `true`, request GPG signing flow. |
| `gpg_key_id` | no | `""` | GPG key ID for signing. |
| `gpg_passphrase` | no | `""` | Passphrase for the GPG key. |
| `pre_cached_pass` | no | `false` | Indicates passphrase is already cached in gpg-agent. |
| `skip_if_no_changes` | no | `true` | If `true`, skip commit when no staged changes exist. |
| `github_token` | no | `''` | Token used by optional Copilot installation step. |

## Outputs

| Output | Description |
|---|---|
| `commit_sha` | SHA of created commit (empty if no commit was made). |
| `committed` | `true` if commit was created, otherwise `false`/`pending` according to flow state. |
| `amended` | Mirrors `inputs.amend`. |

## Dependencies

- `bash`
- `git`
- `gpg` (when signing is enabled)
- Nested action: `./git-install-copilot` (when `copilot == 'true'`)

## Operation flow

1. Optionally install Copilot CLI and generate message when `copilot == 'true'` and `message` is empty.
2. Build commit argument list in `prepare` step.
3. Optionally check for staged changes and skip commit when `skip_if_no_changes` is `true`.
4. Resolve final commit message from `message`, Copilot output, or fallback message.
5. Run `git commit` with prepared args and optional passphrase handling.
6. Emit `commit_sha`, `committed`, and `amended` in final output step.

## Examples

## Example: standard commit

```yaml
- name: Create commit
  id: commit
  uses: ./git-commit
  with:
    message: "chore: update package metadata"
    signoff: 'true'
```

## Example: amend and sign commit

```yaml
- name: Amend signed commit
  id: amend_commit
  uses: ./git-commit
  with:
    amend: 'true'
    gpg_sign: 'true'
    gpg_key_id: ${{ vars.GPG_KEY_ID }}
    gpg_passphrase: ${{ secrets.GPG_PASSPHRASE }}
    pre_cached_pass: 'false'
```

## Example: use Copilot message generation

```yaml
- name: Commit with Copilot-generated message
  id: copilot_commit
  uses: ./git-commit
  with:
    copilot: 'true'
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Common failures

- No staged changes exist and commit is conditionally skipped.
- `amend: 'true'` is set but repository has no previous commit.
- GPG signing requested but key/passphrase setup is invalid.
- Copilot CLI installation or message generation fails.


## Quick verification

```yaml
- name: Verify last commit and outputs
  shell: bash
  run: |
    git log -1 --oneline | cat
    echo "sha=${{ steps.commit.outputs.commit_sha }}"
    echo "committed=${{ steps.commit.outputs.committed }}"
```

