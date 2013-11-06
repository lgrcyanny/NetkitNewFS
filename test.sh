#!/bin/bash
FS_NAME=netkit-fs-min
vstart pc1 -m $FS_NAME -M 512 --eth0=tap,10.0.0.1,10.0.0.2 --append=rout:98:1 -W