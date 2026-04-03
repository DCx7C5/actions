# GitHub Actions

Central overview and status for all local GitHub Actions in this repository.

---

## Action Catalog & Test Status

| Action                                         | Description                              |                                                                                  Status                                                                                   |
|:-----------------------------------------------|:-----------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| [`arch-run-cmd`](./arch-run-cmd)               | Arch Linux container command runner      | [![test](https://github.com/DCx7C5/actions/actions/workflows/test_arch_run_cmd.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_arch_run_cmd.yml) |
| [`docker-build-image`](./docker-build-image)   | Build Docker image                       |       [![test](https://github.com/DCx7C5/actions/actions/workflows/test_docker.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_docker.yml)       |
| [`docker-push-image`](./docker-push-image)     | Push Docker image to registry            |       [![test](https://github.com/DCx7C5/actions/actions/workflows/test_docker.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_docker.yml)       |
| [`aur-json-packages`](./aur-json-packages)     | Manage JSON package dictionary           |    [![test](https://github.com/DCx7C5/actions/actions/workflows/test_json_pkgs.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_json_pkgs.yml)    |
| [`gpg-import`](./gpg-import)                   | Import GPG key (inline, file, keyserver) |   [![test](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml)   |
| [`gpg-setup-home`](./gpg-setup-home)           | Create & harden isolated GNUPGHOME       |   [![test](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml)   |
| [`gpg-preset-pass`](./gpg-preset-pass)         | Cache passphrase in gpg-agent            |   [![test](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml)   |
| [`gpg-set-ownertrust`](./gpg-set-ownertrust)   | Set ownertrust for GPG key               |   [![test](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml)   |
| [`git-configure-gnupg`](./git-configure-gnupg) | Configure Git for GPG signing            |   [![test](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_gpg_import.yml)   |
| [`ssl-encrypt`](./ssl-encrypt)                 | OpenSSL encryption                       |          [![test](https://github.com/DCx7C5/actions/actions/workflows/test_ssl.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_ssl.yml)          |
| [`ssl-decrypt`](./ssl-decrypt)                 | OpenSSL decryption                       |          [![test](https://github.com/DCx7C5/actions/actions/workflows/test_ssl.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_ssl.yml)          |

Additional actions (without dedicated test workflow):

| Action | Description |
|:-------|:------------|
| [`gh-create-release`](./gh-create-release) | Create/verify GitHub release |
| [`gh-upload-assets`](./gh-upload-assets) | Upload release assets |
| [`gpg-export-key`](./gpg-export-key) | Export GPG key |
| [`gpg-create-subkey`](./gpg-create-subkey) | Generate GPG subkey |
| [`gpg-sign-detached`](./gpg-sign-detached) | Detached-sign a file |
| [`gpg-decrypt`](./gpg-decrypt) | Decrypt a file |
| [`tg-notify`](./tg-notify) | Telegram notification |
| [`tar-create`](./tar-create) | Create tar archive |

---

## Quick Start

```yaml
jobs:
  example:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - name: Import GPG key
        uses: ./gpg-import
        with:
          key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg-pass: ${{ secrets.GPG_PASSPHRASE }}
```

---

## Conventions & Notes

- Boolean inputs are always strings (`'true'`/`'false'`)
- Each action is documented in its own directory (`README.md`)
- Invalid inputs produce `::error::` messages
- Input/output changes must be documented in the action's README

---

## For Maintainers

- Keep `action.yml` descriptions short; put details in the README
- When changing inputs/outputs: update the action README in the same commit
- Prefer small validation checks over silently ignoring bad input
