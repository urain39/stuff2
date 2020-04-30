### 基本依赖

1. sh/ash/bash/dash/mksh（必选）
2. grep（必选）
3. awk（必选）
4. openrc/systemd（必选）
5. crontab（必选）
6. rsync（可选；默认配置必选）


### 安装说明

注意：使用前请务必先阅读完下方的配置小节。

```sh
# 安装本体
sudo install -Dm 0755 leg.sh /usr/local/bin/leg

# 初始化配置
sudo leg init
```


### 配置项说明

配置文件是`/etc/leg.conf`。

```sh
# vDIR 规则列表。每行一个规则，每个规则由目录和同步间隔组成，
# 中间以制表符（tab）分隔。同步间隔是 cron 扫描间隔的倍数，
# 0 表示不同步；默认情况下 cron 扫描间隔是一小时一次。当目录
# 不存在时，那么这条规则将会被忽略。
VDIR_ENTRY_LIST="
/tmp	0
/root	8
/home	8
/var/log	24
/var/cache	24
/var/lib/rpimonitor	24
"

# vDIR 同步方法。这里可以指定 vDIR 所使用的同步软件和参数选项。
# 默认情况下 vDIR 使用 rsync 作为同步方法，参数一般不需要修改。
VDIR_SYNC_EXEC="rsync"
VDIR_SYNC_ARGS="-auxy --inplace --no-whole-file --delete-after --"

# vDIR 交换内存。该参数决定 vDIR 和 Swap 的内存分配大小。数值
# 是物理内存的百分比，最高不建议超过100。vDIR 的总大小计算公式是
# 由下面的 ZRAM_OVER_SIZE 减去这里的 VDIR_SWAP_SIZE。
VDIR_SWAP_SIZE="100"

# zRAM 内存压缩。这里的数值用于设置内存压缩参数。其中第一项是
# 指定实际可用内存的大小，即 zRAM 里的 disksize。数值是实际
# 内存的百分比。紧跟在后的是指定保留内存大小，即这部分内存是绝
# 不会被 zRAM 使用的。这个参数是可以减少因内存不足的死机概率。
# 最后两项是指定内存压缩算法，是以制表符 tab 分隔的字符数组。
# 从左往右，当有一项设置成功时，那么它就是最终的压缩算法。当所
# 有项都失败时，那么 zRAM 将使用默认压缩算法。
ZRAM_OVER_SIZE="150"
ZRAM_CONST_SIZE="10"
ZRAM_VDIR_ALGS="lzo-rle	zstd"
ZRAM_SWAP_ALGS="lzo-rle	lzo"
```

注意1：修改配置文件在重启后才生效。  
注意2：安装前请确保 home 目录下的总大小不超过 RAM 的一半。  
注意3：请将大文件储存在 /static 目录下。  
注意4：本脚本会与 log2ram 冲突。  
注意5：本脚本中需要保证脚本名本身以及 vDIR 都不包含引号（安全原因）。


### 卸载说明

```sh
# 卸载本体
sudo rm /usr/local/bin/leg

# 移除配置
sudo rm /etc/leg.conf

# 移除 crontab 配置
    crontab - << EOT
$(crontab -l 2> /dev/null | sed '/^# leg-patch-begin@/,/^# leg-patch-end@/d')
EOT

# 移除 systemd 配置
sudo rm -f /etc/systemd/system/leg.service

# 移除 openrc 配置
sudo rm -f /etc/init.d/leg
```
