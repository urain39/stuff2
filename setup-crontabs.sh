if [ "$USER" = "root" ]; then
    echo "Please run it as non-root user!" >&2
    exit 1
fi

# Set default permission
umask 022

# Create necessary directory
mkdir -p ~/.local/share/crontabs/00closely
mkdir -p ~/.local/share/crontabs/01hourly
mkdir -p ~/.local/share/crontabs/02daily
mkdir -p ~/.local/share/crontabs/03weekly
mkdir -p ~/.local/share/crontabs/04monthly

# Add default crontab
crontab - << EOF
# NOTE: Busybox crontab doesn't support variable with quotes
SHELL=/bin/sh

# m h       dom mon   dow   cmd
  */15 *    * *       *     run-parts ~/.local/share/crontabs/00closely
  10 *      * *       *     run-parts ~/.local/share/crontabs/01hourly
  20 22     * *       *     run-parts ~/.local/share/crontabs/02daily
# NOTE: Busybox cron expression use 0 as sunday only
  30 22     * *       0     run-parts ~/.local/share/crontabs/03weekly
  40 22     1 *       *     run-parts ~/.local/share/crontabs/04monthly
EOF
