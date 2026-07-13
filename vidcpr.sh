#!/bin/sh

CRF="${1:-"27"}"

for v in *.mp4; do
  case "${V}" in
    !*)
      continue
      ;;
    *)
      ;;
  esac
  [ -f "!${V}" ] && continue
  ffmpeg -i "${V}" \
    -c:v libsvtav1 -preset 6 -g 120 -bf 8 -refs 5 -crf "${CRF}" -pix_fmt yuv420p10le \
    -svtav1-params rc=0:scd=1:superres-mode=3:superres-qthres=22:tune=4 \
    -c:a aac -ac 2 -q:a 1 \
    "!${V}"
done
