awk '{ lines[NR] = $0 } END {
  total = NR
  if (total % 2) {
    total--;
  }

  mid = total / 2
  end = NR + 1
  for (i = 1; i <= mid; i++) {
    print lines[i]
    print lines[end - i]
  }

  if (total != NR) {
    print lines[mid + 1]
  }
}'
