# Post-Quantum Digital Signatures Toolkit

This toolkit provides scripts to benchmark performance, analyze key/signature sizes, and test signing/verification workflows for Post-Quantum algorithms (e.g., ML-DSA, Falcon, SLH-DSA) vs Classical algorithms (RSA, ECDSA).

## Prerequisites

Before using this toolkit, ensure you have:

1. OpenSSL with OQS Provider installed and configured
2. Environment variables properly set
3. Key pairs generated in the `../key_gen/` directory structure

## Performance Benchmarking

Use the `benchmark_pqc.sh` script to measure and compare the **Signing** and **Verification** speed of Post-Quantum vs. Classical algorithms.

### Usage Syntax

```bash
chmod +x benchmark_pqc.sh
./benchmark_pqc.sh <type> <algorithm> <file_to_sign> [optional_curve]
```

| Parameter | Description |
|-----------|-------------|
| `<type>` | Define the category: `pq` (Post-Quantum) or `classical` (Standard) |
| `<algorithm>` | The algorithm name (e.g., `ml-dsa-65`, `rsa`, `falcon512`) |
| `<file_to_sign>` | The target file path (e.g., `message.txt`) |
| `[optional_curve]` | (ECDSA only) Specify curve like `prime256v1`, `secp384r1` |

### Examples

**Run a Post-Quantum Benchmark (ML-DSA)**
```bash
./benchmark_pqc.sh pq ml-dsa-65 message.txt
```

**Run a Classical Benchmark (RSA)**
```bash
./benchmark_pqc.sh classical rsa message.txt
```

**Run a Classical Benchmark (ECDSA)**
```bash
# Defaults to prime256v1 if no curve specified
./benchmark_pqc.sh classical ecdsa message.txt

# Specify a stronger curve (P-384)
./benchmark_pqc.sh classical ecdsa message.txt secp384r1
```

### Output

The script performs 100 iterations and outputs:
- Total elapsed time (seconds)
- Operations per second (Ops/Sec)

## Key and Signature Size Analysis

Use the `analyze_size.sh` script to measure the disk footprint (bandwidth cost) of Public Keys and Signatures.

### Usage Syntax

```bash
chmod +x analyze_size.sh
./analyze_size.sh <type> <algorithm> [optional_curve]
```

### Examples

**Analyze ML-DSA-65 (Post-Quantum)**
```bash
./analyze_size.sh pq ml-dsa-65
```

**Analyze Falcon-512 (Post-Quantum)**

Note: Use `falcon512` (no hyphen) for the algorithm name.

```bash
./analyze_size.sh pq falcon512
```

**Analyze RSA (Classical)**
```bash
./analyze_size.sh classical rsa
```

### Output

The script generates a temporary key pair and signature, calculates their size in Bytes/KB, and displays the total bandwidth cost.

## Signature and Verification Manager

The `sign_verify_manager.sh` script provides an interactive interface to sign and verify messages using any available algorithm from your `../key_gen/` directory.

### Features

- Interactive Menu: Select from available algorithms dynamically
- Complete Workflow: Performs both signing and verification in one execution

### Usage

```bash
chmod +x sign_verify_manager.sh
./sign_verify_manager.sh
```

### Example Output

```
[!] message.txt not found. Creating a dummy file...
--- Scanning for available keys in '../key_gen/' ---
Available Algorithms:
  [1] mldsa/ml-dsa-44.key
  [2] mldsa/ml-dsa-65.key
  [3] mldsa/ml-dsa-87.key
  [4] falcon/falcon512.key
  [5] rsa/rsa_4096.key
  [6] ecdsa/ecdsa_p256.key

Select an algorithm (enter number): 2

--- Configuration ---
Private Key: ../key_gen/mldsa/ml-dsa-65.key
Public Key:  ../key_gen/mldsa/ml-dsa-65.pub
Algorithm Type: PQC

--- Step 1: Signing ---
Executing: openssl dgst -provider oqsprovider -sign ../key_gen/mldsa/ml-dsa-65.key -out message.sig message.txt
[Success] Message signed. Signature saved to message.sig

--- Step 2: Verifying ---
Executing: openssl dgst -provider oqsprovider -verify ../key_gen/mldsa/ml-dsa-65.pub -signature message.sig message.txt
[Success] Signature Verified! The message is authentic.
```

### Supported Algorithms

#### Post-Quantum (PQC)

**ML-DSA (Module-Lattice Digital Signature Algorithm)**
- ml-dsa-44, ml-dsa-65, ml-dsa-87

**Falcon (Fast Fourier Lattice-based Compact Signatures)**
- falcon512, falcon1024

**SLH-DSA / SPHINCS+ (Stateless Hash-based Digital Signature Algorithm)**
- Various parameter sets

#### Classical

**RSA (Rivest–Shamir–Adleman)**
- 2048-bit, 3072-bit, 4096-bit

**ECDSA (Elliptic Curve Digital Signature Algorithm)**
- P-256, P-384, P-521 curves