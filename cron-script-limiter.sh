#!/bin/sh
#
# Cron Script Limiter
#
# Usage: ln -sf ${this_file} ${your_script}-
#
# This symlink will switch ${your_script} state
# in every cycles, it means ${your_script} will
# takes 2-cycles time to run 1-cycle. It may be
# useful for you limit run ${your_script}.

SCRIPT="${0%-}"

if [ -f "$SCRIPT" ]; then
    if [ -x "$SCRIPT" ]; then
        chmod u-x "$SCRIPT"
    else
        chmod u+x "$SCRIPT"
    fi
fi
