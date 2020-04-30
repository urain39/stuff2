#!/bin/sh

####################################################################
# Created By: urain39@qq.com
# Source URL: https://github.com/urain39/stuff2/blob/master/leg.sh
# Last Updated: 2024-05-17 20:03:36 +0800
####################################################################

if [ "$(whoami)" != "root" ]; then
    echo "You must run it as root!" >&2
    exit 1
fi

# shellcheck disable=SC2155
readonly THIS_FILE="$(realpath "$0")"
readonly CONF_FILE="/etc/leg.conf"
readonly RUN_CONF_FILE="/run/leg.conf"

readonly ZRAM_DEV_NUM="2"
readonly ZRAM_VDIR_DEV="/dev/zram0"
readonly ZRAM_VDIR_CONF="/sys/block/zram0"
readonly ZRAM_SWAP_DEV="/dev/zram1"
readonly ZRAM_SWAP_CONF="/sys/block/zram1"

readonly SERVICE_FILE_SYSTEMD="/etc/systemd/system/leg.service"
readonly SERVICE_FILE_OPENRC="/etc/init.d/leg"

readonly STATIC_DIR="/static"
readonly VDIR_MNT_DIR="/mnt/leg/vdir"

# shellcheck disable=SC2155
readonly RAM_SIZE="$(awk '$1 == "MemTotal:" { printf("%d", int($2) * 1024); exit }' /proc/meminfo)"
# shellcheck disable=SC2155
readonly CPU_COUNT="$(grep -c '^processor' /proc/cpuinfo)"

readonly LOG_DIR="$STATIC_DIR/log/leg"
# shellcheck disable=SC2155
readonly DATE_TODAY="$(date +"%Y-%m-%d")"

umask 0077

leg_log_begin() {
    mkdir -p "$LOG_DIR"

    exec 9>&1 8>&2 >> "$LOG_DIR/$DATE_TODAY.log" 2>&1
}

leg_log_end() {
    exec >&9 2>&8 9>&- 8>&-
}

leg_callback() {
    :
}

leg_foreach() {
    IFS='
'
    for ENTRY in $VDIR_ENTRY_LIST; do
        IFS='	' read -r ENTRY_DIR SYNC_DELAY << EOT
$ENTRY
EOT

        [ ! -d "$ENTRY_DIR" ] && continue

        [ "$SYNC_DELAY" = "" ] && SYNC_DELAY="8"

        DIR_NAME="$(echo "$ENTRY_DIR" | tr "/" "_")"
        ORG_DIR="$VDIR_MNT_DIR/org/$DIR_NAME"
        TMP_DIR="$VDIR_MNT_DIR/tmp/$DIR_NAME"

        leg_log_begin
        leg_callback
        leg_log_end
    done
}

leg_init() {
    if ! command -v rsync > /dev/null; then
        echo "Did you installed rsync?" >&2
        exit 1
    fi

    if command -v systemd > /dev/null; then
        cat > "$SERVICE_FILE_SYSTEMD" << EOT
[Unit]
DefaultDependencies=no
After=local-fs.target
Before=rsyslog.service sysinit.target syslog.target
Conflicts=shutdown.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c '"$THIS_FILE" start'
ExecStop=/bin/sh -c '"$THIS_FILE" stop'
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOT
        chmod 0644 "$SERVICE_FILE_SYSTEMD"
        systemctl enable leg
    elif command -v openrc > /dev/null; then
        cat > "$SERVICE_FILE_OPENRC" << EOT
#!/sbin/openrc-run

depend() {
    after localmount
    before acpid logger
}

start() {
    "$THIS_FILE" start
}

stop() {
    "$THIS_FILE" stop
}
EOT
        chmod 0755 "$SERVICE_FILE_OPENRC"
        rc-update add leg
    else
        echo "Unsupported supervisor!" >&2
        exit 1
    fi

    leg_sched
}

leg_start() {
    [ -f "$RUN_CONF_FILE" ] && return

    if [ -f "$CONF_FILE" ]; then
        cat "$CONF_FILE" > "$RUN_CONF_FILE"
    else
        cat > "$RUN_CONF_FILE" << \EOT
# vDIR List
VDIR_ENTRY_LIST="
/tmp	0
/root	8
/home	8
/var/log	24
/var/cache	24
/var/lib/rpimonitor	24
"

# vDIR Sync
VDIR_SYNC_EXEC="rsync"
VDIR_SYNC_ARGS="-auvxy --inplace --no-whole-file --delete-after --"

# vDIR Swap
VDIR_SWAP_SIZE="100"

# zRAM Compression
ZRAM_OVER_SIZE="150"
ZRAM_CONST_SIZE="10"
ZRAM_VDIR_ALGS="zstd	lzo-rle"
ZRAM_SWAP_ALGS="zstd	lzo-rle"
EOT
    fi

    # shellcheck disable=SC1090
    . "$RUN_CONF_FILE"

    if [ "$ZRAM_OVER_SIZE" = "" ] ||
        [ "$ZRAM_OVER_SIZE" -lt 125 ] ||
        [ "$ZRAM_OVER_SIZE" -gt 250 ]; then
        ZRAM_OVER_SIZE="150"
    fi

    if [ "$VDIR_SWAP_SIZE" = "" ] ||
        [ "$VDIR_SWAP_SIZE" -le 0 ] ||
        [ "$VDIR_SWAP_SIZE" -gt "$((ZRAM_OVER_SIZE * 3 / 4))" ]; then
        VDIR_SWAP_SIZE="$((ZRAM_OVER_SIZE * 2 / 3))"
    fi

    USABLE_SIZE="$RAM_SIZE"
    if [ "$ZRAM_CONST_SIZE" != "" ] &&
        [ "$ZRAM_CONST_SIZE" -gt 0 ] &&
        [ "$ZRAM_CONST_SIZE" -le 25 ]; then
        USABLE_SIZE="$((USABLE_SIZE * (100 - ZRAM_CONST_SIZE) / 100))"
    fi

    VDIR_SIZE="$((USABLE_SIZE * (ZRAM_OVER_SIZE - VDIR_SWAP_SIZE) / 100))"
    SWAP_SIZE="$((USABLE_SIZE * VDIR_SWAP_SIZE / 100))"

    modprobe zram num_devices="$ZRAM_DEV_NUM"

    echo "1" > "$ZRAM_VDIR_CONF/reset"
    echo "$CPU_COUNT" > "$ZRAM_VDIR_CONF/max_comp_streams"
    IFS='	'
    for ALG in $ZRAM_VDIR_ALGS; do
        (echo "$ALG" > "$ZRAM_VDIR_CONF/comp_algorithm") 2> /dev/null && break
    done
    echo "$VDIR_SIZE" > "$ZRAM_VDIR_CONF/disksize"

    mkfs.ext4 -F "$ZRAM_VDIR_DEV"
    mkdir -p "$VDIR_MNT_DIR"
    mount "$ZRAM_VDIR_DEV" "$VDIR_MNT_DIR"

    mkdir -p "$STATIC_DIR"
    if [ "$(stat -c "%u%g%a" "$STATIC_DIR")" != "001777" ]; then
        chown root:root "$STATIC_DIR"
        chmod 1777 "$STATIC_DIR"
    fi

    leg_callback() {
        mkdir -p "$ORG_DIR"
        mkdir -p "$TMP_DIR"

        mount -o bind,private "$ENTRY_DIR" "$ORG_DIR"
        mount -o bind,private "$TMP_DIR" "$ENTRY_DIR"

        echo "[$(date +"%Y-%m-%d %H:%M:%S")] '$ORG_DIR' => '$TMP_DIR'"

        # Use eval is a trick to hack word splitting, that without reset IFS
        eval "$VDIR_SYNC_EXEC" "$VDIR_SYNC_ARGS" '"$ORG_DIR/"' '"$TMP_DIR/"'
    }
    leg_foreach

    echo "1" > "$ZRAM_SWAP_CONF/reset"
    echo "$CPU_COUNT" > "$ZRAM_SWAP_CONF/max_comp_streams"
    IFS='	'
    for ALG in $ZRAM_SWAP_ALGS; do
        (echo "$ALG" > "$ZRAM_SWAP_CONF/comp_algorithm") 2> /dev/null && break
    done
    echo "$SWAP_SIZE" > "$ZRAM_SWAP_CONF/disksize"

    mkswap "$ZRAM_SWAP_DEV"
    swapon -p 32767 "$ZRAM_SWAP_DEV"
}

leg_stop() {
    [ ! -f "$RUN_CONF_FILE" ] && return

    # shellcheck disable=SC1090
    . "$RUN_CONF_FILE"

    leg_callback() {
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] '$ORG_DIR' <= '$TMP_DIR'"

        # Use eval is a trick to hack word splitting, that without reset IFS
        eval "$VDIR_SYNC_EXEC" "$VDIR_SYNC_ARGS" '"$TMP_DIR/"' '"$ORG_DIR/"'

        umount -l "$ENTRY_DIR"
        umount -l "$ORG_DIR"
    }
    leg_foreach

    swapoff "$ZRAM_SWAP_DEV"
    umount -l "$VDIR_MNT_DIR"

    rm -f "$RUN_CONF_FILE"
    rm -rf "$VDIR_MNT_DIR"
}

leg_sync() {
    [ ! -f "$RUN_CONF_FILE" ] && return

    # shellcheck disable=SC1090
    . "$RUN_CONF_FILE"

    [ "$VDIR_SYNC_COUNT" = "" ] && VDIR_SYNC_COUNT="0"
    : "$((VDIR_SYNC_COUNT += 1))"

    leg_callback() {
        # 0 means disable sync
        [ "$SYNC_DELAY" = "0" ] && return

        if [ "$((VDIR_SYNC_COUNT % SYNC_DELAY))" = "0" ]; then
            echo "[$(date +"%Y-%m-%d %H:%M:%S")] '$ORG_DIR' <= '$TMP_DIR'"

            # Use eval is a trick to hack word splitting, that without reset IFS
            eval "$VDIR_SYNC_EXEC" "$VDIR_SYNC_ARGS" '"$TMP_DIR/"' '"$ORG_DIR/"'
        fi
    }
    leg_foreach

    RUN_CONF="$(sed '/^# leg-data-begin@/,/^# leg-data-end@/d' "$RUN_CONF_FILE")"
    PATCH_DATE="$(date +'%Y-%m-%d %H:%M:%S')"
    cat > "$RUN_CONF_FILE" << EOT
$RUN_CONF
# leg-data-begin@$PATCH_DATE
VDIR_SYNC_COUNT=$VDIR_SYNC_COUNT
# leg-data-end@$PATCH_DATE
EOT

    # Remove old logs
    find "$LOG_DIR/" -type f -mtime +30 -delete
}

leg_sched() {
    SCHED_LIST="$(crontab -l 2> /dev/null | sed '/^# leg-patch-begin@/,/^# leg-patch-end@/d')"
    PATCH_DATE="$(date +'%Y-%m-%d %H:%M:%S')"
    crontab - << EOT
$SCHED_LIST
# leg-patch-begin@$PATCH_DATE
  00 *      * *       *     "$THIS_FILE" sync
# leg-patch-end@$PATCH_DATE
EOT
}

case "$1" in
"init")
    leg_init
    ;;
"start")
    leg_start
    ;;
"stop")
    leg_stop
    ;;
"sync")
    leg_sync
    ;;
"sched")
    leg_sched
    ;;
*)
    echo "${0##*/} [init|start|stop|sync|sched]"
    ;;
esac

exit "$?"
