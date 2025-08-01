for v in *.mp4; do
  case "$v" in
    !*)
      continue
      ;;
  esac
  [ -f "!$v" ] && continue
  ffmpeg -i "$v" \
    -c:v hevc -preset:v veryfast -g 120 -bf 8 -refs 5 -qcomp 0.75 -crf 27 \
    -x265-params aq-mode=3:aq-strength=1.25:deblock=-1,-1:me=star:merange=64:no-amp=1:no-rect=1:no-sao=1:psy-rd=2.2:psy-rdoq=1.33:subme=6:weightb=1 \
    -c:a aac -ac 2 -q:a 1 \
    "!$v"
done
