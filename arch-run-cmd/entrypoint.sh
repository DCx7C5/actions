#!/bin/bash

set -euo pipefail

# Error handling with context
trap 'echo "ERROR: Script failed on line $LINENO (command: $BASH_COMMAND)" >&2; exit 1' ERR

WORK_DIR="$1"
GNUPGHOME="$2"
COMMAND="${3:-}"
START_TIME=$(date +%s)

if [[ -d "$WORK_DIR" && "$GNUPGHOME" == ".gnupg" ]]; then
  export GNUPGHOME="$WORK_DIR/.gnupg"
fi


# ============================================================================
# Environment Detection & Setup
# ============================================================================
export USER="${USER:-builder}"
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

# ============================================================================
# GPG & Keyring Setup for AUR Signing (Secure for CI)
# ============================================================================
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
  echo "    Make flags: $MAKEFLAGS::endgroup::"
fi

# ============================================================================
# Command Execution with CI-Aware Logging and Timeout Support
# ============================================================================
if [ -n "$COMMAND" ]; then
  if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
    echo "==> Executing: $COMMAND"
  else
    echo "::group::Build Command Execution"
  fi

  # Prepare timeout command if needed
  TIMEOUT_CMD=""
  if [ "${CONTAINER_TIMEOUT:-0}" -gt 0 ]; then
    TIMEOUT_CMD="timeout ${CONTAINER_TIMEOUT}"
  fi

  # Execute command with failure handling
  EXIT_CODE=0
  RUN_WITH_SUDO="${RUN_WITH_SUDO:-false}"

  shift 2
  if ! eval "${TIMEOUT_CMD} sudo -u build --preserve-env=PACKAGER --preserve-env=GNUPGHOME $*"; then

    EXIT_CODE=$?

    # Handle timeout specifically
    if [ $EXIT_CODE -eq 124 ]; then
      echo "::error::Build command exceeded timeout of ${CONTAINER_TIMEOUT}s" >&2
    else
      echo "::error::Build failed with exit code $EXIT_CODE" >&2
    fi

    if [ "$IS_GITHUB_ACTIONS" = "true" ]; then
      echo "::endgroup::"
    fi

    # Only keep shell alive in interactive mode if requested
    if [ "$IS_CI" != "true" ] && [ "$KEEP_CONTAINER" = "true" ]; then
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
    echo "::notice::==> Command completed successfully in ${DURATION}s"
    if [ "$KEEP_CONTAINER" = "true" ]; then
      echo "::notice::==> Keeping container alive - use 'docker exec -it <id> bash' for further interaction"
      exec bash -l
    fi
  fi

  exit 0
else
  # Interactive mode
  if [ "$IS_GITHUB_ACTIONS" != "true" ]; then
    echo "::notice::==> Starting interactive shell..."
    echo "::notice::    Tip: Run 'makepkg -si' to build and install AUR packages"
  fi

  exec bash -l
fi
