#!/bin/bash

# ==========================================
# ML-KEM Encapsulation & Decapsulation Test
# ==========================================

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Directory where keys AND artifacts will be stored
KEY_DIR="mlkem/keys"
BASE_DIR="mlkem"

echo -e "${CYAN}--- ML-KEM Simulation (Key Exchange) ---${NC}"
echo "Select the ML-KEM algorithm level to test:"
echo "  [1] ML-KEM-512"
echo "  [2] ML-KEM-768"
echo "  [3] ML-KEM-1024"
read -p "Enter selection [1-3]: " CHOICE

case $CHOICE in
    1) LEVEL="512" ;;
    2) LEVEL="768" ;;
    3) LEVEL="1024" ;;
    *) echo -e "${RED}Invalid selection.${NC}"; exit 1 ;;
esac

ALGO="ml-kem-$LEVEL"

# Define Paths (Everything goes into mlkem/)
PUB_KEY="${BASE_DIR}/mlkem${LEVEL}_pub.pem"
PRIV_KEY="${BASE_DIR}/mlkem${LEVEL}_priv.pem"
CIPHERTEXT="${BASE_DIR}/mlkem${LEVEL}.ct"
SS_SENDER="${BASE_DIR}/mlkem${LEVEL}.ss.sender"
SS_RECEIVER="${BASE_DIR}/mlkem${LEVEL}.ss.receiver"

# 1. Prerequisite Check
if [ ! -f "$PUB_KEY" ] || [ ! -f "$PRIV_KEY" ]; then
    echo -e "${RED}[Error] Keys for $ALGO not found!${NC}"
    echo "Expected: $PUB_KEY and $PRIV_KEY"
    echo -e "${YELLOW}Please ensure you have run 'generate_mlkem_keys.sh'.${NC}"
    exit 1
fi

echo -e "\n${CYAN}Testing $ALGO (Artifacts saved to $KEY_DIR/)...${NC}"

# 2. Encapsulate (Sender Side)
echo -n "1. Encapsulating (Sender)... "
openssl pkeyutl -provider oqsprovider -encap \
    -pubin -inkey "$PUB_KEY" \
    -out "$CIPHERTEXT" \
    -secret "$SS_SENDER"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${RED}[FAIL]${NC}"
    exit 1
fi

# 3. Decapsulate (Receiver Side)
echo -n "2. Decapsulating (Receiver)... "
openssl pkeyutl -provider oqsprovider -decap \
    -inkey "$PRIV_KEY" \
    -in "$CIPHERTEXT" \
    -secret "$SS_RECEIVER"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${RED}[FAIL]${NC}"
    exit 1
fi

# 4. Verification
echo -n "3. Verifying Shared Secrets... "
DIFF_OUT=$(diff "$SS_SENDER" "$SS_RECEIVER")

if [ -z "$DIFF_OUT" ]; then
    echo -e "${GREEN}[SUCCESS]${NC}"
    echo "   Shared Secrets Match!"
    
    # Optional: Visual Proof
    echo -e "\n${YELLOW}Visual Proof (First 32 bytes of Shared Secret):${NC}"
    echo "Sender:   $(xxd -p -l 32 "$SS_SENDER")"
    echo "Receiver: $(xxd -p -l 32 "$SS_RECEIVER")"
else
    echo -e "${RED}[FAILURE]${NC}"
    echo "Secrets do not match."
fi

echo -e "\nArtifacts created in '$KEY_DIR/':"
ls -lh "$CIPHERTEXT" "$SS_SENDER" "$SS_RECEIVER" | awk '{print $9, "(" $5 ")"}'
