#!/bin/bash

# ==========================================
# PQ Key & Signature Size Analyzer
# ==========================================

# Check arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <pq/classical> <algorithm> [ecdsa_curve]"
    echo "Example: $0 pq ml-dsa-65"
    echo "Example: $0 classical rsa"
    exit 1
fi

TYPE=$1
ALGO=$2
CURVE=$3
MESSAGE="size_test_msg.txt"

# Colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Temporary filenames
KEY_FILE="temp_size.key"
PUB_FILE="temp_size.pub"
SIG_FILE="temp_size.sig"

# Create a dummy message if not exists
if [ ! -f "$MESSAGE" ]; then
    echo "This is a dummy file to test signature sizes." > "$MESSAGE"
fi

# Function to clean up on exit
cleanup() {
    rm -f $KEY_FILE $PUB_FILE $SIG_FILE $MESSAGE
}
trap cleanup EXIT

echo -e "${CYAN}--- Generating Artifacts for Analysis ---${NC}"

# 1. Generate Keys
if [ "$TYPE" == "pq" ]; then
    ALGO=$(echo "$ALGO" | tr -d '-')
    openssl genpkey -provider oqsprovider -algorithm "$ALGO" -out "$KEY_FILE" >/dev/null 2>&1
    openssl pkey -provider oqsprovider -in "$KEY_FILE" -pubout -out "$PUB_FILE" >/dev/null 2>&1
    
    # Sign
    openssl dgst -provider oqsprovider -sign "$KEY_FILE" -out "$SIG_FILE" "$MESSAGE" >/dev/null 2>&1

elif [ "$TYPE" == "classical" ]; then
    if [ "$ALGO" == "rsa" ]; then
        openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -out "$KEY_FILE" >/dev/null 2>&1
    elif [ "$ALGO" == "ecdsa" ]; then
        PARAM="${CURVE:-prime256v1}"
        openssl ecparam -name "$PARAM" -genkey -noout -out "$KEY_FILE" >/dev/null 2>&1
    else
        openssl genpkey -algorithm "$ALGO" -out "$KEY_FILE" >/dev/null 2>&1
    fi
    openssl pkey -in "$KEY_FILE" -pubout -out "$PUB_FILE" >/dev/null 2>&1
    
    # Sign (Classical needs sha256)
    openssl dgst -sha256 -sign "$KEY_FILE" -out "$SIG_FILE" "$MESSAGE" >/dev/null 2>&1
fi

# Check if generation worked
if [ ! -f "$PUB_FILE" ] || [ ! -f "$SIG_FILE" ]; then
    echo -e "${YELLOW}[Error] Failed to generate files. Check algorithm name.${NC}"
    exit 1
fi

# 2. Analyze Sizes (using 'stat' to get bytes)
# Linux uses stat -c%s, macOS uses stat -f%z. We assume Linux (Kali).
PUB_SIZE=$(stat -c%s "$PUB_FILE")
SIG_SIZE=$(stat -c%s "$SIG_FILE")
PRIV_SIZE=$(stat -c%s "$KEY_FILE")

# Calculate totals
TOTAL_SIZE=$((PUB_SIZE + SIG_SIZE))

# 3. Output Results
echo ""
echo -e "${GREEN}Analysis Results: $ALGO ($TYPE)${NC}"
echo "---------------------------------------------"
printf "%-20s %10s %10s\n" "Artifact" "Bytes" "Kilobytes"
echo "---------------------------------------------"
printf "%-20s %10d %10.2f KB\n" "Public Key (.pub)" "$PUB_SIZE" "$(echo "$PUB_SIZE/1024" | bc -l)"
printf "%-20s %10d %10.2f KB\n" "Signature (.sig)" "$SIG_SIZE" "$(echo "$SIG_SIZE/1024" | bc -l)"
printf "%-20s %10d %10.2f KB\n" "Private Key (.key)" "$PRIV_SIZE" "$(echo "$PRIV_SIZE/1024" | bc -l)"
echo "---------------------------------------------"
echo -e "${YELLOW}Bandwidth Cost (Pub+Sig): $TOTAL_SIZE Bytes${NC}"
echo ""
