#!/bin/bash
echo "====================Installing Base Linux System======================"
FS_NAME=netkit-fs-min
MOUNT_DIR=/mnt/nkfs2
FILESYSTEM_SIZE=1024
# each cylinder has 63 sectors, each of which is 512 bytes
let CYL_COUNT=$FILESYSTEM_SIZE*1048576/32256

# Create empty netkit-fs file
dd if=/dev/zero of=$FS_NAME bs=1M count=0 seek=$FILESYSTEM_SIZE

# Create image partition
echo ",,L,*" | sfdisk -q -H 1 -S 63 -C $CYL_COUNT $FS_NAME

# Binding lookback device to netkit-fs
device_name=$(losetup -f)
# The offset is the size of one track
losetup --offset 512 $device_name $FS_NAME

# Create ext2 filesystem
mkfs.ext2 $device_name
losetup -d $device_name

# Mount netkit-fs
rm -rf $MOUNT_DIR
mkdir $MOUNT_DIR
mount -o loop,offset=512 -t ext2 $FS_NAME $MOUNT_DIR

# Install the base filesystem  from Internet
debootstrap --arch i386 squeeze $MOUNT_DIR http://ftp.cn.debian.org/debian
echo "=================Base Linux System Installed Success=================="


umount $MOUNT_DIR
echo "done!"