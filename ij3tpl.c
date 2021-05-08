/** 这是真垃圾！ */

#include <stdio.h>
#include <string.h>

#include "ij3tpl/codegen.h"

#define MAX_TOKLEN 4096

typedef unsigned int IJ3CHAR;

typedef enum IJ3TOK {
  IJ3TOK_PREFIX,
  IJ3TOK_SUFFIX,

} IJ3TOK_t;

IJ3TOK* tokenize(const IJ3CHAR* const src, IJ3OPTIONS* opts) {
  int tokpos = MAX_TOKLEN;
  int tokens[MAX_TOKLEN] = {};

  IJ3CHAR prefix_first = prefix[0];
  IJ3CHAR suffix_first = suffix[0];

  if (len == -1) len = strlen(src);

  for (; *src++;) {
    if (*src == prefix_first) {
      IJ3CHAR* src_ = src;
      IJ3CHAR* prefix_ = opts.prefix;

      // 在当前位置查找prefix
      for (; *src_ == *prefix_;) src_++, prefix_++;

      // 判断是否真的匹配完整了
      if (*prefix_ == '\0') {
        if (tokpos) {
          // 收集介于prefix和suffix之间的tagname的循环
          while (*src++) {
            // TODO: IJ3CHAR* tagname;

            if (*src == suffix_first) {
              // 在当前位置查找suffix
              for (; *src_ == *suffix_;) src_++, suffix_++;

              // 判断是否存在suffix
              if (*suffix_ != '\0') {
                fprintf(stderr, "Missing suffix!");
                exit(0);
              }
            }
          }

          // TODO: tokens[--tokpos] = ...

        } else
          fprintf(stderr, "token more than %d!\n", MAX_TOKLEN);
      } else {
        // TODO: 普通字符
      }
    }
  }
}
