import os
import re
import sqlite3

RE_BT_NAME =  re.compile(
  r'(?P<group>[^()]+?) \((?P<author>[^()[\]]+?)\)'
)

DB_INDEX = "FOX-INDEX.db"
DB_INIT = """
CREATE TABLE IF NOT EXISTS tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT CHECK (id > 0),
  name TEXT UNIQUE NOT NULL,
  time TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS files (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  size INTEGER NOT NULL,
  time TEXT NOT NULL,
  tags TEXT NOT NULL
);
"""

DB_TAGS_INSERT = """
INSERT OR IGNORE INTO tags VALUES (
  NULL,
  ?,
  datetime()
)
"""

db = sqlite3.connect(DB_INDEX)
db.executescript(DB_INIT)
db.commit()


for i in os.listdir("CG/同人CG集"):
  m = RE_BT_NAME.match(i)
  db.execute(DB_TAGS_INSERT, (m.group("group"),))
  db.execute(DB_TAGS_INSERT, (m.group("author"),))
db.commit()
