dir2file() {
  rm -fr "$1" && \
    mkdir -p "${1%/*}" && \
    touch "$1" && \
    chmod 000 "$1" && \
    chattr +i "$1"
}


# SnapDragon WLAN Logs
dir2file "/data/media/0/wlan_logs"

# MeizuSecurity
dir2file "/data/media/0/Android/data/com.meizu.safe/UpdateCache"

# MeizuBattery
dir2file "/data/media/0/Android/data/com.meizu.battery/InstallCache"
