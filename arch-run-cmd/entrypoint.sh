#!/bin/bash

set -euo pipefail

# Error handling with context
trap 'echo "ERROR: Script failed on line $LINENO (command: $BASH_COMMAND)" >&2; exit 1' ERR

# ============================================================================
# Environment Detection & Setup
# ============================================================================
export USER="${USER:-builder}"
export GNUPGHOME="${GNUPGHOME:-/home/${USER}/.gnupg}"
export LANG=C.UTF-8
export TERM=xterm-256color
export MAKEFLAGS="${MAKEFLAGS:--j$(nproc)}"
export PACKAGER="${PACKAGER:-Unknown Packager <packager@example.com>}"

# Detect GitHub Actions environment
IS_GITHUB_ACTIONS="${GITHUB_ACTIONS:-false}"
IS_CI="${CI:-false}"

# Makepkg-specific optimization
export CCACHE_DIR="/home/${USER}/.ccache"
export CCACHE_MAXSIZE="2G"

# In GitHub Actions, be less verbose (save logs, faster)
if [ "$IS_GITHUB_ACTIONS" = "true" ]; then
  export VERBOSE=0
  export QUIET=1
fi

# ============================================================================
# Input Validation
# ============================================================================
WORK_DIR="${1:-.}"
COMMAND="${2:-}"
START_TIME=$(date +%s)

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

cd "$WORK_DIR" || exit 1

# ============================================================================
# GPG & Keyring Setup for AUR Signing (Secure for CI)
# ============================================================================
# Only show setup messages if not in automated CI
if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
  echo "==> Initializing GPG environment at: $GNUPGHOME"
fi

mkdir -p "$GNUPGHOME" || {
  echo "ERROR: Cannot create GNUPGHOME" >&2
  exit 1
}

# Set correct permissions (required for GPG, critical security)
chmod 700 "$GNUPGHOME" || {
  echo "ERROR: Cannot set GNUPGHOME permissions" >&2
  exit 1
}

# Initialize GPG if needed (idempotent)
if ! gpg --list-keys > /dev/null 2>&1; then
  gpg --list-keys > /dev/null 2>&1 || true
fi

# ============================================================================
# Ccache Setup for Build Performance
# ============================================================================
if [ -d "$(which ccache 2>/dev/null | xargs dirname)" ]; then
  mkdir -p "$CCACHE_DIR" || true
  chmod 755 "$CCACHE_DIR" || true

  if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
    echo "==> ccache enabled at: $CCACHE_DIR (max: $CCACHE_MAXSIZE)"
  fi
fi

# ============================================================================
# Makepkg Configuration Check
# ============================================================================
if [ -f /etc/makepkg.conf ]; then
  if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
    echo "==> makepkg.conf detected"
  fi

  # Verify PACKAGER is set (required for AUR) - warn quietly in CI
  if ! grep -q "^PACKAGER=" /etc/makepkg.conf; then
    if [ "$IS_CI" = "true" ]; then
      echo "::warning::PACKAGER not set in /etc/makepkg.conf - set via env var PACKAGER"
    else
      echo "WARNING: PACKAGER not set in /etc/makepkg.conf - set via env var PACKAGER"
    fi
  fi
fi

# Show environment only if not in GitHub Actions
if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
  echo "==> Environment ready:"
  echo "    User: $USER"
  echo "    Work directory: $(pwd)"
  echo "    GPG home: $GNUPGHOME"
  echo "    Make flags: $MAKEFLAGS"
fi

# ============================================================================
# Command Execution with CI-Aware Logging
# ============================================================================
if [ -n "$COMMAND" ]; then
  if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
    echo "==> Executing: $COMMAND"
  else
    echo "::group::Build Command Execution"
  fi

  # Execute command with failure handling
  EXIT_CODE=0
  if ! bash -c "$COMMAND"; then
    EXIT_CODE=$?
    echo "ERROR: Command failed with exit code $EXIT_CODE" >&2

    if [ "$IS_GITHUB_ACTIONS" = "true" ]; then
      echo "::endgroup::"
      echo "::error::Build failed with exit code $EXIT_CODE"
    fi

    # Only keep shell alive in interactive mode
    if [ "$IS_CI" != "true" ]; then
      echo "==> Keeping container alive for debugging - use 'docker exec -it <id> bash' to inspect"
      exec bash -l
    else
      exit $EXIT_CODE
    fi
  fi

  if [ "$IS_GITHUB_ACTIONS" = "true" ]; then
    echo "::endgroup::"
  fi

  # Calculate duration
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))

  if [ "$IS_GITHUB_ACTIONS" = "true" ]; then
    echo "::notice::Build completed successfully in ${DURATION}s"
  else
    echo "==> Command completed successfully in ${DURATION}s"
    echo "==> Keeping container alive - use 'docker exec -it <id> bash' for further interaction"
    exec bash -l
  fi

  exit 0
else
  # Interactive mode
  if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
    echo "==> Starting interactive shell..."
    echo "    Tip: Run 'makepkg -si' to build and install AUR packages"
  fi

  exec bash -l
fi
