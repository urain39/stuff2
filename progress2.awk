#!/bin/awk -f

BEGIN {
  bases[1] = 60
  bases[2] = 60
  bases[3] = 24
  bases[4] = 365
  units[1] = "s"
  units[2] = "m"
  units[3] = "h"
  units[4] = "d"
  units[5] = "y"
  chars[0] = "/"
  chars[1] = "-"
  chars[2] = "\\"
  chars[3] = "|"
  total = 0
  count = 0
  start_time = systime()
} {
  if (NF != 1) next
  if ($1 > 0) { total = $1; count = 0 }
  else if ($1 == 0) count++
  else count = -$1
  if (count >= total) {
     printf "\r\033[KProcessing: %d / %d (%.2f%%) | Done\n", count, total, count * 100 / total
     exit 0
  }
  printf "\r\033[KProcessing: %d %c %d (%.2f%%) | ETA: ", count, chars[count % 4], total, count * 100 / total
  if (count == 0) {
    start_time = systime()
    printf "N/A"
  } else {
    now_time = systime()
    remain = (total - count) * ((now_time - start_time) / count)
    index_ = 1
    while (remain >= bases[index_]) {
      buffer[index_] = remain % bases[index_]
      remain = int(remain / bases[index_])
      if (++index_ > 4) break
    }
    buffer[index_] = remain
    for (i = index_; i > 0; i--)
      printf "%d%s", buffer[i], units[i]
  }
}
