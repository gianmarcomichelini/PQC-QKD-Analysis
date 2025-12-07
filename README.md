# Post-Quantum Cryptography (PQC) Toolkit

A comprehensive suite of tools and simulations for exploring, testing, and benchmarking Post-Quantum Cryptographic algorithms. This toolkit provides both classical and quantum-resistant implementations for digital signatures, key encapsulation mechanisms, and quantum key distribution protocols.

## Overview

As quantum computers advance, they pose a significant threat to current cryptographic systems. This toolkit helps developers, researchers, and organizations:

- Understand the differences between classical and post-quantum cryptography
- Benchmark performance characteristics of various algorithms
- Test quantum-resistant implementations
- Prepare for the post-quantum cryptographic transition
- Learn about quantum key distribution through interactive simulations

## What's Included

This repository contains four main components:

### Digital Signatures Module

Tools for testing and benchmarking post-quantum digital signature algorithms (ML-DSA, Falcon, SLH-DSA) versus classical algorithms (RSA, ECDSA).

**Key Features:**

- Performance benchmarking (signing/verification speed)
- Key and signature size analysis
- Interactive sign and verify manager
- Support for multiple security levels

**Algorithms Supported:**

- **Post-Quantum**: ML-DSA-44/65/87, Falcon-512/1024, SLH-DSA, SPHINCS+
- **Classical**: RSA-2048/3072/4096, ECDSA P-256/384/521

### Key Encapsulation Module (KEM)

Implementation and testing of ML-KEM (Kyber) for quantum-resistant key exchange, with comparisons to classical ECDH.

**Key Features:**

- ML-KEM key generation (512/768/1024 security levels)
- Complete encapsulation/decapsulation simulation
- Performance benchmarking vs ECDH
- Visual verification of shared secrets

**Algorithms Supported:**

- **Post-Quantum**: ML-KEM-512/768/1024
- **Classical**: ECDH with P-256/384/521 curves

### BB84 Quantum Key Distribution Simulator

Educational Python simulation of the BB84 protocol, demonstrating quantum cryptography principles.

**Key Features:**

- Step-by-step protocol visualization
- Eavesdropping detection (QBER analysis)
- Decoy state simulation
- Interactive configuration

## Module Documentation

Each module has its own detailed README with usage instructions, examples, and best practices:

### Setup Files

- **Location**: `setup/`
- **README**: [Setup Documentation](setup/README.md)

### Digital Signatures

- **Location**: `key_sign/`
- **README**: [Digital Signatures Documentation](key_sign/README.md)

### Key Agreement

- **Location**: `key_agreement/`
- **README**: [Key Agreement Documentation](key_agreement/README.md)

### BB84 QKD Simulator

- **Location**: `qkd/`
- **README**: [BB84 Simulator Documentation](qkd/README.md)

## Acknowledgments

- **NIST** for the Post-Quantum Cryptography Standardization project
- **Open Quantum Safe** for the liboqs library and OQS provider
- **OpenSSL** team for cryptographic infrastructure
- **Laboratory materials** courtesy of Prof. Atzeni and Sisinni, Polytechnic University of Turin