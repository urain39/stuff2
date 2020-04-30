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
    -net "user,\
hostfwd=tcp::20021-:21,\
hostfwd=tcp::20022-:22,\
hostfwd=tcp::20080-:80,\
hostfwd=tcp::20139-:139,\
hostfwd=tcp::20443-:443,\
hostfwd=tcp::20445-:445,\
hostfwd=tcp::26800-:6800,\
hostfwd=tcp::28080-:8080,\
hostfwd=tcp::28384-:8384,\
hostfwd=tcp::28999-:8999,\
hostfwd=tcp::29532-:9532"
