#!/bin/sh

REMOTES="22-msod-enc:"
EXTENSIONS="{GIF,JFIF,JPEG,JPG,MD,MHTML,PNG,TXT,WEBP,gif,jfif,jpeg,jpg,md,mhtml,png,txt,webp}"

# Replace it with "**", if rclone supported globstar someday...
GLOBSTARS="{,*/,*/*/,*/*/*/}"
for REMOTE in $REMOTES; do
    rclone copy "/sdcard/" "$REMOTE/FakeSD/" \
        --include "/ADM/$GLOBSTARS*.$EXTENSIONS" \
        --include "/Android/data/com.tencent.mobileqq/Tencent/QQ_Images/$GLOBSTARS*.$EXTENSIONS" \
        --include "/Android/data/com.tencent.mobileqq/Tencent/QQfile_recv/$GLOBSTARS*.$EXTENSIONS" \
        --include "/Android/data/com.tencent.tim/Tencent/Tim_Images/$GLOBSTARS*.$EXTENSIONS" \
        --include "/DCIM/$GLOBSTARS*.$EXTENSIONS" \
        --include "/Download/$GLOBSTARS*.$EXTENSIONS" \
        --include "/Pictures/$GLOBSTARS*.$EXTENSIONS" \
        --include "/[Tt]encent/QQ_Images/$GLOBSTARS*.$EXTENSIONS" \
        --include "/[Tt]encent/Tim_Images/$GLOBSTARS*.$EXTENSIONS" \
        --include "/tieba/$GLOBSTARS*.$EXTENSIONS"
done
