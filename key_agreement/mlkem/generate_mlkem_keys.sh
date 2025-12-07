#!/bin/bash

# ==========================================
# ML-KEM (Kyber) Key Generation Script
# ==========================================

# Define the output subdirectory
OUTPUT_DIR="./keys"

# Create the directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo -e "\n--- Starting ML-KEM Key Generation ---\n"
echo "Saving keys to: $OUTPUT_DIR/"

# Loop through the specific ML-KEM security levels
for LEVEL in 512 768 1024; do
    # OpenSSL Algorithm Name (must include hyphens)
    ALGO="ml-kem-$LEVEL"
    
    # Output Filenames (saved in ./keys/)
    PRIV_FILE="${OUTPUT_DIR}/mlkem${LEVEL}_priv.pem"
    PUB_FILE="${OUTPUT_DIR}/mlkem${LEVEL}_pub.pem"

    echo "Processing $ALGO..."

    # 1. Generate Private Key
    # Using -provparam ml-kem.retain_seed=no as requested
    openssl genpkey -provider oqsprovider -algorithm "$ALGO" \
        -provparam ml-kem.retain_seed=no \
        -out "$PRIV_FILE"

    if [ $? -eq 0 ]; then
        # 2. Derive Public Key
        openssl pkey -provider oqsprovider -in "$PRIV_FILE" -pubout -out "$PUB_FILE"
        
        echo "  [Success] Private Key: $PRIV_FILE"
        echo "  [Success] Public Key:  $PUB_FILE"
    else
        echo "  [Error] Failed to generate key for $ALGO"
        exit 1
    fi
    echo "----------------------------------------"
done

echo -e "\nAll ML-KEM keys have been generated in '$OUTPUT_DIR'."
