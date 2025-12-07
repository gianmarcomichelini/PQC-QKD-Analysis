# SPHINCS+ Key Generation Script

Generates SPHINCS+ post-quantum keypairs using the OQS OpenSSL provider.

## Supported Algorithms

- **SHA2-128f / SHA2-128s (Level 1)**  
  - `sphincssha2128fsimple`, `sphincssha2128ssimple`

- **SHA2-192f (Level 3)**  
  - `sphincssha2192fsimple`

- **SHAKE128 (Level 1)**  
  - `sphincsshake128fsimple`

## Usage

```sh
./generate_sphincs_keys.sh
