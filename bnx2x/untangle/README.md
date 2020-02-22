HOW TO BUILD THE BCM KERNEL MODULE FOR UNTANGLE NG FIREWALL

What is untangle? see https://www.untangle.com/

<b>Note: I don't use untangle and can't provide much assistance beyond the scope of this post.
The sole objective of this post is to build the kernel with a working module.</b>

To build the kernel module for untangle you will have to build the full kernel. The process is not overly complicated but it does take time (~30-45 mins)

These build instructions are based on the following wiki article https://wiki.untangle.com/index.php/Building_the_Code

<b>I recommend doing the build on a build VM or dedicated build machine and copy the .deb packages over over to your production machine</b> I used a 48GB VM for the build.

Step 1: Create the build machine. I installed untangle using the iso found here: https://www.untangle.com/get-untangle/

Step 2: Run the setup wizard to set nics (disable automatic updates)

Step 3: Enable ssh under CONFIG - NETWORK - ADVANCED - ACCESS RULES 

Step 4: login via ssh

Step 5: stop untangle service

`/etc/init.d./untangle-vm stop`

Step 6: identify the target kernel version and untangle distribution

[code]
uname -a
[/code]

ex: Linux untangle.example.com 4.9.0-11-untangle-amd64 #1 SMP Debian 4.9.189-3+untangle3 (2020-01-28) x86_64 GNU/Linux

4.9.x means it's debian stretch based
4.19.x should mean its debian buster based

You will need to get the repo commit number that matches your target build

goto https://github.com/untangle/ngfw_kernels

click on the branch button and select the tag and search for the target distribution (ex 15.0.0 = 15.0.0-20200218T23-sync) 


Step 7: Add debian stretch repo and the needed dependencies

[code]
echo "deb http://ftp.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list.d/build.list
echo "deb http://security.debian.org stretch/updates main contrib non-free" >> /etc/apt/sources.list.d/build.list
apt update
dpkg-reconfigure debconf
[/code]

Select dialog. i use critical

[code]
apt -y install linux-headers-$(uname -r)
apt -y install untangle-development-build firmware-bnx2x build-essential libncurses5-dev bison flex bc curl
git clone https://github.com/untangle/ngfw_kernels
[/code]

answer n to _git substitution

Step 8: Checkout the proper version from git

[code]
cd ngfw_kernels
checkout 15.0.0-20200218T23-sync
[/code]

step 9. Download and apply [user=upnatom]'s unified patch for 57810 + 57711 nic families then build the module

[code]
cd ~/ngfw_kernels/debian-4.9.0
make patch
make deps
cd linux-4.9.189
patch -p0 < ~/bnx2x_warpcore_2_5g_sgmii.patch drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
cd ..
make pkgs
[/code]

don't worry about any warnings during the doc build as we wont be using them anyways

get the path of the new kernel module

[code]
find ~ -name bnx2x.ko
[/code]

your looking for the file from the linux image directory

/root/ngfw_kernels/debian-4.9.0/linux-4.9.189/debian/linux-image-4.9.0-11-untangle-amd64/lib/modules/4.9.0-11-untangle-amd64/kernel/drivers/net/ethernet/broadcom/bnx2x/bnx2x.ko

This is the file you will copy to your production machine

I copied them to ~/latest on the working install

ssh into the working router and install the kernel packages

[code]
dpkg -i ~/latest/*.deb
reboot
[/code]

select the new kernel
Done!

<b>Note: IGMPPROXY is not available in the standard install nor does untangle's GUI firewall handle proto 2 (igmp)</b>

HOW-TO SETUP IPTV

step 1: create your secondary wan interafce on vlan 36, select dhcp, DO NOT select use peer dns

step 2: connect via ssh

[code]
curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/debian.list -o /etc/apt/sources.list.d/debian.list
apt update
apt install igmpproxy
rm /etc/apt/sources.list.d/debian.list
apt update
curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/igmpproxy.conf -o /etc/igmpproxy.conf
curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/dhclient-exit-hooks -o /etc/dhcp/dhclient-exit-hooks
curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/rc.local -o /etc/rc.local
chmod 755 /etc/rc.local
reboot
[/code]

step 3: Add to CONFIG - NETWORK - ADVANCED - DNS&DHCP

[code]
conf-file=/opt/dnsmasq.iptv
[/code]

Done.

to test DNS forward zones + routing to 10.2/16

[code]
dig discovery.iptv.microsoft.com
[/code]

Answer should be along the lines of 10.2.76.132

<img src="https://i.imgur.com/ehbrxyh.png">

<img src="https://i.imgur.com/Hgct553.png">

If you do something in the GUI that overwrites the scripted route or firewall rules just reboot

you cab browse the iptv files here https://github.com/JAMESMTL/snippets/tree/master/bnx2x/untangle


---
curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/bnx2x_warpcore+8727_2_5g_sgmii.patch | patch -p0
