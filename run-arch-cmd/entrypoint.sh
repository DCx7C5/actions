#!/bin/bash
set -euo pipefail

cd "$1"

export GNUPGHOME=/github/workspace/.gnupg
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"

echo "Using GNUPGHOME=$GNUPGHOME (mounted via workspace)"

# Run user's script
bash -c "$2"