#!/bin/bash

set -euo pipefail

# Error handling with context
trap 'echo "ERROR: Script failed on line $LINENO (command: $BASH_COMMAND)" >&2; exit 1' ERR

WORK_DIR="$1"
# Fallback auf Standard, wenn leer, null oder ein Systempfad
if [[ -z "$WORK_DIR" || "$WORK_DIR" == "null" || "$WORK_DIR" == "/bin/bash" ]]; then
  WORK_DIR="/github/workspace"
fi
GNUPGHOME="${2:-$WORK_DIR/.gnupg}"

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

if [[ $# -ge 2 ]]; then
  shift 2
else
  shift $#
fi
COMMAND="$*"


if [[ ! -d "$WORK_DIR" ]]; then
  if [[ "$(id -u)" == "0" ]]; then
    mkdir -p "$WORK_DIR"
  else
    echo "WARNING: Cannot create work directory: $WORK_DIR (no permission, not root)" >&2
    if [[ -d "/home/runner/work" && -w "/home/runner/work" ]]; then
      echo "Falling back to /home/runner/work as work directory." >&2
      WORK_DIR="/home/runner/work"
    else
      echo "ERROR: /home/runner/work is not available or not writable. Aborting." >&2
      exit 1
    fi
  fi
fi
cd "$WORK_DIR" || {
  echo "ERROR: Cannot change to work directory: $WORK_DIR" >&2
  exit 1
}

# ============================================================================
# Environment Detection & Setup
# ============================================================================
export USER="${USER:-builder}"
export LANG=C.UTF-8
export TERM=xterm-256color
export MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}"
export PACKAGER="${PACKAGER:-Unknown Packager <packager@example.com>}"
export GPGSIGN_KEY="${GPGSIGN_KEY:-}"

IS_GITHUB_ACTIONS="${GITHUB_ACTIONS:-false}"
IS_CI="${CI:-false}"

# Makepkg-specific optimization
export CCACHE_DIR="${WORK_DIR}/.ccache"
export CCACHE_MAXSIZE="2G"

# In GitHub Actions, be less verbose (save logs, faster)
if [ "$IS_GITHUB_ACTIONS" = "true" ]; then
  export VERBOSE=0
  export QUIET=1
fi

# For GitHub Actions: reduce startup verbosity
if [ "$IS_GITHUB_ACTIONS" != "true" ] && [ $# -eq 0 ]; then
  echo "==> No arguments provided. Starting interactive shell for makepkg..."
fi

# Ensure work directory exists (create if needed for makepkg)
if ! [ -d "$WORK_DIR" ]; then
  mkdir -p "$WORK_DIR" || {
    echo "ERROR: Cannot create work directory: $WORK_DIR" >&2
    exit 1
  }
fi

# Only show setup messages if not in automated CI
if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
  echo "::notice::==> Initializing GPG environment at: $GNUPGHOME"
fi

# Initialize GPG if needed (idempotent)
if ! gpg --list-keys > /dev/null 2>&1; then
  gpg --list-keys > /dev/null 2>&1 || true
fi

# Check if keys are available (warn if empty)
if [[ -z "$(gpg --list-keys 2>/dev/null)" && "$IS_CI" = "true" ]]; then
  echo "::warning::No GPG keys found in $GNUPGHOME - signing may fail"
fi



# ============================================================================
# Makepkg Configuration Check
# ============================================================================
if [ -f /etc/makepkg.conf ]; then
  if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
    echo "::notice::==> makepkg.conf detected"
  fi

  # Verify PACKAGER is set (required for AUR) - warn quietly in CI
  if ! grep -q "^PACKAGER=" /etc/makepkg.conf; then
    if [ "$IS_CI" = "true" ]; then
      echo "::warning::PACKAGER not set in /etc/makepkg.conf - set via env var PACKAGER"
    else
      echo "::warning::PACKAGER not set in /etc/makepkg.conf - set via env var PACKAGER"
    fi
  fi
fi

# Show environment only if not in GitHub Actions
if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
  echo "::group::==> Environment ready:"
  echo "    User: $USER"
  echo "    Work directory: $(pwd)"
  echo "    GPG home: $GNUPGHOME"
  echo "    Make flags: $MAKEFLAGS"
  echo "::endgroup::"
fi

# ============================================================================
# Command Execution with CI-Aware Logging and Timeout Support
# ============================================================================
_RUN_WITH_SUDO="${RUN_WITH_SUDO:-false}"
ENV_VARS=(
  "GNUPGHOME=$GNUPGHOME"
  "LANG=$LANG"
  "TERM=$TERM"
)

[[ -n "$MAKEFLAGS" ]] && ENV_VARS+=("MAKEFLAGS=$MAKEFLAGS")
[[ -n "$PACKAGER" ]] && ENV_VARS+=("PACKAGER=$PACKAGER")
[[ -n "$GPGSIGN_KEY" ]] && ENV_VARS+=("GPGSIGN_KEY=$GPGSIGN_KEY")

if [[ -n "$COMMAND" ]]; then
  if [ "$_RUN_WITH_SUDO" = "true" ]; then
    exec sudo -u builder env "${ENV_VARS[@]}" bash -c "$COMMAND"
  else
    exec bash -c "$COMMAND"
  fi
else
  if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
    echo "::notice::No command provided, starting interactive shell..."
  fi
  echo "Starte interaktive Shell..."
  exec bash -l || { echo "Fehler: Interaktive Shell konnte nicht gestartet werden!" >&2; exit 99; }
fi

