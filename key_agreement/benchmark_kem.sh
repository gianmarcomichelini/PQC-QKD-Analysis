#!/bin/bash

# ==========================================
# Benchmark: ML-KEM (PQ) vs ECDH (Classical)
# ==========================================
#
# Usage:
#   ./benchmark_kem.sh <pq/classical> <algorithm>
#
# Examples:
#   ./benchmark_kem.sh pq ml-kem-512
#   ./benchmark_kem.sh classical ecdh

OPENSSL_BIN="openssl"
NUM_ITERATIONS=100

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <pq/classical> <algorithm>"
    exit 1
fi

TYPE="$1"       # "pq" or "classical"
ALGORITHM="$2"  # ml-kem-512, ml-kem-768, ml-kem-1024, ecdh

if [ "$TYPE" != "pq" ] && [ "$TYPE" != "classical" ]; then
    echo -e "${RED}Error: First parameter must be 'pq' or 'classical'.${NC}"
    exit 1
fi

# Define Filenames (Temporary)
PRIVKEY="bench_kem_priv.pem"
PUBKEY="bench_kem_pub.pem"
CIPHERTEXT="bench_kem_ct.bin"
SECRET_SENDER="bench_kem_ss_sender.bin"
SECRET_RECEIVER="bench_kem_ss_receiver.bin"

ALICE_KEY="bench_alice.key"
ALICE_PUB="bench_alice.pub"
BOB_KEY="bench_bob.key"
BOB_PUB="bench_bob.pub"
SECRET_ALICE="bench_secret_alice.bin"
SECRET_BOB="bench_secret_bob.bin"

# Cleanup function to remove temp files on exit
cleanup() {
    rm -f $PRIVKEY $PUBKEY $CIPHERTEXT $SECRET_SENDER $SECRET_RECEIVER
    rm -f $ALICE_KEY $ALICE_PUB $BOB_KEY $BOB_PUB $SECRET_ALICE $SECRET_BOB
}
trap cleanup EXIT

echo -e "${CYAN}Benchmarking Key Exchange ($TYPE / $ALGORITHM)${NC}"
echo "Iterations: $NUM_ITERATIONS"
echo "---------------------------------------------------------------"

###############################################################################
# 1. Key Generation
###############################################################################

if [ "$TYPE" = "pq" ]; then
    # Validate PQ Algorithm
    case "$ALGORITHM" in
        ml-kem-512|ml-kem-768|ml-kem-1024) ;;
        *)
            echo -e "${RED}Error: Unsupported PQ algorithm '$ALGORITHM'.${NC}"
            echo "Supported: ml-kem-512, ml-kem-768, ml-kem-1024"
            exit 1
            ;;
    esac

    echo "Generating ML-KEM key pair..."
    "$OPENSSL_BIN" genpkey -provider oqsprovider -algorithm "$ALGORITHM" \
        -provparam ml-kem.retain_seed=no \
        -out "$PRIVKEY" >/dev/null 2>&1

    "$OPENSSL_BIN" pkey -provider oqsprovider -in "$PRIVKEY" -pubout -out "$PUBKEY" >/dev/null 2>&1

else
    # Classical: ECDH (P-256)
    if [ "$ALGORITHM" != "ecdh" ]; then
        echo -e "${RED}Error: For classical type, only 'ecdh' is supported.${NC}"
        exit 1
    fi

    echo "Generating ECDH P-256 key pairs for Alice and Bob..."
    "$OPENSSL_BIN" ecparam -name prime256v1 -genkey -noout -out "$ALICE_KEY" >/dev/null 2>&1
    "$OPENSSL_BIN" pkey -in "$ALICE_KEY" -pubout -out "$ALICE_PUB" >/dev/null 2>&1

    "$OPENSSL_BIN" ecparam -name prime256v1 -genkey -noout -out "$BOB_KEY" >/dev/null 2>&1
    "$OPENSSL_BIN" pkey -in "$BOB_KEY" -pubout -out "$BOB_PUB" >/dev/null 2>&1
fi

###############################################################################
# 2. Benchmark Loop
###############################################################################

if [ "$TYPE" = "pq" ]; then
    # --- PQ BENCHMARK (Encapsulate / Decapsulate) ---
    
    echo "Benchmarking Encapsulation (Sender)..."
    START_TIME=$(date +%s.%N)
    for ((i=1; i<=NUM_ITERATIONS; i++)); do
        "$OPENSSL_BIN" pkeyutl -provider oqsprovider \
            -encap \
            -pubin -inkey "$PUBKEY" \
            -out "$CIPHERTEXT" \
            -secret "$SECRET_SENDER" >/dev/null 2>&1
    done
    END_TIME=$(date +%s.%N)
    ENC_ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
    ENC_PER_SECOND=$(echo "$NUM_ITERATIONS / $ENC_ELAPSED_TIME" | bc -l)

    echo "Benchmarking Decapsulation (Receiver)..."
    START_TIME=$(date +%s.%N)
    for ((i=1; i<=NUM_ITERATIONS; i++)); do
        "$OPENSSL_BIN" pkeyutl -provider oqsprovider \
            -decap \
            -inkey "$PRIVKEY" \
            -in "$CIPHERTEXT" \
            -secret "$SECRET_RECEIVER" >/dev/null 2>&1
    done
    END_TIME=$(date +%s.%N)
    DEC_ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
    DEC_PER_SECOND=$(echo "$NUM_ITERATIONS / $DEC_ELAPSED_TIME" | bc -l)

else
    # --- CLASSICAL BENCHMARK (Derive / Derive) ---
    
    echo "Benchmarking ECDH Derive (Alice)..."
    START_TIME=$(date +%s.%N)
    for ((i=1; i<=NUM_ITERATIONS; i++)); do
        "$OPENSSL_BIN" pkeyutl -derive -inkey "$ALICE_KEY" -peerkey "$BOB_PUB" \
            -out "$SECRET_ALICE" >/dev/null 2>&1
    done
    END_TIME=$(date +%s.%N)
    ENC_ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
    ENC_PER_SECOND=$(echo "$NUM_ITERATIONS / $ENC_ELAPSED_TIME" | bc -l)

    echo "Benchmarking ECDH Derive (Bob)..."
    START_TIME=$(date +%s.%N)
    for ((i=1; i<=NUM_ITERATIONS; i++)); do
        "$OPENSSL_BIN" pkeyutl -derive -inkey "$BOB_KEY" -peerkey "$ALICE_PUB" \
            -out "$SECRET_BOB" >/dev/null 2>&1
    done
    END_TIME=$(date +%s.%N)
    DEC_ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
    DEC_PER_SECOND=$(echo "$NUM_ITERATIONS / $DEC_ELAPSED_TIME" | bc -l)
fi

###############################################################################
# 3. Results Output
###############################################################################

echo
echo "==============================================================="
echo -e "Benchmark Results: ${GREEN}$ALGORITHM${NC}"
echo "---------------------------------------------------------------"
if [ "$TYPE" = "pq" ]; then
    printf "%-35s %10.4f sec  (%10.2f ops/sec)\n" "Encapsulation (Sender):" "$ENC_ELAPSED_TIME" "$ENC_PER_SECOND"
    printf "%-35s %10.4f sec  (%10.2f ops/sec)\n" "Decapsulation (Receiver):" "$DEC_ELAPSED_TIME" "$DEC_PER_SECOND"
else
    printf "%-35s %10.4f sec  (%10.2f ops/sec)\n" "Derive Secret (Alice):" "$ENC_ELAPSED_TIME" "$ENC_PER_SECOND"
    printf "%-35s %10.4f sec  (%10.2f ops/sec)\n" "Derive Secret (Bob):" "$DEC_ELAPSED_TIME" "$DEC_PER_SECOND"
fi
echo "==============================================================="
echo
