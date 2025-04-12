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
  estimate = ""
  start_time = systime()
} {
  if (NF != 1) next
  if      ($1 == 0) count++
  else if ($1 == -2147483648) count--
  else if ($1 == 2147483647) ;
  else if ($1 == -2147483647) exit 1
  else if ($1 > 0) { total = $1; count = 0 }
  else count = -$1
  if (count >= total) {
     printf "\r\033[K\033[1;44mProcessing: %d / %d (%.2f%%) | Done\033[0m\n", count, total, count * 100 / total
     exit 0
  }
  if (count == 0) {
    estimate = "N/A"
    start_time = systime()
  } else {
    estimate = ""
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
      estimate = estimate sprintf("%d%s", buffer[i], units[i])
  }
  printf "\r\033[K\033[1;44mProcessing: %d %c %d (%.2f%%) | ETA: %s\033[0m", count, chars[count % 4], total, count * 100 / total, estimate
}