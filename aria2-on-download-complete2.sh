#!/bin/sh

remove_control_file_by_path() {
    local path="$(realpath "$1")"
 
    while :; do
      if [ -f "$path".aria2 ]; then
          rm "$path".aria2
          break
      fi
      path="$(dirname "$path")"
      [ "$path" == "/" ] && break
    done
}

# $1 - GID
# $2 - Number of files
# $3 - First file path
remove_control_file_by_path "$3"
