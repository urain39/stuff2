#!/bin/sh

BITRATE="${1:-"3M"}"

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
    -c:v libsvtav1 -preset 6 -g 120 -bf 8 -refs 5 -b:v "${BITRATE}" -pix_fmt yuv420p10le \
    -svtav1-params scd=1:tune=0 -pass 1 \
    -an \
    -f null \
    "/dev/null"
  ffmpeg -i "${v}" \
    -c:v libsvtav1 -preset 6 -g 120 -bf 8 -refs 5 -b:v "${BITRATE}" -pix_fmt yuv420p10le \
    -svtav1-params scd=1:tune=0 -pass 2 \
    -c:a aac -ac 2 -q:a 1 \
    "!${v}"
done
