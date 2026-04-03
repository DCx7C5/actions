# docker-build-image

[![Test Docker Build/Push](https://github.com/DCx7C5/actions/actions/workflows/test_docker.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_docker.yml)
[![Test Arch Run Cmd](https://github.com/DCx7C5/actions/actions/workflows/test_arch_run_cmd.yml/badge.svg)](https://github.com/DCx7C5/actions/actions/workflows/test_arch_run_cmd.yml)

> Composite GitHub Action to build the Arch Linux Docker image used for AUR builds.

## Inputs

| Input                       | Required | Default | Description                                                      |
|-----------------------------|----------|---------|------------------------------------------------------------------|
| `image-tag`                 | **yes**  | `''`    | Docker image tag to build.                                       |
| `image-version`             | **yes**  | `''`    | Docker image version tag (e.g. `latest`).                        |
| `dockerfile-path`           | no       | `''`    | Path to the Dockerfile.                                          |
| `image-working-directory`   | no       | `''`    | Working directory inside the container.                          |
| `runtime-working-directory` | no       | `''`    | Working directory for the build context (defaults to workspace). |
| `gpg-home`                  | no       | `''`    | GPG home directory.                                              |
| `ccache-dir`                | no       | `''`    | ccache directory for build caching.                              |
| `user`                      | no       | `''`    | User name to create inside the container.                        |
| `group`                     | no       | `''`    | Group name to create inside the container.                       |
| `uid`                       | no       | `''`    | User ID to use inside the container.                             |
| `gid`                       | no       | `''`    | Group ID to use inside the container.                            |
| `gpg-key`                   | no       | `''`    | GPG private key to import into the container.                    |
| `gh-token`                  | no       | `''`    | GitHub token for API access.                                     |
| `build-args`                | no       | `''`    | Newline-separated additional `docker build` arguments.           |

## Outputs

| Output          | Description                            |
|-----------------|----------------------------------------|
| `image`         | Full Docker image tag that was built.  |
| `image-tag`     | Docker image tag (without version).    |
| `image-version` | Docker image version tag.              |

## Example

```yaml
- name: Build Docker image
  id: build
  uses: ./docker-build-image
  with:
    image-tag: 'my-image'
    image-version: 'latest'
    dockerfile-path: Dockerfile
    user: runner
    group: runner
    uid: '1001'
    gid: '127'
    gh-token: ${{ secrets.GITHUB_TOKEN }}
```

