#!/usr/bin/env bash

set -euo pipefail
trap 'echo "ERROR: Script failed on line $LINENO (command: $BASH_COMMAND)" >&2; exit 1' ERR

WORK_DIR="${WORKING_DIRECTORY}"
GNUPGHOME="${GNUPGHOME:-$WORK_DIR/.gnupg}"

if [[ -d "$WORK_DIR" && "$GNUPGHOME" == ".gnupg" ]]; then
  export GNUPGHOME="$WORK_DIR/.gnupg"
elif [[ -d "$WORK_DIR" && -d "$GNUPGHOME" ]]; then
  export GNUPGHOME="$GNUPGHOME"
else
  export GNUPGHOME="$WORK_DIR/.gnupg"
fi

if [[ -d "$GNUPGHOME" && -n "$GPG_KEY_ID" && -n "$GPG_PASSPHRASE" && "$PRESET_CACHE" == "true" ]]; then
  KEYGRIPS=$(gpg --batch --with-colons --list-secret-keys "$GPG_KEY_ID" 2>/dev/null | awk -F: '/^grp:/ {print $10}')
  while read -r GRIP; do
    printf '%s' "$GPG_PASSPHRASE" | /usr/lib/gnupg/gpg-preset-passphrase --preset "$GRIP" 2>/dev/null || true
  done <<< "$KEYGRIPS"
  echo "::notice::Preset GPG passphrase in gpg-agent cache"
fi