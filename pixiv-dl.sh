#!/bin/sh

random_wait() {
  local _t="$(
    dd if=/dev/urandom bs=4 count=1 2> /dev/null |
      od -t u4 |
      awk \
        -v _b="$1" \
        -v _e="$2" \
        '{ _r = $2 / 0xffffffff; exit }
        END { print (_b + ((_e - _b) * _r) ) }'
  )"
  echo "sleep ${_t}s ..."
  sleep "$_t"
}

download_pixiv() {
  local _pid="$1"
  if wget \
    --continue \
    --content-disposition \
    "https://pixiv.nl/$_pid-1.jpg"; then
    local _i=
    for _i in $(seq 2 999); do
      random_wait 0 15
      wget \
        --continue \
        --content-disposition \
        "https://pixiv.nl/$_pid-$_i.jpg" ||
        break
    done
  else
    random_wait 0 15
    wget \
      --continue \
      --content-disposition \
      "https://pixiv.nl/$_pid.jpg"
  fi
}

while [ "$1" != "" ]; do
  download_pixiv "$1"
  random_wait 60 300
  shift
done
