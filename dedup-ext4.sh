#!/bin/sh

rdfind \
  -outputname /proc/self/fd/1 \
  -makehardlinks true \
  "$@"

