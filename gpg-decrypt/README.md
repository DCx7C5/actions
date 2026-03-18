# gpg-decrypt

Composite GitHub Action to decrypt files using GPG for CI/CD workflows.

## What this action does

- Accepts an encrypted file and a GPG key or passphrase.
- Decrypts the file using GPG.
- Outputs the decrypted file for further workflow steps.

## Inputs

| Input         | Required | Default | Description                                 |
|---------------|----------|---------|---------------------------------------------|
| `input_file`  | yes      | -       | Path to the encrypted file.                 |
| `passphrase`  | yes      | -       | Passphrase or key for decryption.           |
| `output_file` | no       | -       | Optional: path for the decrypted output.    |

## Outputs

| Output         | Description                        |
|----------------|------------------------------------|
| `output_file`  | Path to the decrypted file.         |

## Dependencies

- `gpg`
- `bash`

## Operation flow

1. Validate that `input_file` exists and is readable.
2. Run `gpg --batch --yes --passphrase <passphrase> -o <output_file> -d <input_file>`.
3. Set output `output_file` to the decrypted file path.

## Example

```yaml
- name: Decrypt secret file
  uses: ./gpg-decrypt
  with:
    input_file: secrets.enc
    passphrase: ${{ secrets.GPG_PASSPHRASE }}
    output_file: secrets.txt
```

## Common failures

- `input_file` does not exist or is not readable.
- Passphrase is incorrect or key is missing.
- GPG is not installed or misconfigured.

## Quick verification

```yaml
- name: Verify decrypted file
  run: |
    test -f secrets.txt
    head -n 5 secrets.txt
```
