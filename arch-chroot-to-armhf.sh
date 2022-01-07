#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script requires root, run it again with sudo" 
   exit 1
fi

LOOPDEV=$(losetup -P -f --show ${1})

mkdir -p /mnt/rpi-image/

# mount partition
mount -o rw ${LOOPDEV}p2  /mnt/rpi-image
mount -o rw ${LOOPDEV}p1 /mnt/rpi-image/boot

# We need to comment out the copies and fills preload
# because we may be running on a machine/emulator that doesn't
# supoort the specical instructions that are used
sed -i 's/^/#QEMU /g' /mnt/rpi-image/etc/ld.so.preload

# copy qemu binary
cp /usr/bin/qemu-arm-static /mnt/rpi-image/usr/bin/

# arch-chroot to rpi-image
# mount binds of {dev, sys etc.} are done behind the scenes with arch-chroot
arch-chroot /mnt/rpi-image /bin/bash

# -------------------------- ON EXIT ---------------------------- #
# Clean up
# revert ld.so.preload fix
sed -i 's/^#QEMU //g' /mnt/rpi-image/etc/ld.so.preload

# unmount everything
umount -lf /mnt/rpi-image
