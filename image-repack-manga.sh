#!/bin/sh

BASENAME="${0##*/}"

exec > ~/"$BASENAME.out" 2> ~/"$BASENAME.err"

get_files() {
    sed -En '1,/^-{5}/d;/^-{5}/,$d;/\.([Jj][Pp][Gg]|[Pp][Nn][Gg])$/p'
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
magick_suffix="" # Default
#magick_suffix="-6" # Alpine
#magick_suffix="-im6" # Ubuntu
magick_width0="1680>" # Width < Height
magick_width1="3360>" # Width >= Height
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
    IFS='
'
    for entry in $(7z l "$arc" | get_files); do
        IFS=' 	'
        read -r _ _ _ _ _ file_ << EOI
$entry
EOI
        7z x -aoa -y "$arc" "$file_"
        echo "Started at $(date +'%Y-%m-%d %H:%M:%S')"
        width="$(identify"$magick_suffix" -format "%w" "$file_")"
        height="$(identify"$magick_suffix" -format "%h" "$file_")"
        if [ "$width" -lt "$height" ]; then
            resize_="$magick_width0"
        else
            resize_="$magick_width1"
        fi
        file__="${file_%.*}.webp"
        MAGICK_TEMPORARY_PATH="$magick_tmp_dir" convert"$magick_suffix" \
            -limit disk "786MiB" \
            -limit memory "512MiB" \
            -colorspace "YUV" \
            -depth "8" \
            -enhance \
            -interlace "none" \
            -quality "99%" \
            -resize "$resize_" \
            -sampling-factor "4:2:0" \
            -strip \
            "$file_" "$file__"
        [ "$file_" != "$file__" ] && rm "$file_"
        echo "Stopped at $(date +'%Y-%m-%d %H:%M:%S')"
        size="$(stat -c '%s' "$file__")"
        : "$((cache_size += size))"
        if [ "$cache_size" -gt "$cache_size_max" ]; then
            pack_files
        fi
    done
    if ls "$tmp_dir"/* > /dev/null 2>&1; then
        pack_files
    fi
    if ! ls "$store_dir/$name"/* > /dev/null 2>&1; then
        rm -r "$store_dir/$name"
    fi
done
