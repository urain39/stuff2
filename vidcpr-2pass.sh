#!/bin/sh

TBR="${1:-"5M"}"
TUN="${2:-"0"}"
PRE="${3:-"6"}"

for V in *.mp4; do
  case "${V}" in
    !*)
      continue
      ;;
    *)
      ;;
  esac
  [ -f "!${V}" ] && continue
  taskset -a f0 ffmpeg -i "${V}" \
    -c:v libsvtav1 -preset "${PRE}" -g 120 -bf 8 -refs 5 -b:v "${TBR}" -pix_fmt yuv420p10le \
    -svtav1-params enable-dlf=2:enable-variance-boost=1:lp=4:rc=1:scd=1:tune="${TUN}" -pass 1 \
    -an \
    -f null \
    "/dev/null"
  taskset -a f0 ffmpeg -i "${V}" \
    -c:v libsvtav1 -preset "${PRE}" -g 120 -bf 8 -refs 5 -b:v "${TBR}" -pix_fmt yuv420p10le \
    -svtav1-params enable-dlf=2:enable-variance-boost=1:lp=4:rc=1:scd=1:tune="${TUN}" -pass 2 \
    -c:a aac -ac 2 -q:a 1 \
    "!${V}"
done
