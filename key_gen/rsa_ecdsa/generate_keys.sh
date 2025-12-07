#!/bin/sh

# RSA
for bits in 2048 3072 4096; do
    openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$bits -out rsa${bits}.key
    openssl pkey -in rsa${bits}.key -pubout -out rsa${bits}.pub
done

# ECDSA NIST P-curves
for curve in prime256v1 secp384r1 secp521r1; do
    keyfile=$(echo $curve | tr -d '[:punct:]')
    openssl ecparam -genkey -name $curve -out ecdsa_${keyfile}.key
    openssl pkey -in ecdsa_${keyfile}.key -pubout -out ecdsa_${keyfile}.pub
done
