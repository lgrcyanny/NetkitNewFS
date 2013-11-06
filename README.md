NetkitNewFS
===========

Create a custom Netkit filesystem from scratch, and based on netkit-uml-filesystem
The filesystem of Netkit is very large, more than 10GB, so this project is to minmize and optimize the Netkit filesystem. Make the filesystem as small as possible.

How to Build Netket-fs
===============
1. install netkit and config the environment appropriately. Test it with vstart
2. <code>sudo ./netkit-fs-buld.sh</code>
3. after buld test the fs with <code>sudo ./test.sh</code>

File Structures
=========
netkit-tweaks/etc    contains neccessary files for netkit
netkit-tweaks/sbin   contains neccessary files for netkit
for more details about how to make the netkit-fs, please refer to comments on *netkit-fs-build.sh*