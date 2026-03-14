# tg-notify-release

Composite GitHub Action to send a Telegram notification for a newly published signed release by delegating the actual send operation to `./tg-notify`.

## What this action does

1. Accepts release-related metadata such as repository, commit, branch, actor, fingerprint, tag, and release name.
2. Builds a preformatted HTML Telegram message.
3. Calls `./tg-notify` with `parse_mode: HTML`.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `token` | yes | - | Telegram bot token. |
| `to` | yes | - | Telegram chat ID. |
| `repository` | no | `${{ github.repository }}` | Repository name shown in the message. |
| `commit` | no | `${{ github.sha }}` | Commit SHA shown in the message. |
| `branch` | no | `${{ github.ref_name }}` | Branch name shown in the message. |
| `actor` | no | `${{ github.actor }}` | GitHub actor shown in the message. |
| `fingerprint` | yes | `''` | GPG fingerprint shown in the signing section. |
| `tag_name` | yes | `''` | Tag name shown in the tag/release section. |
| `release_name` | yes | `''` | Release name shown in the message. |

## Outputs

This action currently defines no outputs.

## Runtime behavior

The action consists of a single composite step:

- `uses: ./tg-notify`

with:

- `token`
- `to`
- `parse_mode: HTML`
- a generated multiline `message`

## Example

```yaml
- name: Notify release in Telegram
  uses: ./tg-notify-release
  with:
    token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
    to: ${{ secrets.TELEGRAM_CHANNEL_ID }}
    fingerprint: ${{ steps.gpg_import.outputs.fingerprint }}
    tag_name: ${{ steps.tag_create.outputs.tag_name }}
    release_name: ${{ steps.tag_create.outputs.tag_name }}
```

## Typical use case

This action fits after steps that:

- import a GPG signing key
- create and push a Git tag
- create a GitHub release

A real workflow in this repository uses it after `tag-create-and-push` and release publication.

## Common failures

Because this action delegates to `./tg-notify`, failures typically come from:

- invalid Telegram bot token or chat ID
- Telegram API/network issues
- malformed HTML content rejected by Telegram

## Known caveats

The current message template in `action.yml` contains several hard-coded or incomplete placeholders:

- `Version` is rendered as an empty `<code></code>` block.
- `Release Name` is rendered as `<code>$</code>` instead of `${{ inputs.release_name }}`.
- The release link is hard-coded to `/releases/tag/v1` instead of using `inputs.tag_name`.
- `fingerprint`, `tag_name`, and `release_name` are marked `required: true` while also carrying empty-string defaults.

This README documents the action as implemented today.

## Verification

A minimal workflow check:

```yaml
- name: Send release notification
  uses: ./tg-notify-release
  with:
    token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
    to: ${{ secrets.TELEGRAM_CHANNEL_ID }}
    fingerprint: ABCDEF1234567890ABCDEF1234567890ABCDEF12
    tag_name: v1.2.3
    release_name: v1.2.3
```

