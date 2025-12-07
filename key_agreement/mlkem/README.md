# 🔐 ML-KEM (Kyber) Key Generation

This module handles the generation of Quantum-Resistant Key Encapsulation Mechanism (KEM) keys using the **ML-KEM** (Module-Lattice-based Key Encapsulation Mechanism) algorithm, formerly known as Kyber.

It generates keys for all three standardized security levels:
- **ML-KEM-512** (NIST Security Level 1)
- **ML-KEM-768** (NIST Security Level 3)
- **ML-KEM-1024** (NIST Security Level 5)

---

## 🚀 Usage

### 1. Run the Generator

This script automatically generates private and public keys for all three levels (512, 768, 1024).

```bash
chmod +x generate_mlkem_keys.sh
./generate_mlkem_keys.sh
```

### 2. Output

The keys are saved in the script directory with the following structure:

| Algorithm | Private Key | Public Key |
|-----------|-------------|------------|
| ML-KEM-512 | `mlkem512_priv.pem` | `mlkem512_pub.pem` |
| ML-KEM-768 | `mlkem768_priv.pem` | `mlkem768_pub.pem` |
| ML-KEM-1024 | `mlkem1024_priv.pem` | `mlkem1024_pub.pem` |
