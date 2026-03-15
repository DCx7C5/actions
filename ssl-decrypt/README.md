# ssl-decrypt

Composite GitHub Action to decrypt OpenSSL-encrypted input from either:
- a file path, or
- an inline value/secret.

It can auto-detect input type and output encoding, then returns plaintext output (text or base64 for binary).

## What this action does

1. Masks sensitive inputs (`enc_input`, `passphrase`, `salt`) in logs.
2. Validates `type` and `encoding` inputs.
3. Detects input type when `type: auto`.
4. Detects output encoding when `encoding: auto`.
5. Decrypts with `openssl enc -aes-256-cbc -d`.
6. Optionally cleans up encrypted source file if `type` resolves to `file`.

## Inputs

| Input        | Required | Default | Description                                                                   |
|--------------|----------|---------|-------------------------------------------------------------------------------|
| `enc_input`  | yes      | -       | Encrypted file path or inline encrypted value                                 |
| `passphrase` | yes      | -       | Password for OpenSSL decryption                                               |
| `salt`       | no       | `''`    | Optional salt passed to OpenSSL (`-S`)                                        |
| `type`       | no       | `auto`  | `auto`, `file`, `inline` (also accepts aliases `secret`, `value`, `variable`) |
| `encoding`   | no       | `auto`  | `auto`, `binary`, or `text`                                                   |
| `cleanup`    | no       | `true`  | Securely delete encrypted input file (file mode only)                         |

## Outputs

| Output                  | Description                                      |
|-------------------------|--------------------------------------------------|
| `type`                  | Resolved input type (`file` or `inline`)         |
| `encoding`              | Resolved output encoding (`binary` or `text`)    |
| `decrypted_content`     | Decrypted text output                            |
| `decrypted_content_b64` | Base64-encoded decrypted bytes for binary output |

## Environment and dependencies

- Requires `bash` and `openssl` in the runner environment.
- Uses `shred` for secure deletion when available, otherwise falls back to `rm`.

## Usage examples

## Example: decrypt inline encrypted value

```yaml
- name: Decrypt inline secret
  id: dec_inline
  uses: ./ssl-decrypt
  with:
    enc_input: ${{ secrets.ENCRYPTED_VALUE }}
    passphrase: ${{ secrets.ENCRYPTION_PASS }}
    type: inline
    encoding: text

- name: Use decrypted value
  run: echo "${{ steps.dec_inline.outputs.decrypted_content }}"
```

## Example: decrypt encrypted file and auto-cleanup

```yaml
- name: Decrypt file
  id: dec_file
  uses: ./ssl-decrypt
  with:
    enc_input: ./secret.txt.enc
    passphrase: ${{ secrets.ENCRYPTION_PASS }}
    type: file
    encoding: text
    cleanup: 'true'

- name: Print decrypted content
  run: echo "${{ steps.dec_file.outputs.decrypted_content }}"
```

## Example: binary output handling

```yaml
- name: Decrypt binary payload
  id: dec_bin
  uses: ./ssl-decrypt
  with:
    enc_input: ${{ secrets.ENCRYPTED_BINARY }}
    passphrase: ${{ secrets.ENCRYPTION_PASS }}
    type: inline
    encoding: binary

- name: Restore binary file
  shell: bash
  run: |
    printf '%s' "${{ steps.dec_bin.outputs.decrypted_content_b64 }}" | base64 -d > restored.bin
```

## Common failures

- `enc_input cannot be empty`: required input is missing.
- `Invalid 'type' input`: unsupported `type` value.
- `Invalid 'format' input`: unsupported `encoding` value.
- OpenSSL decryption returns empty/invalid output: wrong `passphrase`, wrong mode, or mismatched encrypted data.

## Quick verification

Use a follow-up step to verify resolved mode and output presence:

```yaml
- name: Verify decrypt outputs
  run: |
    echo "type=${{ steps.dec_inline.outputs.type }}"
    echo "encoding=${{ steps.dec_inline.outputs.encoding }}"
    test -n "${{ steps.dec_inline.outputs.decrypted_content }}" || test -n "${{ steps.dec_inline.outputs.decrypted_content_b64 }}"
```

