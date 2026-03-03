#!/bin/bash
# GPG Helper Functions Library
# Shared utilities for GPG operations

# Count GPG keys (public and secret)
# Returns: "total_count public_count secret_count" (space-separated)
gpg_count_keys() {
  local KEY_COUNT_PUB KEY_COUNT_SEC KEY_COUNT_TOTAL

  KEY_COUNT_PUB=$(gpg --list-keys --with-colons 2>/dev/null | grep -c "^pub:" || echo "0")
  KEY_COUNT_SEC=$(gpg --list-secret-keys --with-colons 2>/dev/null | grep -c "^sec:" || echo "0")
  KEY_COUNT_TOTAL=$((KEY_COUNT_PUB + KEY_COUNT_SEC))

  echo "$KEY_COUNT_TOTAL $KEY_COUNT_PUB $KEY_COUNT_SEC"
}

# Set owner trust level for a given fingerprint
# Arguments: $1 = fingerprint
gpg_set_owner_trust() {
  local fingerprint="$1"

  if [ -z "$fingerprint" ]; then
    return 1
  fi

  echo "$fingerprint:6:" | gpg --import-ownertrust 2>/dev/null || true
}

# Get fingerprint of the first secret key
# Returns: fingerprint or empty string
gpg_get_secret_fingerprint() {
  local fingerprint

  fingerprint=$(gpg --batch --list-secret-keys --with-colons 2>/dev/null | grep "^fpr:" | head -1 | cut -d: -f10)

  echo "$fingerprint"
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
