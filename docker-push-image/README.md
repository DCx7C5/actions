# docker-push-image

[![Test Docker Build/Push](https://github.com/DCx7C5/actions/actions/workflows/test_docker.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_docker.yml)
[![Test Arch Run Cmd](https://github.com/DCx7C5/actions/actions/workflows/test_arch_run_cmd.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_arch_run_cmd.yml)

> Composite GitHub Action to push a Docker image to a container registry (e.g. GHCR, Docker Hub).

## Inputs

| Input           | Required | Default   | Description                                               |
|-----------------|----------|-----------|-----------------------------------------------------------|
| `image-tag`     | **yes**  | –         | Name of the Docker image to push.                         |
| `image-version` | **yes**  | `latest`  | Version tag of the Docker image.                          |
| `registry`      | no       | `ghcr.io` | URL of the Docker registry.                               |
| `gh-token`      | no       | `''`      | GitHub Token for registry authentication.                 |
| `user`          | no       | `''`      | Username for registry login (defaults to `github.actor`). |

## Outputs

| Output       | Description                                                          |
|--------------|----------------------------------------------------------------------|
| `full_image` | Full image reference that was pushed (e.g. `ghcr.io/owner/img:tag`). |

## Example

```yaml
- name: Push Docker image
  uses: ./docker-push-image
  with:
    image-tag: 'my-image'
    image-version: 'latest'
    registry: 'ghcr.io'
    gh-token: ${{ secrets.GITHUB_TOKEN }}
```

