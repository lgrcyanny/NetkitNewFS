#!/bin/bash

echo "=======================Configuring Netkit=============================="
echo "=====Warning: Please run these following code manually and carefully====="

#Copy necessary files to netkit-fs
FS_NAME=netkit-fs-min
NETKIT_TWEAKS_DIR=netkit-tweaks
MOUNT_DIR=/mnt/nkfs2
mount -o loop,offset=512 -t ext2 $FS_NAME $MOUNT_DIR

# /etc/sysctl.conf is important, since it configure ip forwarding net.ipv4.ip_forward=1, 
# or virtual machines can't ping successfully
cp -Rvf $NETKIT_TWEAKS_DIR/etc $MOUNT_DIR/
cp -Rvf $NETKIT_TWEAKS_DIR/sbin $MOUNT_DIR/

# change root dir
chroot $MOUNT_DIR

# Handle the mtab error
# The  proc filesystem is a pseudo-filesystem which provides an interface
# to kernel data structures.  It is commonly mounted at /proc.   Most  of
# it is read-only, but some files allow kernel variables to be changed.
mount -t proc none /proc

# Handle the perl locale warning, so that update-rc.d can pass
# I really doubt wheather the warning has influence?
apt-get install locales
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
dpkg-reconfigure locales # it will popup a GUI, chose "en_US.UTF-8" with space key and press ok button
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8 LC_MEASUREMENT=en_US.UTF-8


# Install necessary packages
apt-get install less
apt-get install vim
apt-get install chkconfig


# link netkit-phase1 and netkit-phase2 to rcX.d for runlevel prority
insserv netkit-phase1 
chkconfig netkit-phase1 on
insserv netkit-phase2 
chkconfig netkit-phase2 on 
# disable cron on boot
update-rc.d cron remove

# exit and umount
exit
umount $MOUNT_DIR/proc
umount $MOUNT_DIR
# When can't umount, $MOUNT_DIR busy
fuser -m $MOUNT_DIR
# if out put is
# /dev/sdc1: 538 
ps -aux | grep 538
# kill the process, and then umount can success

#=====================================================================
echo "========================== Configuring quagga==================="
echo "=====Warning: Please carefully and Manually run these following code inside the netkit vitual machine====="

# install necessary packages
apt-get install busybox
apt-get install telnet
apt-get install telnetd
apt-get install tcpd
apt-get install tcpdump
apt-get install tcpreen
apt-get install tcpreplay
apt-get install tcpslice
apt-get install tcptraceroute
apt-get install arping
apt-get install arptables

# install quagga
apt-cache policy quagga
apt-get install quagga -v 0.99.20.1

# exit root 
exit
umount $MOUNT_DIR/proc
umount $MOUNT_DIR

