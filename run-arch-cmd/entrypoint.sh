#!/bin/bash

set -euo pipefail

# Error handling
trap 'echo "ERROR: Script failed on line $LINENO" >&2; exit 1' ERR

# Validate inputs
if [ $# -lt 2 ]; then
  echo "ERROR: Missing arguments" >&2
  echo "Usage: $0 <directory> <command>" >&2
  exit 1
fi

WORK_DIR="$1"
COMMAND="$2"

# Validate directory exists
if ! [ -d "$WORK_DIR" ]; then
  echo "ERROR: Directory does not exist: $WORK_DIR" >&2
  exit 1
fi

# Change to work directory safely
cd "$WORK_DIR" || exit 1

# Setup GPG environment with security
if ! mkdir -p "$GNUPGHOME" 2>/dev/null; then
  echo "WARNING: Could not create GNUPGHOME, may already exist"
fi

# Secure GPG directory permissions
chmod 700 "$GNUPGHOME" || {
  echo "ERROR: Could not set GPG directory permissions" >&2
  exit 1
}

# Verify GPG setup
if ! gpg --list-keys > /dev/null 2>&1; then
  echo "WARNING: GPG initialization may have issues"
fi

echo "Initialized GPG environment at: $GNUPGHOME"
echo "Working directory: $(pwd)"

# Execute command with proper error handling
echo "Executing command: $COMMAND"
if ! bash -c "$COMMAND"; then
  echo "ERROR: Command execution failed" >&2
  exit 1
fi

echo "Command completed successfully"
exit 0
