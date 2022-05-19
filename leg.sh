#!/bin/sh

####################################################################
# Created By: urain39@qq.com
# Source URL: https://github.com/urain39/stuff2/blob/master/leg.sh
# Last Updated: 2021-12-12 16:19:01
####################################################################

if [ "$(whoami)" != "root" ]; then
    echo "You must run it as root!" >&2
    exit 1
fi

readonly THIS_FILE="$(realpath "$0")"
readonly CONF_FILE="/etc/leg.conf"

readonly STATIC_DIR="/static"
readonly VDIR_MNT_DIR="/mnt/leg/vdir"
readonly RUN_CONF_FILE="/run/leg.conf"

readonly RAM_SIZE="$(awk '$1 == "MemTotal:" { printf("%d", int($2) * 1024); exit }' /proc/meminfo)"
readonly CPU_COUNT="$(grep -c '^processor' /proc/cpuinfo)"

readonly RUN_LOG_DIR="/var/log/leg"
readonly DATE_TODAY="$(date +"%Y-%m-%d")"
readonly CURRENT_TTY="$(realpath "/dev/stdin")"

umask 022

leg_log_begin() {
    mkdir -p "$RUN_LOG_DIR"
    exec >> "$RUN_LOG_DIR/$DATE_TODAY.log" 2>&1
}

leg_log_end() {
    exec > "$CURRENT_TTY" 2> "$CURRENT_TTY"
}

leg_callback() {
    : pass
}

leg_foreach() {
    IFS='
'
    for ENTRY in $VDIR_ENTRY_LIST; do
        IFS='	'
        read -r ENTRY_DIR SYNC_DELAY << EOT
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
        cat > '/etc/systemd/system/leg.service' << EOT
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
        systemctl enable leg
    elif command -v openrc > /dev/null; then
        cat > '/etc/init.d/leg' << EOT
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
        chmod 755 '/etc/init.d/leg'
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
ZRAM_VDIR_ALGS="lzo-rle	zstd"
ZRAM_SWAP_ALGS="lzo-rle	lzo"
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

    modprobe zram num_devices="2"

    echo "1" > "/sys/block/zram0/reset"
    echo "$CPU_COUNT" > "/sys/block/zram0/max_comp_streams"
    IFS='	'
    for ALG in $ZRAM_VDIR_ALGS; do
        (echo "$ALG" > "/sys/block/zram0/comp_algorithm") 2> /dev/null && break
    done
    echo "$VDIR_SIZE" > "/sys/block/zram0/disksize"

    mkfs.ext4 -F "/dev/zram0"
    mkdir -p "$VDIR_MNT_DIR"
    mount "/dev/zram0" "$VDIR_MNT_DIR"

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

        echo "[$(date +"%Y-%m-%d %H:%M:%S")] $ORG_DIR -> $TMP_DIR"

        # Use eval is a trick to hack word splitting, that without reset IFS
        eval "$VDIR_SYNC_EXEC" "$VDIR_SYNC_ARGS" '"$ORG_DIR/"' '"$TMP_DIR/"'
    }
    leg_foreach

    echo "1" > "/sys/block/zram1/reset"
    echo "$CPU_COUNT" > "/sys/block/zram1/max_comp_streams"
    IFS='	'
    for ALG in $ZRAM_SWAP_ALGS; do
        (echo "$ALG" > "/sys/block/zram1/comp_algorithm") 2> /dev/null && break
    done
    echo "$SWAP_SIZE" > "/sys/block/zram1/disksize"

    mkswap "/dev/zram1"
    swapon -p 32767 "/dev/zram1"
}

leg_stop() {
    [ ! -f "$RUN_CONF_FILE" ] && return

    # shellcheck disable=SC1090
    . "$RUN_CONF_FILE"

    leg_callback() {
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] $ORG_DIR <- $TMP_DIR"

        # Use eval is a trick to hack word splitting, that without reset IFS
        eval "$VDIR_SYNC_EXEC" "$VDIR_SYNC_ARGS" '"$TMP_DIR/"' '"$ORG_DIR/"'

        umount -l "$ENTRY_DIR"
        umount -l "$ORG_DIR"
    }
    leg_foreach

    swapoff "/dev/zram1"
    umount -l "$VDIR_MNT_DIR"

    rm -f "$RUN_CONF_FILE"
    rm -rf "$VDIR_MNT_DIR"
}

leg_sync() {
    [ ! -f "$RUN_CONF_FILE" ] && return

    # shellcheck disable=SC1090
    . "$RUN_CONF_FILE"

    [ "$VDIR_SYNC_COUNT" = "" ] && VDIR_SYNC_COUNT="0"

    leg_callback() {
        # 0 means disable sync
        [ "$SYNC_DELAY" = "0" ] && return

        if [ "$((VDIR_SYNC_COUNT % SYNC_DELAY))" = "0" ]; then
            echo "[$(date +"%Y-%m-%d %H:%M:%S")] $ORG_DIR <- $TMP_DIR"

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
VDIR_SYNC_COUNT=$((VDIR_SYNC_COUNT + 1))
# leg-data-end@$PATCH_DATE
EOT

    # Remove old logs
    find "$RUN_LOG_DIR" -type f -mtime +30 -delete
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
