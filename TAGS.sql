------------------------------------------
--         数据库多标签查询方法
--        --------------------
--
--  原理主要是将以 \x00 分隔的字符串当数组使用
--  然后再使用 instr 搜索被 \x00 包裹的字符串
--  理论上 \x00 换成逗号也行（记得改开头和结尾）
--  此外下面的字符串也可以直接换成字节（整数类型）
------------------------------------------

CREATE TABLE files (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name nvarchar[64] NOT NULL,
  tags nvarchar[64] NOT NULL
);

INSERT INTO files VALUES (
  NULL,
  "Au - きらいな人.mp3",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - しんでしまうとはなさけない!.mp3",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - 夕立のりぼん.mp3",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - 路地裏猫の正体.mp3",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - After This.mp3",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - ギガンティックO.T.N.mp3",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - 威風堂々.mp3",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - シﾞュリエッタとロミヲ.mp3",
  "\x00Au\x00ぺろ。\x00"
);

INSERT INTO files VALUES (
  NULL,
  "Au - Glow.mp3",
  "\x00Au\x00ぺろ。\x00"
);

SELECT id FROM files
  WHERE instr(tags, "\x00Au\x00")
    AND instr(tags, "\x00ぺろ。\x00");
