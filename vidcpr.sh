#!/bin/sh

CRF="${1:-"35"}"
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
  # shellcheck disable=SC2140
  ffmpeg -i "${V}" \
    -c:v libsvtav1 -preset "${PRE}" -g 120 -bf 8 -refs 5 -crf "${CRF}" -pix_fmt yuv420p10le \
    -svtav1-params enable-dlf=2:rc=0:scd=1:superres-mode=3:superres-qthres="$((CRF - 5))":tune="${TUN}" \
    -c:a aac -ac 2 -q:a 1 \
    "!${V}"
done
