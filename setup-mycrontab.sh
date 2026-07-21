if [ "$USER" = "root" ]; then
    echo "Please run it as non-root user!" >&2
    exit 1
fi

# Set default permission
umask 022

# Create necessary directory
mkdir -p ~/.local/share/mycrontab/closely
mkdir -p ~/.local/share/mycrontab/hourly
mkdir -p ~/.local/share/mycrontab/daily
mkdir -p ~/.local/share/mycrontab/weekly
mkdir -p ~/.local/share/mycrontab/monthly

# Add default crontab
crontab - << \EOF
# NOTE: Busybox crontab doesn't support variable with quotes
SHELL=/bin/sh

# m h       dom mon   dow   cmd
  */15 *    * *       *     flock -x -w 60 ~/.local/share/mycrontab/closely/.lock run-parts ~/.local/share/mycrontab/closely
  10 *      * *       *     flock -x -w 60 ~/.local/share/mycrontab/hourly/.lock run-parts ~/.local/share/mycrontab/hourly
  20 22     * *       *     flock -x -w 60 ~/.local/share/mycrontab/daily/.lock run-parts ~/.local/share/mycrontab/daily
# NOTE: Busybox cron expression use 0 as sunday only
  30 22     * *       0     flock -x -w 60 ~/.local/share/mycrontab/weekly/.lock run-parts ~/.local/share/mycrontab/weekly
  40 22     1 *       *     flock -x -w 60 ~/.local/share/mycrontab/monthly/.lock run-parts ~/.local/share/mycrontab/monthly
EOF
