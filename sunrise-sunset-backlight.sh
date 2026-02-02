#!/bin/sh

# 常量定义：杭州经纬度
LAT="30.2741"; LON="120.1551"; TZ="8"

# 获取时间并去除前导零（兼容 Busybox）
current_hour="$( date +%H | sed 's/^0//' )"
current_minute="$( date +%M | sed 's/^0//' )"
doy="$( date +%j | sed 's/^0//' )"

# 处理空值（防止 sed 后全空的情况）
[ -z "${current_hour}" ] && current_hour="0"
[ -z "${current_minute}" ] && current_minute="0"
[ -z "${doy}" ] && doy="0"

# 计算当前分钟数
current_minutes="$(( ${current_hour} * 60 + ${current_minute} ))"

# 计算日出/日落时间
read -r sunrise_minutes sunset_minutes <<EOF
 $( awk -v lat="${LAT}" -v lon="${LON}" -v tz="${TZ}" -v doy="${doy}" '
BEGIN {
  pi = 4 * atan2( 1, 1 )
  rad = pi / 180.0
  deg = 180.0 / pi
  g = 2 * pi / 365.0 * ( doy - 1 )
  eq = 229.18 * ( 0.000075 + 0.001868 * cos( g ) - 0.032077 * sin( g ) - 0.014615 * cos( 2 * g ) - 0.040849 * sin( 2 * g ) )
  decl = 0.006918 - 0.399912 * cos( g ) + 0.070257 * sin( g ) - 0.006758 * cos( 2 * g ) + 0.000907 * sin( 2 * g ) - 0.002697 * cos( 3 * g ) + 0.00148 * sin( 3 * g )
  zen = 90.833 * rad
  c_ha = ( cos( zen ) - sin( lat * rad ) * sin( decl ) ) / ( cos( lat * rad ) * cos( decl ) )
  if ( c_ha > 1 ) { print 0, 0; exit }
  if ( c_ha < -1 ) { print 0, 1440; exit }
  ha_deg = atan2( sqrt( 1 - c_ha * c_ha ), c_ha ) * deg
  noon_utc = 720 - 4 * lon - eq
  sr = noon_utc - ha_deg * 4 + 60 * tz
  ss = noon_utc + ha_deg * 4 + 60 * tz
  # 兼容 Busybox awk 的浮点数归一化算法
  sr_min = sr - 1440 * int( sr / 1440 )
  if ( sr_min < 0 ) sr_min += 1440
  ss_min = ss - 1440 * int( ss / 1440 )
  if ( ss_min < 0 ) ss_min += 1440
  print int( sr_min ), int( ss_min )
}')
EOF

# 控制背光
if [ "${current_minutes}" -ge "${sunrise_minutes}" ] && [ "${current_minutes}" -lt "${sunset_minutes}" ]; then
  brightness="0"
else
  brightness="160"
fi

sudo sh -c "echo ${brightness} > /sys/class/leds/lcd-backlight/brightness"
