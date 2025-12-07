# Quantum-Safe OpenSSL Setup Guide

This guide provides instructions for installing and configuring OpenSSL with the Open Quantum Safe (OQS) provider, enabling post-quantum cryptographic algorithms.

## Installation Steps

### Step 1: Run the Installation Script

```bash
chmod +x setup_openssl_with_oqs.sh
./setup_openssl_with_oqs.sh
```

### Step 2: Configure Environment Variables

#### For Bash Users

```bash
bash
chmod +x set_environment_variables_bash.sh
./set_environment_variables_bash.sh
source ~/.bashrc
```

#### For Zsh Users (Kali Linux)

```bash
zsh
chmod +x set_environment_variables_zsh.sh
./set_environment_variables_zsh.sh
source ~/.zshrc
```

## Verification

### Verify OpenSSL Installation

```bash
openssl version
```

### Verify OQS Provider

```bash
openssl list -providers -verbose -provider oqsprovider
```

### List Available Algorithms

**Post-Quantum Signature Algorithms:**

```bash
openssl list -signature-algorithms -provider oqsprovider
```

**Post-Quantum KEM Algorithms:**

```bash
openssl list -kem-algorithms -provider oqsprovider
```

## Troubleshooting

**Issue: OpenSSL command not found**

```bash
source ~/.bashrc  # For bash
source ~/.zshrc   # For zsh
```

**Issue: OQS provider not loading**

```bash
echo $OPENSSL_CONF
echo $OPENSSL_MODULES
```

Both should return paths to your build directory.