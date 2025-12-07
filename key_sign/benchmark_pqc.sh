#!/bin/bash

# ==========================================
# PQ vs Classical Benchmark Script (Adjusted)
# ==========================================

# Check if the correct number of arguments is provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <pq/classical> <algorithm> <file_to_be_signed> [ecdsa_curve]"
    echo "Example: $0 pq ml-dsa-65 message.txt"
    echo "Example: $0 classical rsa message.txt"
    echo "Example: $0 classical ecdsa message.txt prime256v1"
    exit 1
fi

TYPE=$1        # "pq" or "classical"
ALGORITHM=$2   # Algorithm name (e.g., rsa, ml-dsa-65, falcon-512)
MESSAGE=$3     # File to be signed
CURVE_ARG=$4   # Optional: Curve for ECDSA (default: prime256v1)

# Validate input type
if [[ "$TYPE" != "pq" && "$TYPE" != "classical" ]]; then
    echo "Error: First parameter must be 'pq' or 'classical'."
    exit 1
fi

# Define filenames (using a temp prefix to avoid overwriting real keys)
KEY="bench_temp_${TYPE}_${ALGORITHM}.key"
PUBKEY="bench_temp_${TYPE}_${ALGORITHM}.pub"
SIGNATURE="bench_temp_${TYPE}_${ALGORITHM}.sig"
NUM_ITERATIONS=100

# Function to clean up files on exit
cleanup() {
    rm -f "$KEY" "$PUBKEY" "$SIGNATURE"
}
trap cleanup EXIT

# --------------------------------------
# 1. Key Generation
# --------------------------------------
echo "--- Generating temporary key pair for $ALGORITHM ---"

if [ "$TYPE" == "pq" ]; then
    # OQS Provider Generation
    openssl genpkey -provider oqsprovider -algorithm "$ALGORITHM" -out "$KEY" > /dev/null 2>&1
    openssl pkey -provider oqsprovider -in "$KEY" -pubout -out "$PUBKEY" > /dev/null 2>&1
else
    # Classical Generation
    if [ "$ALGORITHM" == "ecdsa" ]; then
        # Use provided curve or default to prime256v1 (P-256)
        CURVE="${CURVE_ARG:-prime256v1}"
        echo "Using ECDSA Curve: $CURVE"
        openssl ecparam -name "$CURVE" -genkey -noout -out "$KEY" > /dev/null 2>&1
        openssl pkey -in "$KEY" -pubout -out "$PUBKEY" > /dev/null 2>&1
    elif [ "$ALGORITHM" == "rsa" ]; then
        # Default RSA to 3072 bits for fair security comparison
        openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -out "$KEY" > /dev/null 2>&1
        openssl pkey -in "$KEY" -pubout -out "$PUBKEY" > /dev/null 2>&1
    else
        # Generic Classical Fallback
        openssl genpkey -algorithm "$ALGORITHM" -out "$KEY" > /dev/null 2>&1
        openssl pkey -in "$KEY" -pubout -out "$PUBKEY" > /dev/null 2>&1
    fi
fi

# Sanity Check: Did key generation work?
if [ ! -f "$KEY" ]; then
    echo "Error: Failed to generate key. Check if algorithm name '$ALGORITHM' is correct."
    exit 1
fi

# --------------------------------------
# 2. Signing Benchmark
# --------------------------------------
echo "Benchmarking SIGNING ($NUM_ITERATIONS iterations)..."
START_TIME=$(date +%s.%N)

for ((i=1; i<=NUM_ITERATIONS; i++)); do
    if [ "$TYPE" == "pq" ]; then
        # PQ: Requires provider, usually no digest flag needed (algo specific)
        openssl dgst -provider oqsprovider -sign "$KEY" -out "$SIGNATURE" "$MESSAGE" > /dev/null 2>&1
    else
        # Classical: Requires explicit digest (SHA256)
        openssl dgst -sha256 -sign "$KEY" -out "$SIGNATURE" "$MESSAGE" > /dev/null 2>&1
    fi
done

END_TIME=$(date +%s.%N)
SIGN_ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc)
SIGN_PER_SECOND=$(echo "$NUM_ITERATIONS / $SIGN_ELAPSED_TIME" | bc -l)

# --------------------------------------
# 3. Verification Benchmark
# --------------------------------------
echo "Benchmarking VERIFICATION ($NUM_ITERATIONS iterations)..."
START_TIME=$(date +%s.%N)

for ((i=1; i<=NUM_ITERATIONS; i++)); do
    if [ "$TYPE" == "pq" ]; then
        # PQ Verification
        openssl dgst -provider oqsprovider -verify "$PUBKEY" -signature "$SIGNATURE" "$MESSAGE" > /dev/null 2>&1
    else
        # Classical Verification
        openssl dgst -sha256 -verify "$PUBKEY" -signature "$SIGNATURE" "$MESSAGE" > /dev/null 2>&1
    fi
done

END_TIME=$(date +%s.%N)
VERIFY_ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc)
VERIFY_PER_SECOND=$(echo "$NUM_ITERATIONS / $VERIFY_ELAPSED_TIME" | bc -l)

# --------------------------------------
# 4. Results
# --------------------------------------
# Formatting output with printf for cleaner alignment
echo ""
echo "======================================="
echo "   Benchmark Results: $ALGORITHM"
echo "======================================="
printf "%-20s %s\n" "Metric" "Value"
echo "---------------------------------------"
printf "%-20s %.4f seconds\n" "Sign Total Time:" "$SIGN_ELAPSED_TIME"
printf "%-20s %.2f ops/sec\n" "Sign Speed:" "$SIGN_PER_SECOND"
echo "---------------------------------------"
printf "%-20s %.4f seconds\n" "Verify Total Time:" "$VERIFY_ELAPSED_TIME"
printf "%-20s %.2f ops/sec\n" "Verify Speed:" "$VERIFY_PER_SECOND"
echo "======================================="
echo ""
