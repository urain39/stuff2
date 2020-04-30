#!/system/bin/sh


KEEP_PKGS="\
com.termux
com.xunlei.downloadprovider\
"
KEEP_PROCS=""


refresh_keep_procs() {
  KEEP_PROCS="" # Clear
  while read -r PROC; do
    EXE="$(readlink "$PROC/exe")"
    if [ "${EXE:0:23}" != "/system/bin/app_process" ]; then
      continue
    fi
    PKG="$(cat "$PROC/cmdline")"
    IFS=$'\n'
    for PKG_ in $KEEP_PKGS; do
      if [ "$PKG" = "$PKG_" ]; then
        KEEP_PROCS="$KEEP_PROCS $PROC"
        break
      fi
    done
  done <<EOF
$(find /proc/ -type d -mindepth 1 -maxdepth 1 | grep -E '/proc/[0-9]+')
EOF
  echo "Refreshed processes at $(date +"%Y-%m-%d %H:%M:%S")."
}


refresh_keep_procs
COUNT=0
while sleep 5; do
  if ((COUNT >= 120)); then
    refresh_keep_procs
    COUNT=0
  fi
  IFS=" "
  for PROC in $KEEP_PROCS; do
    # $KEEP_PROCS outdated?
    if [ ! -d "$PROC" ]; then
      echo "\$KEEP_PROCS outdated." 
      refresh_keep_procs
      COUNT=0
      continue
    fi
    echo -17 > "$PROC/oom_adj"
    echo "Updated $PROC/oom_adj."
  done
  ((COUNT++))
done
