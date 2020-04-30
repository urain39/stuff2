#!/bin/sh

BASENAME="${0##*/}"

exec > ~/"$BASENAME.out" 2> ~/"$BASENAME.err"

get_files() {
    sed -En '1,/^-{5}/d;/^-{5}/,$d;p'
}

pack_files() {
    : "$((pack_count += 1))"
    7z a -mx3 "$store_dir/$name/$name.$(printf "%03d" "$pack_count").$extname" -r -- *
    rm -rf -- *
    : "$((cache_size = 0))"
}

set -e

org_dir="$HOME/my-msod-enc/qBittorrent"
tmp_dir="/tmp/$$.tmp"
# 设置临时文件目录为 /dev/shm 的原因如下：
#     1. /dev/shm 能保证在内存中操作
#     2. 临时文件的可压缩空间非常高（配合 zRAM）
#     3. 旧版不能在低内存状态下将 disk 限制为 0B
#     4. 瞬时请求大内存容易触发 OOM （zRAM bug？）
magick_tmp_dir="/dev/shm"
store_dir="$HOME/my-msod-enc/Repack"
cache_size_max="$((100 * (1 << 20)))"
for arc in "$org_dir"/*.zip; do
    arcname="${arc##*/}"
    name="${arcname%.*}"
    extname="${arcname##*.}"
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir"
    [ -d "$store_dir/$name" ] && continue
    mkdir -p "$store_dir/$name"
    cache_size=0
    pack_count=0
    while read -r _ _ _ _ _ file_; do
        7z x -aoa -y "$arc" "$file_"
        echo "Started at $(date +'%Y-%m-%d %H:%M:%S')"
        MAGICK_TEMPORARY_PATH="$magick_tmp_dir" convert \
            -limit disk "512MiB" \
            -limit memory "256MiB" \
            -colorspace "YUV" \
            -depth "8" \
            -interlace "none" \
            -quality "0" \
            -resize "1680>" \
            -sampling-factor "4:2:0" \
            "$file_" "$file_"
        echo "Stopped at $(date +'%Y-%m-%d %H:%M:%S')"
        size="$(stat -c '%s' "$file_")"
        : "$((cache_size += size))"
        if [ "$cache_size" -gt "$cache_size_max" ]; then
            pack_files
        fi
    done << EOT
$(7z l "$arc" | get_files)
EOT
    if ls "$tmp_dir"/* > /dev/null 2>&1; then
        pack_files
    fi
done
