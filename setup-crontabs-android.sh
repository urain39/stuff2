# Set default permission
umask 022

# Make /system writable
mount -o rw,remount /system

# Create missing passwd file
echo "root:x:0:0:root:/:/system/bin/sh" > /system/etc/passwd
echo "shell:x:2000:2000:shell:/:/system/bin/sh" >> /system/etc/passwd

# Create necessary directory
mkdir -p /data/cron/tabs
mkdir -p /data/cron/00closely
mkdir -p /data/cron/01hourly
mkdir -p /data/cron/02daily
mkdir -p /data/cron/03weekly
mkdir -p /data/cron/04monthly

# Add default crontab
cat > /data/cron/tabs/root << EOF
# NOTE: Busybox crontab doesn't support variable with quotes
SHELL=/system/bin/sh
PATH=/sbin:/system/bin:/system/xbin

# m h       dom mon   dow   cmd
  */15 *    * *       *     run-parts /data/cron/00closely
  10 *      * *       *     run-parts /data/cron/01hourly
  20 22     * *       *     run-parts /data/cron/02daily
# NOTE: Busybox cron expression use 0 as sunday only
  30 22     * *       0     run-parts /data/cron/03weekly
  40 22     1 *       *     run-parts /data/cron/04monthly
# Uncomment following line to reduce time disparity while dozing
#  */30 *    * *       *     input keyevent KEYCODE_POWER
EOF
cat > /data/cron/tabs/shell << EOF
# NOTE: Busybox crontab doesn't support variable with quotes
SHELL=/system/bin/sh
PATH=/sbin:/system/bin:/system/xbin

# m h       dom mon   dow   cmd
#  29 05     * *       *     sleep 60 && reboot
EOF

# Add init.d script
cat > /system/etc/init.d/00crond << EOF
#!/system/bin/sh
crond -b -l7 -L /data/cron/messages -c /data/cron/tabs
EOF
chmod 755 /system/etc/init.d/00crond

# Make /system read-only
mount -o ro,remount /system
