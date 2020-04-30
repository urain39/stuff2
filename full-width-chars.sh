: '
// From: Windows-Server-2003/sdktools/trace/inc/varg.c#L1214
BOOL IsFullWidth(TCHAR wch)
{
    if (0x20 <= wch && wch <= 0x7e)
        /* ASCII */
        return FALSE;
    else if (0x3000 <= wch && wch <= 0x3036)
        /* CJK Symbols and Punctuation */
        return TRUE;
    else if (0x3041 <= wch && wch <= 0x3094)
        /* Hiragana */
        return TRUE;
    else if (0x30a1 <= wch && wch <= 0x30fe)
        /* Katakana */
        return TRUE;
    else if (0x3105 <= wch && wch <= 0x312c)
        /* Bopomofo */
        return TRUE;
    else if (0x3131 <= wch && wch <= 0x318e)
        /* Hangul Elements */
        return TRUE;
    else if (0x3200 <= wch && wch <= 0x32ff)
        /* Enclosed CJK Letters and Ideographics */
        return TRUE;
    else if (0x3300 <= wch && wch <= 0x33fe)
        /* CJK Squared Words and Abbreviations */
        return TRUE;
    else if (0xac00 <= wch && wch <= 0xd7a3)
        /* Korean Hangul Syllables */
        return TRUE;
    else if (0xe000 <= wch && wch <= 0xf8ff)
        /* EUDC */
        return TRUE;
    else if (0xff01 <= wch && wch <= 0xff5e)
        /* Fullwidth ASCII variants */
        return TRUE;
    else if (0xff61 <= wch && wch <= 0xff9f)
        /* Halfwidth Katakana variants */
        return FALSE;
    else if ( (0xffa0 <= wch && wch <= 0xffbe) ||
              (0xffc2 <= wch && wch <= 0xffc7) ||
              (0xffca <= wch && wch <= 0xffcf) ||
              (0xffd2 <= wch && wch <= 0xffd7) ||
              (0xffda <= wch && wch <= 0xffdc)   )
        /* Halfwidth Hangule variants */
        return FALSE;
    else if (0xffe0 <= wch && wch <= 0xffe6)
        /* Fullwidth symbol variants */
        return TRUE;
    else if (0x4e00 <= wch && wch <= 0x9fa5)
        /* CJK Ideographic */
        return TRUE;
    else if (0xf900 <= wch && wch <= 0xfa2d)
        /* CJK Compatibility Ideographs */
        return TRUE;
    else if (0xfe30 <= wch && wch <= 0xfe4f) {
        /* CJK Compatibility Forms */
        return TRUE;
    }

    else
        /* Unknown character */
        return FALSE;
}
'

awk '/^[\u3000-\u3036\u3041-\u3094\u30A1-\u30FE\u3105-\u312C\u3131-\u318E\u3200-\u32FF\u3300-\u33FE\uAC00-\uD7A3\uE000-\uF8FF\uFF01-\uFF5E\uFFE0-\uFFE6\u4E00-\u9FA5\uF900-\uFA2D\uFE30-\uFE4F]+$/ {
  print
}'
