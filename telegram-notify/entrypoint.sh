#!/bin/bash
# Secure Telegram notification script
# Improvements:
# - Uses jq for safe JSON construction
# - Input validation
# - Proper secret handling (masked)
# - No command injection vulnerabilities
# - Error handling and cleanup

set -euo pipefail

# Error handling
trap 'unset TELEGRAM_BOT_TOKEN; exit 1' ERR EXIT

# Validate required environment variables
if [ -z "${TELEGRAM_BOT_TOKEN:-}" ]; then
  echo "ERROR: TELEGRAM_BOT_TOKEN not set" >&2
  exit 1
fi

if [ -z "${TELEGRAM_TO:-}" ]; then
  echo "ERROR: TELEGRAM_TO not set" >&2
  exit 1
fi

if [ -z "${TELEGRAM_MESSAGE:-}" ]; then
  echo "ERROR: TELEGRAM_MESSAGE not set" >&2
  exit 1
fi

# Set defaults
TELEGRAM_PARSE_MODE="${TELEGRAM_PARSE_MODE:-MarkdownV2}"
TELEGRAM_SILENT="${TELEGRAM_SILENT:-false}"

# Validate parse mode
case "$TELEGRAM_PARSE_MODE" in
  MarkdownV2|Markdown|HTML) ;;
  *)
    echo "ERROR: Invalid parse mode: $TELEGRAM_PARSE_MODE" >&2
    exit 1
    ;;
esac

# Validate silent flag
if ! [[ "$TELEGRAM_SILENT" =~ ^(true|false)$ ]]; then
  echo "ERROR: TELEGRAM_SILENT must be true or false" >&2
  exit 1
fi

# Convert silent flag to JSON boolean
DISABLE_NOTIFICATION=$([ "$TELEGRAM_SILENT" = "true" ] && echo "true" || echo "false")

echo "Preparing to send Telegram message..."
echo "Chat ID: $TELEGRAM_TO"
echo "Parse mode: $TELEGRAM_PARSE_MODE"
echo "Silent: $TELEGRAM_SILENT"

# Use jq for safe JSON construction (prevents injection)
JSON_PAYLOAD=$(jq -n \
  --arg chat_id "$TELEGRAM_TO" \
  --arg text "$TELEGRAM_MESSAGE" \
  --arg parse_mode "$TELEGRAM_PARSE_MODE" \
  --argjson disable_notification "$DISABLE_NOTIFICATION" \
  '{
    chat_id: ($chat_id | tonumber),
    text: $text,
    parse_mode: $parse_mode,
    disable_notification: $disable_notification
  }')

if [ -z "$JSON_PAYLOAD" ]; then
  echo "ERROR: Failed to construct JSON payload" >&2
  exit 1
fi

# Send message with proper error handling
echo "Sending Telegram message..."
RESPONSE=$(curl -s \
  -w "\n%{http_code}" \
  -X POST \
  -H "Content-Type: application/json" \
  --data "$JSON_PAYLOAD" \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage")

# Extract HTTP status code (last line)
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

# Check HTTP status code
if [ "$HTTP_STATUS" != "200" ]; then
  echo "ERROR: HTTP $HTTP_STATUS" >&2
  echo "Response: $RESPONSE_BODY" >&2
  exit 1
fi

# Parse JSON response
if ! echo "$RESPONSE_BODY" | jq -e '.ok' > /dev/null 2>&1; then
  echo "ERROR: Telegram API error" >&2
  echo "Response: $RESPONSE_BODY" >&2
  exit 1
fi

# Extract message ID for verification
MESSAGE_ID=$(echo "$RESPONSE_BODY" | jq -r '.result.message_id // empty')
if [ -n "$MESSAGE_ID" ]; then
  echo "✓ Telegram message sent successfully! (Message ID: $MESSAGE_ID)"
else
  echo "ERROR: No message ID in response" >&2
  exit 1
fi

exit 0

