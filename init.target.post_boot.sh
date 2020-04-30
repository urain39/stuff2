#!/vendor/bin/sh
#
# Copyright (C) 2022 Paranoid Android
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Setup 2GB zRAM & 2GB Memory Extension
if [ ! -f /data/swapfile ]; then
    dd if=/dev/zero of=/data/swapfile bs=1048576 count=2048
    chmod 0600 /data/swapfile
fi
mknod -m 0600 /dev/block/loop0 b 7 0
losetup /dev/block/loop0 /data/swapfile
echo /dev/block/loop0 > /sys/block/zram0/backing_dev
echo 1048576 > /sys/block/zram0/writeback_limit
echo 1 > /sys/block/zram0/writeback_limit_enable
echo 2147483648 > /sys/block/zram0/disksize
# Kernel<=5.0 needs do this after setting disksize
echo all > /sys/block/zram0/idle
echo idle > /sys/block/zram0/writeback
echo 100 > /proc/sys/vm/swappiness
mkswap /dev/block/zram0
swapon /dev/block/zram0

# Enable SIGKILL memory reap
echo 1 > /proc/sys/vm/reap_mem_on_sigkill

# Zygote Preforking (override)
setprop persist.device_config.runtime_native.usap_pool_enabled true
