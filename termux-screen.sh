#!/bin/sh

is_termux_direct_shell() {
  local ppid="$(awk '$1 == "PPid:" { print $2; exit 0 }' "/proc/$$/status")"
  local comm="$(cat "/proc/${ppid}/comm")"
  [ "${comm}" = "com.termux" ]
}

if is_termux_direct_shell; then
  screen -wipe host
  screen -S host
fi
