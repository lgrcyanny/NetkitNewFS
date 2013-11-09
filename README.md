NetkitNewFS
===========

Create a custom Netkit filesystem from scratch, and based on netkit-uml-filesystem. <br>
The filesystem of Netkit is very large, more than 10GB, so this project is to minmize and optimize the Netkit filesystem. Make the filesystem as small as possible.<br>
**Now I have successfully buld a netkit-fs with only 330M, comparing to to original netkit 10GB, it's smaller. And it's the smalles version so far. The netkit-fs has passed rip, ospf single area, ospf multi area and simple bgp test.**
Let's see how to build it.<br>

How to Build Netket-fs
===============
1. <code>git clone 	https://github.com/lgrcyanny/NetkitNewFS.git</code>

2. Install netkit based on official guides on netkit(http://wiki.netkit.org/index.php/Main_Page)<BR>
(1)First, download netkit and compress these files:<BR>
<code>tar xjSf netkit-x.y.tar.bz2<BR>
tar xjSf netkit-filesystem-Fx.y.tar.bz2<BR>
tar xjSf netkit-kernel-Kx.y.tar.bz2</code><BR>
(2)And then <code>vim ~/.bashrc</code>, append these to the file:<BR>
<code>
export NETKIT_HOME=/home/lgrcyanny/netkit/netkit<BR>
export MANPATH=:$NETKIT_HOME/man:$MANPATH<BR>
export PATH=$NETKIT_HOME/bin:$PATH<BR>
. $NETKIT_HOME/bin/netkit_bash_completion # this is optional
</code><BR>
execute .bashrc<BR>
<code>source ~/.bashrc</code><BR>
(3)open netkit directory, execute **check_configuration.sh**<BR>
<code>./check_configuration.sh</code>


3. Install the base linux file system
run the shell with root access.
<code>sudo ./netkit-fs-buld.sh</code>

4. After, the base file system built successfully. Let's Configure it for netkit.
Open *configure-netkit.sh* file, please exectue the linux command in the shell file based on the comments.<BR>
Please execute these commands **manually** and **carefully**, Up to now, automatic method bring me a lot of problem, so manually way can be more effective. 

5. After build successfully, you can test the netkit-fs 
You can pull the test lab. 
<code>git clone https://github.com/lgrcyanny/NetkitLabs.git </code>
Please modiy the **netkit.conf** in the netkit installed directory.<BR>
configure as follows:
<code>VM_MODEL_FS="/home/lgrcyanny/netkit/newfs/netkit-fs"</code>
so that <code>lstart</code> can start now

File Structures
========
- netkit-tweaks<BR>
---- etc<BR>
---------init.d   #contains netkit-phase1 and netkit-phase2, the two important file for netkit bootstrap<BR>
---------network  #interfaces confgure<br>
---------inittab  # inittab file for bootstrap runlevel<br>
---------resolv.conf # DNS parse<br>
---------sysctl.conf # net.ipv4.ip_forward=1 for ip forwarding, important configure, enable ip packet forwarding<br>
-----sbin<br>
---------mingetty # mingetty is a minimal getty program for watching virtual termianl<br>

Trouble Shooting
=======
I have spent five days on the file system minimize, encountered some seriouse problems, which my partners encountered as well.
1. The virtual machine disappear fast on bootstrap
-------------------------
Firstly, Please check wheather the linux base system installed valid.<BR>
Secondly, Use insserv and chkconfig to configure netkit-phase1 and netkit-phase2

2. Quagga install error
----------
I have tried to compile and make quagga manually, but unsuccessfully. I also tried mount the netkit-fs, and install quagga on my host, lstart can still unsuccessfully.
Finally, I install quagga inside the netkit virtual machine with connection to Internet.
<code>apt-get install quagga -v 0.99.20.1</code>, If the version too high, will be imcompatible with the netkit kernel.

3. ip forwarding problem
--------
When I lstart a lab, the routers can lean routes from other machines, but can't be pinged.
I digged into the problem, and find the solution, by defaut, ip forwarding is diabled, just open it.
I copy the *sysctl.conf* from the original netkit-fs, configure the ip forwarding with <code>net.ipv4.ip_forward=1</code>