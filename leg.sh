#!/bin/sh

####################################################################
# Created By: urain39@qq.com
# Source URL: https://github.com/urain39/stuff2/blob/master/leg.sh
# Last Updated: 2021-12-03 08:58:39
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
        read -r ENTRY_DIR SYNC_DELAY << EOT
$ENTRY
EOT

        [ ! -d "$ENTRY_DIR" ] && continue

        [ "$SYNC_DELAY" = "" ] && SYNC_DELAY=8

        DIR_NAME="$(echo "$ENTRY_DIR" | tr "/" "_")"
        ORG_DIR="$VDIR_MNT_DIR/org/$DIR_NAME"
        TMP_DIR="$VDIR_MNT_DIR/tmp/$DIR_NAME"

        vdir_callback
    done
}

vdir_init() {
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

[Service]
Type=oneshot
ExecStart=/bin/sh -c '"$THIS_FILE" start'
ExecStop=/bin/sh -c '"$THIS_FILE" stop'
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOT
        systemctl enable leg && systemctl start leg
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
        rc-update add leg && rc-service leg start
    else
        echo "Unsupported supervisor!" >&2
        exit 1
    fi

    vdir_sched
}

vdir_start() {
    [ -f "$RUN_CONF_FILE" ] && return

    if [ -f "$CONF_FILE" ]; then
        cat "$CONF_FILE" > "$RUN_CONF_FILE"
    else
        cat > "$RUN_CONF_FILE" << EOT
# vDIR List
VDIR_ENTRY_LIST="
/tmp	0
/root	4
/home	4
/var/log	12
/var/cache	24
"

# vDIR Sync
VDIR_RSYNC_EXEC="rsync"
VDIR_RSYNC_ARGS="-auy --inplace --no-whole-file --delete-after"

# vDIR Swap
VDIR_SWAP_SIZE="50"
EOT
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

    mkdir -p "$STATIC_DIR"
    if [ "$(stat -c "%u%g%a" "$STATIC_DIR")" != "001777" ]; then
        chown root:root "$STATIC_DIR"
        chmod 1777 "$STATIC_DIR"
    fi

    vdir_callback() {
        mkdir -p "$ORG_DIR"
        mkdir -p "$TMP_DIR"

        mount -o bind,private "$ENTRY_DIR" "$ORG_DIR"
        mount -o bind,private "$TMP_DIR" "$ENTRY_DIR"

        # Use eval is a trick to hack word splitting, that without reset IFS
        eval "$VDIR_RSYNC_EXEC" "$VDIR_RSYNC_ARGS" '"$ORG_DIR/"' '"$TMP_DIR/"'
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
        eval "$VDIR_RSYNC_EXEC" "$VDIR_RSYNC_ARGS" '"$TMP_DIR/"' '"$ORG_DIR/"'

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
        # 0 means disable sync
        [ "$SYNC_DELAY" = "0" ] && return

        if [ "$((VDIR_SYNC_COUNT % SYNC_DELAY))" = "0" ]; then
            # Use eval is a trick to hack word splitting, that without reset IFS
            eval "$VDIR_RSYNC_EXEC" "$VDIR_RSYNC_ARGS" '"$TMP_DIR/"' '"$ORG_DIR/"'
        fi
    }
    vdir_foreach

    RUN_CONF="$(sed '/^# leg-data-begin@/,/^# leg-data-end@/d' "$RUN_CONF_FILE")"
    PATCH_DATE="$(date +'%Y-%m-%d %H:%M:%S')"
    cat > "$RUN_CONF_FILE" << EOT
$RUN_CONF
# leg-data-begin@$PATCH_DATE
VDIR_SYNC_COUNT=$((VDIR_SYNC_COUNT + 1))
# leg-data-end@$PATCH_DATE
EOT
}

vdir_sched() {
    SCHED_LIST="$(crontab -l | sed '/^# leg-patch-begin@/,/^# leg-patch-end@/d')"
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
    vdir_init
    ;;
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
    echo "${0##*/} [init|start|stop|sync|sched]"
    ;;
esac

exit "$?"
