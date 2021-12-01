#!/bin/sh

if [ "$(whoami)" != "root" ]; then
    echo "You must run it as root!" >&2
    exit 0
fi

readonly CONF_FILE="/etc/leg.conf"
readonly VDIR_MNT_DIR="/mnt/leg/vdir"
readonly RUN_CONF_FILE="/run/leg.conf"
readonly SWAP_FILE="$VDIR_MNT_DIR/swapfile"

readonly RAM_SIZE="$(awk '$1 == "MemTotal:" { printf("%d", int($2) * 1024); exit }' /proc/meminfo)"
readonly RAM_HALF_SIZE="$((RAM_SIZE / 2))"
readonly CPU_COUNT="$(grep -c '^processor' /proc/cpuinfo)"

umask 022

vdir_callback() {
    : pass
}

vdir_foreach() {
    IFS='
'
    for ENTRY in $VDIR_ENTRY_LIST; do
        IFS='	'
        read -r ENTRY_DIR SYNC_DELAY << DELIM
$ENTRY
DELIM

        [ ! -d "$ENTRY_DIR" ] && continue

        [ "$SYNC_DELAY" = "" ] && SYNC_DELAY=1

        DIR_NAME="$(echo "$ENTRY_DIR" | tr "/" "_")"
        ORG_DIR="$VDIR_MNT_DIR/org/$DIR_NAME"
        TMP_DIR="$VDIR_MNT_DIR/tmp/$DIR_NAME"

        vdir_callback
    done
}

vdir_start() {
    [ -f "$RUN_CONF_FILE" ] && return

    if [ -f "$CONF_FILE" ]; then
        cat "$CONF_FILE" > "$RUN_CONF_FILE"
    else
        cat > "$RUN_CONF_FILE" << DELIM
# vDIR List
VDIR_ENTRY_LIST="
/var/log	6
/home	2
"

# vDIR Sync
VDIR_SYNC_EXEC="rsync"
VDIR_SYNC_ARGS="-auy --inplace --no-whole-file --delete-after"

# vDIR Swap
VDIR_SWAP_SIZE="50"
DELIM
    fi

    # shellcheck disable=SC1090
    . "$RUN_CONF_FILE"

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

        mount -o bind,private "$ENTRY_DIR" "$ORG_DIR"
        mount -o bind,private "$TMP_DIR" "$ENTRY_DIR"

        # Use eval is a trick to hack word splitting, that without reset IFS
        eval "$VDIR_SYNC_EXEC" "$VDIR_SYNC_ARGS" '"$ORG_DIR/"' '"$TMP_DIR/"'
    }
    vdir_foreach

    [ "$VDIR_SWAP_SIZE" = "" ] && return
    if [ "$VDIR_SWAP_SIZE" -gt 0 ] && [ "$VDIR_SWAP_SIZE" -le 50 ]; then
        SWAP_SIZE="$((RAM_SIZE * VDIR_SWAP_SIZE / 100))"
        dd if="/dev/zero" bs=4194304 count="$((SWAP_SIZE / 4194304))" of="$SWAP_FILE"
        chmod 600 "$SWAP_FILE"

        mkswap "$SWAP_FILE"
        swapon "$SWAP_FILE"
    fi
}

vdir_stop() {
    [ ! -f "$RUN_CONF_FILE" ] && return

    # shellcheck disable=SC1090
    . "$RUN_CONF_FILE"

    vdir_callback() {
        # Use eval is a trick to hack word splitting, that without reset IFS
        eval "$VDIR_SYNC_EXEC" "$VDIR_SYNC_ARGS" '"$TMP_DIR/"' '"$ORG_DIR/"'

        umount -l "$ENTRY_DIR"
        umount -l "$ORG_DIR"
    }
    vdir_foreach

    [ -f "$SWAP_FILE" ] && swapoff "$SWAP_FILE"
    umount -l "$VDIR_MNT_DIR"

    rm -f "$RUN_CONF_FILE"
    rm -rf "$VDIR_MNT_DIR"
}

vdir_sync() {
    [ ! -f "$RUN_CONF_FILE" ] && return

    # shellcheck disable=SC1090
    . "$RUN_CONF_FILE"

    [ "$VDIR_SYNC_COUNT" = "" ] && VDIR_SYNC_COUNT=0

    vdir_callback() {
        if [ "$((VDIR_SYNC_COUNT % SYNC_DELAY))" = "0" ]; then
            # Use eval is a trick to hack word splitting, that without reset IFS
            eval "$VDIR_SYNC_EXEC" "$VDIR_SYNC_ARGS" '"$TMP_DIR/"' '"$ORG_DIR/"'
        fi
    }
    vdir_foreach

    RUN_CONF="$(sed '/^# leg-data-begin@/,/^# leg-data-end@/d' "$RUN_CONF_FILE")"
    PATCH_DATE="$(date +'%Y-%m-%d %H:%M:%S')"
    cat > "$RUN_CONF_FILE" << DELIM
$RUN_CONF
# leg-data-begin@$PATCH_DATE
VDIR_SYNC_COUNT=$((VDIR_SYNC_COUNT + 1))
# leg-data-end@$PATCH_DATE
DELIM
}

vdir_sched() {
    SCHED_LIST="$(crontab -l | sed '/^# leg-patch-begin@/,/^# leg-patch-end@/d')"
    PATCH_DATE="$(date +'%Y-%m-%d %H:%M:%S')"
    crontab - << DELIM
$SCHED_LIST
# leg-patch-begin@$PATCH_DATE
  */5 *    * *       *     $(realpath "$0") sync
# leg-patch-end@$PATCH_DATE
DELIM
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
"sched")
    vdir_sched
    ;;
*)
    echo "${0##*/} [start|stop|sync|sched]"
    ;;
esac

exit "$?"
