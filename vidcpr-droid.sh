#!/bin/sh

set -e

input="${1:-"test.mp4"}"
quality="${2:-"65"}"
codec="${3:-"hevc"}"

ffmpeg -y \
  -hwaccel mediacodec \
  -i "$input" \
  -c:v "${codec}_mediacodec" \
  -bitrate_mode:v 0 \
  -global_quality:v "$quality" \
  "!$input"
