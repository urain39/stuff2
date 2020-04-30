ls | grep -Eo '^[0-9A-Za-z]{5}.zip' | while read -r O; do
  S="$(du -k "$O" | awk '{ print $1 }')"
  if [ "$S" -lt 1000 ]; then
    echo "Skip dummy $O"
    continue
  fi
  N="$(unzip -l "$O" | sed -En 's@^.*[0-9]+_([^/.\t]{1,2}|[^/.\t]\.|\.[^/.\t]|[^/\t]{3,})/info.txt$@\1@p').zip"
  echo "$O -> $N"
  mv "$O" "$N"
  touch "$O"
done
