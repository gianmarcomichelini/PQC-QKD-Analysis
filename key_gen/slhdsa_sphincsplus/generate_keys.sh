#!/bin/sh

# Supported SPHINCS+ algorithms (only core variants)
algorithms="
sphincssha2128fsimple
sphincssha2128ssimple
sphincssha2192fsimple
sphincsshake128fsimple
"

for alg in $algorithms; do
    echo "Generating keys for $alg..."
    openssl genpkey -provider oqsprovider -algorithm $alg -out ${alg}.key
    openssl pkey -provider oqsprovider -in ${alg}.key -pubout -out ${alg}.pub
done
