#!/bin/sh -l

# 替换为镜像源
sed -i 's/dl-cdn.alpinelinux.org/mirrors.bfsu.edu.cn/g' /etc/apk/repositories

# 添加 testing 源
sed -i '$p;$s/v\d\{1,\}\.\d\{1,\}\/.\{1,\}$/edge\/testing/' /etc/apk/repositories

# 修改 DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf


# 安装最新版 qBittorrent
apk --update --no-cache add \
	qbittorrent-nox
