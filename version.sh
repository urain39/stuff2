#! /bin/sh
awk 'BEGIN { printf "%08x", systime() }'
