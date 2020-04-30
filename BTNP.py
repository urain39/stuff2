#!/usr/bin/python
#
# BTNP - BitTorrent Name Parser | BT 名称解析器。
#

import re

# 规范化的 BT 任务名应该是 "(类别) [作者团体 (作者名称)] 文件名"
RE_BT_NAME =  re.compile(
  r'^(?:\((?P<category>[^()[\]]+?)\) ?)?'
  r'(?:\[(?P<group_author>'
  r'(?P<group>[^()]+?)'
  r'(?: ?\((?P<author>[^()[\]]+?)\))?'
  r')\] ?)?'
  r'(?P<file_name>[^()[\]]+)$'
)

def parse(name):
  rv = RE_BT_NAME.match(name).groupdict()
  # XXX: 因为 Python 中的 RegExp 不支持重复定义命名捕获组，
  # 所以我们只能使用一个表达式匹配两种情况。即：我们将 author
  # 视作是可省略的，group 视作是必须的；当 author 缺失时，我
  # 们再将 group 提取出来当作 author。
  if rv["author"] is None:
    rv["author"] = rv["group"]
    rv["group"] = None
  return rv
