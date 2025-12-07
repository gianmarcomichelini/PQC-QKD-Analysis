#!/bin/bash

# Batch Key Generation Script
# Executes generate_keys.sh in each algorithm subdirectory

set -e

echo "=========================================="
echo "  Cryptographic Key Generation"
echo "=========================================="
echo ""

SCRIPT="generate_keys.sh"

echo "[1/2] Setting execute permissions on all $SCRIPT files..."
echo ""

# Make generate_keys.sh executable in all subdirectories
for folder in */; do
    if [ -d "$folder" ] && [ -f "$folder/$SCRIPT" ]; then
        chmod +x "$folder/$SCRIPT"
        echo "  Set permissions: ${folder}$SCRIPT"
    fi
done

echo ""
echo "[2/2] Executing key generation in each directory..."
echo ""

# Execute generate_keys.sh in each subdirectory
for folder in */; do
    if [ -d "$folder" ]; then
        folder_name="${folder%/}"
        
        if [ -f "$folder/$SCRIPT" ]; then
            echo "=========================================="
            echo "  Directory: $folder_name"
            echo "=========================================="
            cd "$folder" || exit
            ./"$SCRIPT"
            cd ..
            echo ""
        else
            echo "Warning: $SCRIPT not found in $folder_name, skipping..."
            echo ""
        fi
    fi
done

echo "=========================================="
echo "  All Key Generation Complete"
echo "=========================================="