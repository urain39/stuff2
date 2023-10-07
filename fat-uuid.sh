# dd if=/dev/block/mmcblk1p1 bs=1 skip=67 count=4
printf '\x70\x38\x3e\x43' | dd of=/dev/block/mmcblk1p1 bs=1 seek=67
