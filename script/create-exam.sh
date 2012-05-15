#!/bin/bash

# Default is not locking
LOCK=false

# Parse options
while getopts "l" OPT; do
  case "$OPT" in
  l)
    LOCK=true
    ;;
  \?)
    echo "Invalid options: -$OPTARG"
    ;;
  esac
done

# Check arguments
shift $(($OPTIND - 1))
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 OPTIONS file"
    exit 1
fi

# File to submit, zip to create
FILE="$1"
ZIP="$FILE.zip"

# Lock if necessary
if "$LOCK"; then
    FILE_ENC="$FILE.enc"
    echo "Encrypting $FILE..."
    openssl enc -aes-256-cbc -e -in "$FILE" -out "$FILE_ENC"

    # Check if locking worked
    if test ! -f "$FILE_ENC"; then
        echo "Locking $FILE failed, aborting!"
        exit 1
    fi

    FILE="$FILE_ENC"
fi


# Sign file
FILE_SIG="$FILE.sig"
echo "Signing $FILE..."
gpg --detach-sig "$FILE"

# Check if signing worked: both files must exist
if test ! -f "$FILE" -o ! -f "$FILE_SIG"; then
    echo "Signing $FILE failed, aborting!"
    exit 1
fi

# Zip necessary files
echo "Zipping data into $ZIP..."
zip "$ZIP" "$FILE" "$FILE_SIG"

# Check if zipping worked
if test -f "$ZIP"; then
    echo "$ZIP created!"
else
    echo "Could not zip data!"
    exit 1
fi
