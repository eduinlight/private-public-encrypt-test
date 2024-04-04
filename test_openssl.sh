#!/bin/env bash

set -e

PASSPHRASE="asdfqweasdqweasd"
PRIVATE_KEY_PATH=keys/private.pem
PUBLIC_KEY_PATH=keys/public.pem
FILE_PATH=./file.txt
ENCRYPTED_PATH=./file.encrypted
UNENCRYPTED_PATH=./file.unencrypted

mkdir -p keys

function gen-keys() {
  echo "GENERATING PRIVATE KEY..."
  openssl genrsa -aes128 -passout pass:$PASSPHRASE -out $PRIVATE_KEY_PATH 1024
  echo "PRIVATE KEY GENERATED => ${PRIVATE_KEY_PATH}"
  echo ""
  echo "GENERATING PUBLIC KEY..."
  openssl rsa -passin pass:$PASSPHRASE -in $PRIVATE_KEY_PATH -pubout > $PUBLIC_KEY_PATH
  echo "PUBLIC KEY GENERATED => ${PUBLIC_KEY_PATH}"
  echo ""
}

# 1 => file
# 2 => output file
# 3 => public key
function encrypt() {
  echo "ENCRYPTING ${1} with ${3}"
  openssl pkeyutl -encrypt -passin pass:$PASSPHRASE -inkey $3 -pubin -in $1 -out $2
  echo "FILE ENCRYPTED => ${2}"
  echo ""
}

# 1 => encrypted file
# 2 => output file
# 3 => private key
function decrypt() {
  echo "UNENCRYPTING ${1} with ${3}"
  openssl pkeyutl -decrypt -passin pass:$PASSPHRASE -inkey $3 -in $1 > $2
  echo "FILE UNENCRYPTED => ${2}"
  echo ""
}

# 1 => file a
# 2 => file b
function compare-files() {
  echo "COMPARING ${1} with ${2}"
  if (diff $1 $2 -s > /dev/null); then
    echo "✅ File ${1} and file ${2} are EQUALS"
  else
    echo "❌ File ${1} and file ${2} are DIFFERENT"
  fi
}

gen-keys

echo "TESTING ENCRYPTING WITH PUBLIC AND UNENCRYPT WITH PRIVATE"
encrypt $FILE_PATH $ENCRYPTED_PATH $PUBLIC_KEY_PATH
decrypt $ENCRYPTED_PATH $UNENCRYPTED_PATH $PRIVATE_KEY_PATH
compare-files $FILE_PATH $UNENCRYPTED_PATH

echo ""

echo "TESTING ENCRYPTING WITH PRIVATE AND UNENCRYPT WITH PUBLIC"
encrypt $FILE_PATH $ENCRYPTED_PATH $PRIVATE_KEY_PATH
decrypt $ENCRYPTED_PATH $UNENCRYPTED_PATH $PUBLIC_KEY_PATH
compare-files $FILE_PATH $UNENCRYPTED_PATH
