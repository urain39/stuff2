### 配置项说明

```sh
# vDIR 规则列表。每行一个规则，每个规则由目录和同步时长组成，
# 中间以制表符（tab）分隔。同步时长是 cron 扫描时长的倍数，
# 默认情况下 cron 扫描时长是一小时一次。当目录不存在时，那么
# 这条规则将会被忽略。
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
# 最后两项是指定内存压缩算法，是以任意空白符分隔的字符数组。从
# 左往右，当有一项设置成功时，那么它就是最终的压缩算法。当所有
# 项都失败时，那么 zRAM 将使用默认压缩算法。
ZRAM_OVER_SIZE="150"
ZRAM_CONST_SIZE="10"
ZRAM_VDIR_ALGS="lzo-rle	zstd"
ZRAM_SWAP_ALGS="lzo-rle	lzo"
```
