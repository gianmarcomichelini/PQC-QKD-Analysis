#!/bin/sh

# Falcon key generation (OQS OpenSSL)
for alg in falcon512 falcon1024; do
    echo "Generating keys for $alg..."
    openssl genpkey -provider oqsprovider -algorithm $alg -out ${alg}.key
    openssl pkey -provider oqsprovider -in ${alg}.key -pubout -out ${alg}.pub
done
