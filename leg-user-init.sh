#!/sbin/openrc-run

callback() {
    : pass
}

foreach() {
    IFS='
'
    # shellcheck disable=SC2013
    for LINE in $(awk -vFS=':' -vOFS='	' '$3 >= 1000 && $3 < 6000 { print $1, $6 }' /etc/passwd); do
        IFS='	'
        read -r USER_ HOME_ << EOT
$LINE
EOT
        SCRIPT_DIR="$HOME_/.config/leg-user-init.d"
        if [ -d "$SCRIPT_DIR" ]; then
            callback
        fi
    done
}

start() {
    callback() {
        su - "$USER_" -s '/bin/sh' -c "
            run-parts -a 'start' \"$SCRIPT_DIR\"
        " >> /run/leg-user-init.log 2>&1
    }
    foreach
}

stop() {
    callback() {
        su - "$USER_" -s '/bin/sh' -c "
            run-parts -a 'stop' \"$SCRIPT_DIR\"
        " >> /run/leg-user-init.log 2>&1
    }
    foreach
}
