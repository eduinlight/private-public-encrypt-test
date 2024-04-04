#!/bin/env bash

set -e

PASSPHRASE="asdfqweasdqweasd"
PRIVATE_KEY_PATH=keys/private.pem
PUBLIC_KEY_PATH=keys/public.pem
FILE_PATH=./file.txt
ENCRYPTED_PATH=./file.encrypted
UNENCRYPTED_PATH=./file.unencrypted

BLUE_COLOR="\e[34m"
RED_COLOR="\e[31m"
GREEN_COLOR="\e[32m"
CYAN_COLOR="\e[36m"
DEFAULT_COLOR="\e[0m"

mkdir -p keys

# 1 => text
# 2 => color
function echo-color() {
  echo -e "${2}${1}${DEFAULT_COLOR}"
}

function gen-keys() {
  echo "GENERATING PRIVATE KEY..."
  openssl genrsa -aes128 -passout pass:$PASSPHRASE -out $PRIVATE_KEY_PATH 1024
  echo "PRIVATE KEY GENERATED => $(echo-color $PRIVATE_KEY_PATH $GREEN_COLOR)"
  echo ""
  echo "GENERATING PUBLIC KEY..."
  openssl rsa -passin pass:$PASSPHRASE -in $PRIVATE_KEY_PATH -pubout > $PUBLIC_KEY_PATH
  echo "PUBLIC KEY GENERATED => $(echo-color $PUBLIC_KEY_PATH $GREEN_COLOR)"
  echo ""
}

# 1 => file
# 2 => output file
# 3 => public key
function encrypt() {
  echo "ENCRYPTING $(echo-color $1 $BLUE_COLOR) with $(echo-color $3 $BLUE_COLOR)"
  openssl pkeyutl -encrypt -passin pass:$PASSPHRASE -inkey $3 -pubin -in $1 -out $2
  echo "FILE ENCRYPTED => $(echo-color $2 $GREEN_COLOR)"
  echo ""
}

# 1 => encrypted file
# 2 => output file
# 3 => private key
function decrypt() {
  echo "UNENCRYPTING $(echo-color $1 $BLUE_COLOR) with $(echo-color $3 $BLUE_COLOR)"
  openssl pkeyutl -decrypt -passin pass:$PASSPHRASE -inkey $3 -in $1 > $2
  echo "FILE UNENCRYPTED => $(echo-color $2 $GREEN_COLOR)"
  echo ""
}

# 1 => file a
# 2 => file b
function compare-files() {
  echo "COMPARING $(echo-color $1 $BLUE_COLOR) with $(echo-color $2 $BLUE_COLOR)"
  if (diff $1 $2 -s > /dev/null); then
    echo-color "✅ File ${1} and file ${2} are EQUALS" $GREEN_COLOR
  else
    echo-color "❌ File ${1} and file ${2} are DIFFERENT" $RED_COLOR
  fi
}

gen-keys

echo-color "TESTING ENCRYPTING WITH PUBLIC AND UNENCRYPT WITH PRIVATE" $CYAN_COLOR
encrypt $FILE_PATH $ENCRYPTED_PATH $PUBLIC_KEY_PATH
decrypt $ENCRYPTED_PATH $UNENCRYPTED_PATH $PRIVATE_KEY_PATH
compare-files $FILE_PATH $UNENCRYPTED_PATH

echo ""

echo-color "TESTING ENCRYPTING WITH PRIVATE AND UNENCRYPT WITH PUBLIC" $CYAN_COLOR
encrypt $FILE_PATH $ENCRYPTED_PATH $PRIVATE_KEY_PATH
decrypt $ENCRYPTED_PATH $UNENCRYPTED_PATH $PUBLIC_KEY_PATH
compare-files $FILE_PATH $UNENCRYPTED_PATH
