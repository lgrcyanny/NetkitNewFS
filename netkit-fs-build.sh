#!/bin/bash
FS_NAME=netkit-fs
MOUNT_DIR=/mnt/nkfs2
FILESYSTEM_SIZE=512
let CYL_COUNT=$FILESYSTEM_SIZE*1048576/32256
# Create empty netkit-fs file
dd if=/dev/zero of=netkit-fs bs=1M count=0 seek=$FILESYSTEM_SIZE

# Binding lookback device to netkit-fs
device_name=$(losetup -f)
losetup $device_name $FS_NAME

# Create image partition
echo ",,L," | sfdisk -q -H 1 -S 63 -C $CYL_COUNT $device_name
losetup -d $device_name

# mv the image to netkit-fs
# The offset is the size of one track
losetup -offset 512 $device_name $FS_NAME

# Create ext2 filesystem
mkfs.ext2 $device_name
losetup -d $device_name

# Mount netkit-fs
mount -o loop,offset=512 -t ext2 $FS_NAME $MOUNT_DIR
# Install the basic filesystem with connection to the Internet
debootstrap --arch i386 wheezy $MOUNT_DIR http://ftp.cn.debian.org/debian

umount /mnt/umfs
echo "done!"