#!/bin/sh

readonly CFG_FILE="/etc/leg/config.conf"
readonly VDIR_MNT_DIR="/mnt/leg/vdir"
readonly RUN_CFG_FILE="/run/leg.conf"
readonly SWAP_FILE="$VDIR_MNT_DIR/swapfile"

readonly RAM_SIZE="$(awk '$1 == "MemTotal:" { printf("%d", int($2) * 1024); exit }' /proc/meminfo)"
readonly RAM_HALF_SIZE="$((RAM_SIZE / 2))"
readonly CPU_COUNT="$(grep -c '^processor' /proc/cpuinfo)"

umask 022

vdir_callback() { :; }

vdir_foreach() {
    IFS="
"
    for ENT_DIR in $VDIR_ENTRY_LIST; do
        if [ ! -d "$ENT_DIR" ]; then
            continue
        fi

        DIR_NAME="$(echo "$ENT_DIR" | tr "/" "_")"
        ORG_DIR="$VDIR_MNT_DIR/org/$DIR_NAME"
        TMP_DIR="$VDIR_MNT_DIR/tmp/$DIR_NAME"

        vdir_callback
    done
}

vdir_start() {
    [ -f "$RUN_CFG_FILE" ] && return

    if [ -f "$CFG_FILE" ]; then
        cat "$CFG_FILE" > "$RUN_CFG_FILE"
    else
        : > "$RUN_CFG_FILE"
    fi

    # shellcheck disable=SC1090
    . "$RUN_CFG_FILE"

    rm -rf "$VDIR_MNT_DIR"
    modprobe zram num_devices=1

    echo "1" > "/sys/block/zram0/reset"
    echo "$CPU_COUNT" > "/sys/block/zram0/max_comp_streams"
    echo "$RAM_SIZE" > "/sys/block/zram0/disksize"

    mkfs.ext4 -F "/dev/zram0"
    mkdir -p "$VDIR_MNT_DIR"
    mount "/dev/zram0" "$VDIR_MNT_DIR"

    vdir_callback() {
        mkdir -p "$ORG_DIR"
        mkdir -p "$TMP_DIR"

        mount -o bind "$ENT_DIR" "$ORG_DIR"
        mount -o bind "$TMP_DIR" "$ENT_DIR"

        eval "$VDIR_SYNC_EXEC" "$VDIR_SYNC_ARGS" '"$ORG_DIR/"' '"$TMP_DIR/"'
    }
    vdir_foreach

    [ "$VDIR_SWAP_SIZE" = "" ] && return
    if [ "$VDIR_SWAP_SIZE" -gt 0 ] && [ "$VDIR_SWAP_SIZE" -le 50 ]; then
        SWAP_SIZE="$((RAM_SIZE * VDIR_SWAP_SIZE / 100))"
        dd if="/dev/zero" bs=4194304 count="$((SWAP_SIZE / 4194304))" of="$SWAP_FILE"
        mkswap "$SWAP_FILE"
        swapon "$SWAP_FILE"
    fi
}

vdir_stop() {
    [ ! -f "$RUN_CFG_FILE" ] && return

    # shellcheck disable=SC1090
    . "$RUN_CFG_FILE"

    vdir_callback() {
        eval "$VDIR_SYNC_EXEC" "$VDIR_SYNC_ARGS" '"$TMP_DIR/"' '"$ORG_DIR/"'

        umount -l "$ENT_DIR"
        umount -l "$ORG_DIR"
    }
    vdir_foreach

    swapoff "$SWAP_FILE"
    umount -l "$VDIR_MNT_DIR"

    rm -f "$RUN_CFG_FILE"
    rm -rf "$VDIR_MNT_DIR"
}

vdir_sync() {
    [ ! -f "$RUN_CFG_FILE" ] && return

    # shellcheck disable=SC1090
    . "$RUN_CFG_FILE"

    vdir_callback() {
        eval "$VDIR_SYNC_EXEC" "$VDIR_SYNC_ARGS" '"$TMP_DIR/"' '"$ORG_DIR/"'
    }
    vdir_foreach
}

case "$1" in
"start")
    vdir_start
    ;;
"stop")
    vdir_stop
    ;;
"sync")
    vdir_sync
    ;;
*)
    echo "${0##*/} [start|stop|sync]"
    ;;
esac

exit "$?"
