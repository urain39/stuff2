#!/bin/sh

# 常量定义：杭州经纬度
LAT="30.2741"; LON="120.1551"; TZ="8"

# 获取输入参数
if [ -n "${1}" ]; then
  DOY="${1}"
else
  DOY="$( date +%j | sed 's/^0//' )"
fi
[ -z "${DOY}" ] && DOY="0"

awk -v lat="${LAT}" -v lon="${LON}" -v tz="${TZ}" -v doy="${DOY}" '
BEGIN {
  pi = 4 * atan2( 1, 1 )
  rad = pi / 180.0
  deg = 180.0 / pi
  g = 2 * pi / 365.0 * ( doy - 1 )
  eq = 229.18 * ( 0.000075 + 0.001868 * cos( g ) - 0.032077 * sin( g ) - 0.014615 * cos( 2 * g ) - 0.040849 * sin( 2 * g ) )
  decl = 0.006918 - 0.399912 * cos( g ) + 0.070257 * sin( g ) - 0.006758 * cos( 2 * g ) + 0.000907 * sin( 2 * g ) - 0.002697 * cos( 3 * g ) + 0.00148 * sin( 3 * g )
  zen = 90.833 * rad
  c_ha = ( cos( zen ) - sin( lat * rad ) * sin( decl ) ) / ( cos( lat * rad ) * cos( decl ) )
  if ( c_ha > 1 ) { print "Polar Night"; exit }
  if ( c_ha < -1 ) { print "Polar Day"; exit }
  ha_deg = atan2( sqrt( 1 - c_ha * c_ha ), c_ha ) * deg
  noon_utc = 720 - 4 * lon - eq
  sr = noon_utc - ha_deg * 4 + 60 * tz
  ss = noon_utc + ha_deg * 4 + 60 * tz
  # 兼容 Busybox awk 的浮点数归一化算法
  sr_min = sr - 1440 * int( sr / 1440 )
  if ( sr_min < 0 ) sr_min += 1440
  ss_min = ss - 1440 * int( ss / 1440 )
  if ( ss_min < 0 ) ss_min += 1440
  # 取整并格式化输出
  v_sr = int( sr_min )
  v_ss = int( ss_min )
  printf "Sunrise: %02d:%02d\n", int( v_sr / 60 ), v_sr % 60
  printf "Sunset:  %02d:%02d\n", int( v_ss / 60 ), v_ss % 60
}'
