#!/bin/bash
set -euo pipefail

# Escape special characters for MarkdownV2 (Telegram's strictest format)
escape_markdown_v2() {
  printf "%s" "$1" | sed -e 's/[\[+*-\!}{)(_#\\|`]/\\&/g' -e 's/]/\\]/'
}

# Only escape if using MarkdownV2
if [[ "${TELEGRAM_PARSE_MODE}" == "MarkdownV2" ]]; then
  ESCAPED_MESSAGE=$(escape_markdown_v2 "$TELEGRAM_MESSAGE")
else
  ESCAPED_MESSAGE="$TELEGRAM_MESSAGE"
fi

# Build JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
  "chat_id": "$TELEGRAM_TO",
  "text": "$ESCAPED_MESSAGE",
  "parse_mode": "$TELEGRAM_PARSE_MODE",
  "disable_notification": $TELEGRAM_SILENT
}
EOF
)

# Send message
RESPONSE=$(curl -s \
  -X POST \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage")

# Check result
if echo "$RESPONSE" | grep -q '"ok":true'; then
  echo "Telegram message sent successfully!"
else
  echo "Failed to send Telegram message"
  echo "Response: $RESPONSE"
  exit 1
fi