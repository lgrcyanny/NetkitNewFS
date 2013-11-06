#!/bin/bash
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

# Configure the filesystem for netkit
# Copy necessary files to netkit-fs
NETKIT_TWEAKS_DIR=netkit-tweaks
cp -Rvf $NETKIT_TWEAKS_DIR/etc $MOUNT_DIR/
cp -Rvf $NETKIT_TWEAKS_DIR/sbin $MOUNT_DIR/

# Handle the perl locale warning, so that update-rc.d can pass
# I really doubt wheather the warning has influence?
chroot $MOUNT_DIR apt-get install locales
chroot $MOUNT_DIR export LANGUAGE=en_US.UTF-8
chroot $MOUNT_DIR export LANG=en_US.UTF-8
chroot $MOUNT_DIR export LC_ALL=en_US.UTF-8,
chroot $MOUNT_DIR export LC_PAPER=en_US.UTF-8
chroot $MOUNT_DIR export LC_ADDRESS=en_US.UTF-8
chroot $MOUNT_DIR export LC_MONETARY=en_US.UTF-8
chroot $MOUNT_DIR export LC_NUMERIC=en_US.UTF-8
chroot $MOUNT_DIR export LC_TELEPHONE=en_US.UTF-8
chroot $MOUNT_DIR export LC_IDENTIFICATION=en_US.UTF-8
chroot $MOUNT_DIR export LC_MEASUREMENT=en_US.UTF-8
chroot $MOUNT_DIR export LC_TIME=en_US.UTF-8
chroot $MOUNT_DIR export LC_NAME=en_US.UTF-8
chroot $MOUNT_DIR dpkg-reconfigure locales # it will popup a GUI, chose "en_US.UTF-8" with space key and press ok button
chroot $MOUNT_DIR  locale-gen en_US.UTF-8


# Install necessary packages
chroot $MOUNT_DIR apt-get update
chroot $MOUNT_DIR apt-get install less
chroot $MOUNT_DIR apt-get install vim
chroot $MOUNT_DIR apt-get install chkconfig


# link netkit-phase1 and netkit-phase2 to rcX.d for runlevel prority
chroot $MOUNT_DIR insserv netkit-phase1 
chroot $MOUNT_DIR chkconfig netkit-phase1 on
chroot $MOUNT_DIR insserv netkit-phase2 
chroot $MOUNT_DIR chkconfig netkit-phase2 on 

# enable quagga
chroot $MOUNT_DIR apt-get install quagga
chroot $MOUNT_DIR apt-get install busybox
chroot $MOUNT_DIR apt-get install telnet

# disable unuseful service to make boot faster
chroot $MOUNT_DIR update-rc.d cron remove
chroot $MOUNT_DIR update-rc.d quagga remove

# exit root 
exit
umount $MOUNT_DIR
echo "done!"