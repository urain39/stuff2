sqlite3 ~/.nyaq.db << EOF
.mode tabs
SELECT t1.title, t1.size, t1.time, hex(t1.infohash) FROM torrents t1
  WHERE instr(t1.title, "$1")
    AND t1.size == (
      SELECT max(t2.size) FROM torrents t2
        WHERE t2.title == t1.title
    )
    ORDER BY time ASC;
EOF
