for v in *.mp4; do
  case "$v" in
    !*)
      continue
      ;;
  esac
  [ -f "!$v" ] && continue
  ffmpeg -i "$v" \
    -c:v hevc -preset:v veryfast -g 240 -bf 4 -refs 3 -qcomp 0.75 -qmin 22 -qmax 33 -x265-params aq-mode=3 \
    -c:a aac -q:a 1 \
    "!$v"
done
