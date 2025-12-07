#!/bin/sh

# ML-DSA key generation (OQS OpenSSL)
for alg in ml-dsa-44 ml-dsa-65 ml-dsa-87; do
    openssl genpkey -provider oqsprovider -algorithm $alg -out ${alg}.key
    openssl pkey -provider oqsprovider -in ${alg}.key -pubout -out ${alg}.pub
done
