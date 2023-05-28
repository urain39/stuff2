dir2file() {
  rm -fr "$1" && touch "$1"
}


# SnapDragon WLAN Logs
dir2file /sdcard/wlan_logs

# MeizuSecurity
dir2file /sdcard/Android/data/com.meizu.safe/UpdateCache

# MeizuBattery
dir2file /sdcard/Android/data/com.meizu.battery/InstallCache
