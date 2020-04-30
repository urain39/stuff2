convert 0525_Koharu_NOBG.png \
  \( \
    +clone \
    -alpha extract \
    -write 0525_Koharu_NOBG-alpha.jpg \
    -negate \
    -background black \
    -alpha shape \
  \) \
  -compose src-over \
  -composite 0525_Koharu_NOBG.jpg

convert 0525_Koharu_NOBG.jpg \
  0525_Koharu_NOBG-alpha.jpg \
    -alpha copy \
  -compose CopyOpacity \
  -composite 0525_Koharu_NOBG-REGEN.png
