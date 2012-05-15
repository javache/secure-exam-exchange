#!/bin/bash

# Parse options
while getopts "l" OPT; do
  case "$OPT" in
  l)
    # TODO
    echo "Locked"
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

# Sign file
FILE="$1"
FILE_SIG="$FILE.sig"
echo "Signing $FILE..."
gpg --detach-sig "$FILE"

# Check if signing worked: both files must exist
if test ! -f "$FILE" -o ! -f "$FILE_SIG"; then
    echo "Signing $FILE failed, aborting!"
    exit 1
fi

# Zip necessary files
ZIP="$FILE.zip"
echo "Zipping data into $ZIP..."
zip "$ZIP" "$FILE" "$FILE_SIG"

# Check if zipping worked
if test -f "$ZIP"; then
    echo "$ZIP created!"
else
    echo "Could not zip data!"
    exit 1
fi
