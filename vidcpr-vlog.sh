#!/bin/sh

for v in *.mp4; do
  case "${v}" in
    !*)
      continue
      ;;
    *)
      ;;
  esac
  [ -f "!${v}" ] && continue
  ffmpeg -i "${v}" \
    -c:v libsvtav1 -preset 8 -g 120 -bf 8 -refs 5 -crf 33 -pix_fmt yuv420p10le \
    -svtav1-params scd=1:superres-mode=3:superres-qthres=22:tune=5 \
    -c:a aac -ac 2 -q:a 1 \
    "!${v}"
done
