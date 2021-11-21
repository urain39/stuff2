#!/bin/sh

MNT_DIR="$HOME/.avfs"

mkdir -p "$MNT_DIR"
grep -Fq " $MNT_DIR fuse.avfsd " /proc/mounts \
  || avfsd "$MNT_DIR" \
    -o allow_other \
    -o auto_unmount \
    -o async_read \
    -o direct_io \
    -o modules=subdir \
    -o subdir="$HOME" \
    -o rellinks
