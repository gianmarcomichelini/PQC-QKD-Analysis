#!/bin/bash

# ==========================================
# PQ Signature & Verification Manager
# ==========================================

# Colors for formatting
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MESSAGE_FILE="message.txt"
SIG_OUTPUT="message.sig"
KEY_GEN_DIR="../key_gen"

# 1. Check if message.txt exists, if not, create a dummy one
if [ ! -f "$MESSAGE_FILE" ]; then
    echo -e "${YELLOW}[!] $MESSAGE_FILE not found. Creating a dummy file...${NC}"
    echo "This is a test message for PQC signing." > "$MESSAGE_FILE"
fi

echo -e "${CYAN}--- Scanning for available keys in '$KEY_GEN_DIR/' ---${NC}"

# 2. Dynamic Discovery: Find all .key files in subdirectories of key_gen
# We use 'find' to get the paths, and store them in an array
mapfile -t KEY_LIST < <(find "$KEY_GEN_DIR" -type f -name "*.key" 2>/dev/null | sort)

if [ ${#KEY_LIST[@]} -eq 0 ]; then
    echo -e "${RED}[Error] No .key files found in $KEY_GEN_DIR/ folders.${NC}"
    echo -e "${YELLOW}Please ensure the key_gen directory exists in the parent directory and contains key files.${NC}"
    exit 1
fi

# 3. Present Menu to User
echo "Available Algorithms:"
i=1
for key in "${KEY_LIST[@]}"; do
    # Remove the '../key_gen/' prefix for cleaner display
    display_name=$(echo "$key" | sed "s|^$KEY_GEN_DIR/||")
    echo "  [$i] $display_name"
    ((i++))
done

echo ""
read -p "Select an algorithm (enter number): " SELECTION

# Validate Input
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "${#KEY_LIST[@]}" ]; then
    echo -e "${RED}[Error] Invalid selection.${NC}"
    exit 1
fi

# Get the actual file paths
CHOSEN_KEY_PATH="${KEY_LIST[$((SELECTION-1))]}"
# Derive Public Key path (assumes .pub extension replaces .key)
CHOSEN_PUB_PATH="${CHOSEN_KEY_PATH%.key}.pub"

echo -e "\n${CYAN}--- Configuration ---${NC}"
echo "Private Key: $CHOSEN_KEY_PATH"
echo "Public Key:  $CHOSEN_PUB_PATH"

# 4. Check if Public Key exists
if [ ! -f "$CHOSEN_PUB_PATH" ]; then
    echo -e "${RED}[Error] Public key not found at: $CHOSEN_PUB_PATH${NC}"
    echo "Please ensure the public key has the same name as the private key but ends in .pub"
    exit 1
fi

# 5. Determine if we need OQS Provider or Standard
# Logic: If path contains mldsa, falcon, slh, sphincs -> Use OQS. Else (rsa, ecdsa) -> Standard.
filename=$(basename "$CHOSEN_KEY_PATH" | tr '[:upper:]' '[:lower:]')

if [[ "$filename" == *"mldsa"* ]] || [[ "$filename" == *"falcon"* ]] || [[ "$filename" == *"slh"* ]] || [[ "$filename" == *"sphincs"* ]]; then
    ALGO_TYPE="PQC"
    # PQC commands usually need the provider
    SIGN_CMD="openssl dgst -provider oqsprovider -sign $CHOSEN_KEY_PATH -out $SIG_OUTPUT $MESSAGE_FILE"
    VERIFY_CMD="openssl dgst -provider oqsprovider -verify $CHOSEN_PUB_PATH -signature $SIG_OUTPUT $MESSAGE_FILE"
else
    ALGO_TYPE="CLASSICAL"
    # Classical usually needs a digest hash like -sha256 explicitly
    SIGN_CMD="openssl dgst -sha256 -sign $CHOSEN_KEY_PATH -out $SIG_OUTPUT $MESSAGE_FILE"
    VERIFY_CMD="openssl dgst -sha256 -verify $CHOSEN_PUB_PATH -signature $SIG_OUTPUT $MESSAGE_FILE"
fi

echo -e "Algorithm Type: ${YELLOW}$ALGO_TYPE${NC}"

# 6. Perform Signing
echo -e "\n${CYAN}--- Step 1: Signing ---${NC}"
echo "Executing: $SIGN_CMD"
eval "$SIGN_CMD"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[Success] Message signed. Signature saved to $SIG_OUTPUT${NC}"
else
    echo -e "${RED}[Fail] Signing failed.${NC}"
    exit 1
fi

# 7. Perform Verification
echo -e "\n${CYAN}--- Step 2: Verifying ---${NC}"
echo "Executing: $VERIFY_CMD"
# Capture output to check for "Verified OK"
VERIFY_OUTPUT=$(eval "$VERIFY_CMD" 2>&1)

if [[ "$VERIFY_OUTPUT" == *"Verified OK"* ]]; then
    echo -e "${GREEN}[Success] Signature Verified! The message is authentic.${NC}"
else
    echo -e "${RED}[Fail] Verification Failed!${NC}"
    echo "OpenSSL Output: $VERIFY_OUTPUT"
fi