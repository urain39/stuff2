#!/bin/sh

"qemu-system-$(uname -m)" \
    -nographic \
    -M virt,accel=kvm \
    -cpu host \
    -m 256M \
    -bios QEMU_EFI.FD \
    -hda DISK.QCOW2 \
    -cdrom CDROM.ISO \
    -net nic,model=virtio \
    -net tap
