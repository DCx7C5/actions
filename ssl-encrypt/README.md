# ssl-encrypt

Composite GitHub Action to encrypt files or data using SSL for secure transfer or storage.

## What this action does

- Accepts an input file and a certificate/key.
- Encrypts the file using OpenSSL.
- Outputs the encrypted file for further workflow steps.

## Inputs

| Input         | Required | Default | Description                                 |
|---------------|----------|---------|---------------------------------------------|
| `input_file`  | yes      | -       | Path to the file to encrypt.                |
| `cert`        | yes      | -       | Path to the SSL certificate or public key.  |
| `output_file` | no       | -       | Optional: path for the encrypted output.    |

## Outputs

| Output         | Description                        |
|----------------|------------------------------------|
| `output_file`  | Path to the encrypted file.         |

## Dependencies

- `openssl`
- `bash`

## Operation flow

1. Validate that `input_file` and `cert` exist and are readable.
2. Run `openssl smime -encrypt -binary -aes256 -in <input_file> -out <output_file> -outform DER <cert>`.
3. Set output `output_file` to the encrypted file path.

## Example

```yaml
- name: Encrypt file
  uses: ./ssl-encrypt
  with:
    input_file: data.txt
    cert: cert.pem
    output_file: data.txt.enc
```

## Common failures

- `input_file` or `cert` does not exist or is not readable.
- OpenSSL is not installed or misconfigured.
- Output path is not writable.

## Quick verification

```yaml
- name: Verify encrypted file
  run: |
    test -f data.txt.enc
    file data.txt.enc
```
