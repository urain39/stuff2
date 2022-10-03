#!/bin/sh

# 启用防火墙
ufw enable

# 默认允许本机访问外网
ufw default allow outgoing

# 默认拒绝外网访问本机
ufw default deny incoming

# 允许内网 192.168.1.0/24 段访问本机
ufw allow from 192.168.1.0/24

# 禁用日志功能（部分环境限制）
ufw logging off
