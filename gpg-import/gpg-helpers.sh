#!/bin/bash
# GPG Helper Functions Library
# Shared utilities for GPG operations

# Count GPG keys (public and secret)
# Returns: "total_count public_count secret_count" (space-separated)
gpg_count_keys() {
  local KEY_COUNT_PUB KEY_COUNT_SEC KEY_COUNT_TOTAL

  KEY_COUNT_PUB=$(gpg --list-keys --with-colons 2>/dev/null | grep -c "^pub:" || true)
  KEY_COUNT_SEC=$(gpg --list-secret-keys --with-colons 2>/dev/null | grep -c "^sec:" || true)
  KEY_COUNT_TOTAL=$((KEY_COUNT_PUB + KEY_COUNT_SEC))

  echo "$KEY_COUNT_TOTAL $KEY_COUNT_PUB $KEY_COUNT_SEC"
}

# Get fingerprint of the first secret key
# Returns: fingerprint or empty string
gpg_get_secret_fingerprint() {
  local fingerprint

  fingerprint=$(gpg --batch --list-secret-keys --with-colons 2>/dev/null | grep "^fpr:" | head -1 | cut -d: -f10)

  echo "$fingerprint"
}

get_fingerprint() {
  if [ -n "$1" ]; then
    echo "$1" | gpg --with-colons --with-fingerprint --with-subkey-fingerprint --list-secret-keys 2>/dev/null | \
    grep -E "^fpr:.*:" | head -1 | cut -d: -f10
  elif [ -n "$2" ]; then
    echo "$2" | gpg --with-colons --with-fingerprint --with-subkey-fingerprint --list-keys 2>/dev/null | \
    grep -E "^fpr:.*:" | head -1 | cut -d: -f10
  else
    echo ""
  fi
}

# Log key count statistics
# Arguments: $1 = total, $2 = public, $3 = secret
gpg_log_key_stats() {
  local total public secret

  total="$1"
  public="$2"
  secret="$3"

  echo "::notice::GPG Keys - Public: $public, Secret: $secret, Total: $total"
}
