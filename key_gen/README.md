# Key Generation

### Purpose

This script automates the execution of `generate_keys.sh` in each cryptographic algorithm subdirectory, streamlining the process of generating keypairs across all available algorithms.


### Prerequisites

- OpenSSL 3.0 or later
- OQS Provider for OpenSSL (for post-quantum algorithms)
- Each subdirectory must contain its own `generate_keys.sh` script
- Properly configured environment variables for OQS provider



### Algorithm Coverage

When all subdirectories are present, this script will generate keys for:

**Post-Quantum Algorithms:**
- Falcon-512, Falcon-1024
- ML-DSA-44, ML-DSA-65, ML-DSA-87
- SPHINCS+ variants (SHA2, SHAKE)

**Classical Algorithms:**
- RSA (2048, 3072, 4096 bits)
- ECDSA (P-256, P-384, P-521)

### Usage


**Basic Execution:**

```bash
chmod +x keygen.sh
./keygen.sh
```

**What It Does:**

1. Scans all subdirectories for `generate_keys.sh` files
2. Sets execute permissions on each found script
3. Enters each subdirectory and executes its key generation script
4. Returns to the parent directory after each execution
5. Skips directories that don't contain `generate_keys.sh` with a warning

### Example Output

```
==========================================
  Cryptographic Key Generation
==========================================

[1/2] Setting execute permissions on all generate_keys.sh files...

  Set permissions: falcon/generate_keys.sh
  Set permissions: mldsa/generate_keys.sh
  Set permissions: rsa_ecdsa/generate_keys.sh
  Set permissions: sphincs/generate_keys.sh

[2/2] Executing key generation in each directory...

==========================================
  Directory: falcon
==========================================
Generating Falcon keypairs...
Falcon-512 keys generated successfully
Falcon-1024 keys generated successfully

==========================================
  Directory: mldsa
==========================================
Generating ML-DSA keypairs...
ML-DSA-44 keys generated successfully
ML-DSA-65 keys generated successfully
ML-DSA-87 keys generated successfully

==========================================
  Directory: rsa_ecdsa
==========================================
Generating RSA and ECDSA keypairs...
RSA-2048 keys generated successfully
ECDSA P-256 keys generated successfully

Warning: generate_keys.sh not found in empty_folder, skipping...

==========================================
  All Key Generation Complete
==========================================
```

