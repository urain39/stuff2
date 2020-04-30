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
  start_time = systime()
} {
  if (NF < 2) next
  total = $1
  count = $2
  if (count >= total) {
     printf "\r\033[KProcessing: %d / %d (%.2f%%) | Done\n", count, total, count * 100 / total
     exit
  }
  printf "\r\033[KProcessing: %d / %d (%.2f%%) | ETA: ", count, total, count * 100 / total
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
      if (++index_ == 5) break
    }
    buffer[index_] = remain
    for (i = index_; i >= 1; i--)
      printf "%d%s", buffer[i], units[i]
  }
}
