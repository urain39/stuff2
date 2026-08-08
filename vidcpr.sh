#!/bin/sh

CRF="${1:-"40"}"
TUN="${2:-"5"}"
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
  taskset -a f0 ffmpeg -i "${V}" \
    -vf 'scale=if(lte(iw\,ih)\,min(iw\,1080)\,-1):if(lte(iw\,ih)\,-1\,min(ih\,1080)),crop=iw-mod(iw\,8):ih-mod(ih\,8)' \
    -af 'sofalizer=sofa='"${PREFIX-:"/usr"}"'/share/libmysofa/default.sofa:type=time' \
    -c:v libsvtav1 -preset "${PRE}" -g 120 -bf 8 -refs 5 -crf "${CRF}" -pix_fmt yuv420p10le \
    -svtav1-params ac-bias=1.0:enable-cdef=1:enable-dlf=2:enable-kf-tf=1:enable-restoration=1:enable-tf=1:enable-variance-boost=1:lp=4:qp-scale-compress-strength=1:rc=0:scd=1:scm=3:sharpness=1:superres-mode=3:superres-qthres="$((CRF - 5))":tune="${TUN}" \
    -c:a libopus -ac 2 -b:a 76.8K \
    "!${V}"
done
