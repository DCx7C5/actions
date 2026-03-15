# tag-create-and-push

Composite GitHub Action to create a Git tag locally and push it to `origin`, optionally with a GPG signature.

## What this action does

1. Masks sensitive inputs such as the passphrase and optional keygrip.
2. Validates that `version` is present.
3. Creates either:
   - an unsigned tag,
   - a signed tag without passphrase preset, or
   - a signed tag after presetting the passphrase in `gpg-agent`.
4. Pushes the created tag to `origin`.
5. Exposes the created tag name as output.

## Inputs

| Input         | Required | Default | Description                                         |
|---------------|----------|---------|-----------------------------------------------------|
| `version`     | yes      | -       | Tag name/version to create, e.g. `v1.2.3`.          |
| `commit_msg`  | no       | `''`    | Annotation message for the tag.                     |
| `fingerprint` | no       | `''`    | GPG fingerprint or email to use for signing.        |
| `pass`        | no       | `''`    | Passphrase for GPG signing key.                     |
| `sign`        | no       | `true`  | Whether to sign the tag with GPG.                   |
| `gpg_home`    | no       | `''`    | Path to `GNUPGHOME`.                                |
| `gpg_grp`     | no       | `''`    | Explicit keygrip used when presetting a passphrase. |

## Outputs

| Output | Description |
|---|---|
| `tag_name` | The created tag name. |

## Environment and dependencies

The runner must provide:

- `git`
- `gpg` for signed tags
- `/usr/lib/gnupg/gpg-preset-passphrase` when using `pass`

The action reads:

- `GNUPGHOME` from `inputs.gpg_home` or existing environment

## Tag creation modes

### Unsigned mode

Used when:

- `sign == 'false'`

Behavior:

- checks that the tag does not already exist
- creates a tag with `git tag`
- pushes to `origin`

### Signed mode without passphrase preset

Used when:

- `sign == 'true'`
- `pass == ''`

Behavior:

- creates a signed annotated tag with `git tag -s`
- optionally selects the signing key via `-u <fingerprint>`
- pushes to `origin`

### Signed mode with passphrase preset

Used when:

- `sign == 'true'`
- `pass != ''`

Behavior:

- looks up all secret keygrips, or uses `gpg_grp` if provided
- presets the passphrase in `gpg-agent`
- creates a signed annotated tag with `git tag -s`
- pushes to `origin`

## Examples

### Example: create and push unsigned tag

```yaml
- name: Create unsigned tag
  id: tag_create
  uses: ./tag-create-and-push
  with:
    sign: 'false'
    version: v1.2.3
    commit_msg: Release v1.2.3
```

### Example: create signed tag with imported GPG home

```yaml
- name: Create signed tag
  id: tag_create
  uses: ./tag-create-and-push
  env:
    GNUPGHOME: ${{ steps.gpg_import.outputs.gpg_home }}
  with:
    sign: 'true'
    version: v1.2.3
    commit_msg: Release v1.2.3
    pass: ${{ secrets.GPG_PASSPHRASE }}
```

### Example: select explicit signing key

```yaml
- name: Create signed tag with explicit key
  uses: ./tag-create-and-push
  with:
    version: v1.2.3
    fingerprint: ABCDEF1234567890ABCDEF1234567890ABCDEF12
    pass: ${{ secrets.GPG_PASSPHRASE }}
    gpg_home: ${{ steps.gpg_import.outputs.gpg_home }}
```

## Common failures

- `version input is required`: missing version/tag name.
- `Tag <name> already exists`: local tag already exists before creation.
- `Failed to create unsigned tag`: `git tag` failed.
- `Failed to create signed tag`: signing failed due to Git/GPG configuration, missing key, wrong passphrase, or unavailable agent.
- `Failed to push tag to repository`: remote push failed.

## Known caveats

- In unsigned mode the implementation currently starts with `TAG_ARGS=(-l "$TAG")`, which is unusual for tag creation and may not behave as intended on all Git versions.
- Push always targets `origin`; alternative remotes are not configurable.
- The action assumes a checked-out repository with writable remote credentials already configured.

## Verification

Use a follow-up step to inspect the created tag name:

```yaml
- name: Verify created tag
  run: |
    echo "Created tag: ${{ steps.tag_create.outputs.tag_name }}"
```


