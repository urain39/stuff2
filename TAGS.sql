------------------------------------------
--         数据库多标签查询方法
--        --------------------
--
--  原理主要是将以 \x00 分隔的字符串当数组使用
--  然后再使用 INSTR 搜索被 \x00 包裹的字符串
--  理论上 \x00 换成逗号也行（记得改开头和结尾）
--
--  此外也可以直接将 tag 编码成 Unicode 字符
--  配合 CHECK (tag_id > 0) 可以实现快速查询
------------------------------------------

-- CREATE TABLE IF NOT EXISTS tags (
--   id INTEGER PRIMARY KEY AUTOINCREMENT CHECK (id > 0),
--   name TEXT UNIQUE NOT NULL,
--   time TEXT NOT NULL
-- );

-- 假如某个 file 的 tags 存在 tag_id == 0 那么可以使用下面的语句修复
-- UPDATE files SET tags=REPLACE(tags, "\x00\x00\x00", "")
--   WHERE INSTR(tags, "\x00\x00\x00");

CREATE TABLE IF NOT EXISTS files (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  size INTEGER NOT NULL,
  time TEXT NOT NULL,
  tags TEXT NOT NULL
);

INSERT INTO files VALUES (
  NULL,
  "Au - きらいな人.mp3",
  0,
  "2022-09-02 15:54:20",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - しんでしまうとはなさけない!.mp3",
  0,
  "2022-09-02 15:54:20",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - 夕立のりぼん.mp3",
  0,
  "2022-09-02 15:54:20",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - 路地裏猫の正体.mp3",
  0,
  "2022-09-02 15:54:20",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - After This.mp3",
  0,
  "2022-09-02 15:54:20",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - ギガンティックO.T.N.mp3",
  0,
  "2022-09-02 15:54:20",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - 威風堂々.mp3",
  0,
  "2022-09-02 15:54:20",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - シﾞュリエッタとロミヲ.mp3",
  0,
  "2022-09-02 15:54:20",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - Glow.mp3",
  0,
  "2022-09-02 15:54:20",
  "\x00Au\x00ぺろ。\x00"
);

SELECT id FROM files
  WHERE INSTR(tags, "\x00Au\x00")
    AND INSTR(tags, "\x00ぺろ。\x00");
