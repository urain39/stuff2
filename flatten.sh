#!/bin/bash

set -e

if [ "$1" = "" ]; then
  echo "Usage: sh flatten.sh <dir>"
  exit 1
fi

cd "$1"
find . -type f | while read -r F; do
  F="${F:2}"        # Skip "./"
  NF="${F// /-}"    # ' ' -> '-'
  NF="${NF//\//_}"  # '/' -> '_'
  if [ "$F" != "$NF" ]; then
    echo "$F -> $NF"
    mv "$F" "$NF"
  fi
done
