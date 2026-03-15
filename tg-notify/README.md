# tg-notify

Composite GitHub Action to send a Telegram message from a GitHub Actions workflow with basic input validation and safe JSON payload construction.

## What this action does

1. Validates bot token format, chat ID format, and parse mode.
2. Exposes action inputs as runtime environment variables.
3. Builds the Telegram API request body with `jq`.
4. Sends the message to `sendMessage` via `curl`.
5. Verifies that Telegram returned HTTP `200` and an `ok: true` response.
6. Fails if no Telegram `message_id` is returned.

## Inputs

| Input        | Required | Default | Description                                                             |
|--------------|----------|---------|-------------------------------------------------------------------------|
| `token`      | yes      | -       | Telegram bot token. Expected format: `<numeric-id>:<token>`.            |
| `to`         | yes      | -       | Telegram chat ID. Must be numeric, can be negative for groups/channels. |
| `message`    | yes      | -       | Message text to send.                                                   |
| `parse_mode` | no       | `HTML`  | Telegram parse mode: `MarkdownV2`, `Markdown`, or `HTML`.               |
| `silent`     | no       | `false` | Whether to disable notification sound (`true`/`false`).                 |

## Outputs

This action currently defines no outputs.

## Runtime environment

The action passes these variables to `entrypoint.sh`:

- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_TO`
- `TELEGRAM_MESSAGE`
- `TELEGRAM_PARSE_MODE`
- `TELEGRAM_SILENT`

## Dependencies

The runner must provide:

- `bash`
- `curl`
- `jq`

## Request flow

The message is sent to:

- `https://api.telegram.org/bot<TOKEN>/sendMessage`

The JSON body contains:

- `chat_id`
- `text`
- `parse_mode`
- `disable_notification`

## Example: send a simple HTML message

```yaml
- name: Notify Telegram
  uses: ./tg-notify
  with:
    token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
    to: ${{ secrets.TELEGRAM_CHAT_ID }}
    parse_mode: HTML
    message: "<b>Build finished successfully</b>"
```

## Example: silent Markdown message

```yaml
- name: Notify Telegram silently
  uses: ./tg-notify
  with:
    token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
    to: ${{ secrets.TELEGRAM_CHAT_ID }}
    parse_mode: Markdown
    silent: 'true'
    message: "*Release created successfully*"
```

## Common failures

- `Invalid Telegram bot token format`: token does not match the expected bot token pattern.
- `Invalid Telegram chat ID format`: `to` is not numeric.
- `Invalid parse mode`: parse mode is not one of the supported values.
- `TELEGRAM_SILENT must be true or false`: invalid boolean string passed to `silent`.
- `HTTP <status>`: Telegram API request failed.
- `Telegram API error`: Telegram returned a non-success JSON response.
- `No message ID in response`: request returned `200`, but no usable message object was found.

## Verification

A minimal smoke test in a workflow:

```yaml
- name: Send Telegram smoke test
  uses: ./tg-notify
  with:
    token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
    to: ${{ secrets.TELEGRAM_CHAT_ID }}
    message: "Smoke test from GitHub Actions"
```

