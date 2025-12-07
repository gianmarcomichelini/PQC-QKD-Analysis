#!/bin/bash

# ==========================================
# Classical ECDH Key Agreement Simulation
# ==========================================

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Directory to store artifacts
OUTPUT_DIR="ecdh"
mkdir -p "$OUTPUT_DIR"

echo -e "${CYAN}--- ECDH Key Exchange Simulation ---${NC}"
echo "Select Elliptic Curve strength:"
echo "  [1] prime256v1 (P-256) - Standard security"
echo "  [2] secp384r1  (P-384) - High security"
echo "  [3] secp521r1  (P-521) - Very High security"
read -p "Enter selection [1-3]: " CHOICE

case $CHOICE in
    1) CURVE="prime256v1" ;;
    2) CURVE="secp384r1" ;;
    3) CURVE="secp521r1" ;;
    *) echo -e "${RED}Invalid selection.${NC}"; exit 1 ;;
esac

echo -e "\n${CYAN}Using Curve: $CURVE${NC}"

# Define filenames
ALICE_KEY="$OUTPUT_DIR/alice.key"
ALICE_PUB="$OUTPUT_DIR/alice.pub"
BOB_KEY="$OUTPUT_DIR/bob.key"
BOB_PUB="$OUTPUT_DIR/bob.pub"
SECRET_ALICE="$OUTPUT_DIR/secret.alice"
SECRET_BOB="$OUTPUT_DIR/secret.bob"

# --------------------------------------
# 1. Key Generation (Alice & Bob)
# --------------------------------------
echo -n "1. Generating Keys for Alice and Bob... "

# Alice
openssl ecparam -genkey -name "$CURVE" -out "$ALICE_KEY" 2>/dev/null
openssl pkey -in "$ALICE_KEY" -pubout -out "$ALICE_PUB" 2>/dev/null

# Bob
openssl ecparam -genkey -name "$CURVE" -out "$BOB_KEY" 2>/dev/null
openssl pkey -in "$BOB_KEY" -pubout -out "$BOB_PUB" 2>/dev/null

if [ -f "$ALICE_KEY" ] && [ -f "$BOB_KEY" ]; then
    echo -e "${GREEN}[OK]${NC}"
else
    echo -e "${RED}[FAIL]${NC}"
    exit 1
fi

# --------------------------------------
# 2. Key Exchange (Derivation)
# --------------------------------------
echo "2. Deriving Shared Secrets..."

# Alice calculates Secret (Her Priv + Bob Pub)
echo -n "   Alice is calculating... "
openssl pkeyutl -derive -inkey "$ALICE_KEY" -peerkey "$BOB_PUB" -out "$SECRET_ALICE"
echo -e "${GREEN}[Done]${NC}"

# Bob calculates Secret (His Priv + Alice Pub)
echo -n "   Bob is calculating...   "
openssl pkeyutl -derive -inkey "$BOB_KEY" -peerkey "$ALICE_PUB" -out "$SECRET_BOB"
echo -e "${GREEN}[Done]${NC}"

# --------------------------------------
# 3. Verification
# --------------------------------------
echo -n "3. Verifying consistency... "
DIFF_OUT=$(diff "$SECRET_ALICE" "$SECRET_BOB")

if [ -z "$DIFF_OUT" ]; then
    echo -e "${GREEN}[SUCCESS]${NC}"
    echo "   Both parties derived the exact same secret."
    
    # Visual Proof
    echo -e "\n${YELLOW}Visual Proof (First 32 bytes of Hex):${NC}"
    echo "Alice's Secret: $(xxd -p -l 32 "$SECRET_ALICE")"
    echo "Bob's Secret:   $(xxd -p -l 32 "$SECRET_BOB")"
else
    echo -e "${RED}[FAILURE]${NC}"
    echo "Secrets do not match!"
fi

echo -e "\nArtifacts stored in './$OUTPUT_DIR/'"
