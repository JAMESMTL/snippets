## HOW TO BUILD THE BCM KERNEL MODULE FOR UNTANGLE NG FIREWALL (v15.0.x, v15.1.x)

What is untangle? see https://www.untangle.com/

<b>Note: I don't use untangle and can't provide much assistance beyond the scope of this post.</b>  
<b>The sole objective of this post is to build the kernel with a working module.</b>

To build the kernel module for untangle you will have to build the full kernel. The process is not overly complicated but it does take time (~30-45 mins). These build instructions are based on the following wiki article https://wiki.untangle.com/index.php/Building_the_Code

<b>I recommend doing the build on a build VM or dedicated build machine and copy the kernel module over to your production machine</b>

Step 1: Create the build machine.  I used a 48GB VM for the build and I installed untangle using the iso found here: https://wiki.untangle.com/index.php/NG_Firewall_Downloads

Step 2: Run the setup wizard to set nics (disable automatic updates)

Step 3: Enable ssh under CONFIG - NETWORK - ADVANCED - ACCESS RULES

Step 4: Identify the untangle distribution

From the untangle UI goto CONFIG - ABOUT

![](https://i.imgur.com/R249Yge.png)

Here we see that we are running build 15.0.0 with a datestamp of 20200214T135223

Step 5: Login via ssh

Step 6: Identify the target kernel version

    uname -a

example: Linux untangle.example.com 4.9.0-11-untangle-amd64 #1 SMP Debian 4.9.189-3+untangle3 (2020-01-28) x86_64 GNU/Linux
example: Linux untangle.example.com 4.19.0-8-untangle-amd64 #1 SMP Debian 4.19.98-1+untangle3buster (2020-05-08) x86_64 GNU/Linux

4.9.x means it's debian stretch based  
4.19.x should mean its debian buster based

4.9.<b>189-3</b> 189-3 is the kernel revision (this is important and is what you are looking to match)

Step 7: Stop untangle service

For debian stretch use

    /etc/init.d/untangle-vm stop

Step 8: Get the most appropriate repo commit number for your target build

Goto https://github.com/untangle/ngfw_kernels

Click on the branch button and select the tag tab and search for the target distribution that matches the above build or that follows it (ex 15.0.0 = 15.0.0-20200218T23-sync, 15.1.0 = 15.1.0-20200623T0956-sync).

If you now click on the appropraite kernel branch ex. debian-4.9.0 for debian stretch and debian-4.19.0 for debian buster. you should now see your target kernel

![](https://i.imgur.com/cadTXeM.png)

Step 9: Add the appropriate debian repo

For debian stretch use

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/debian-stretch-repo.list -o /etc/apt/sources.list.d/debian.list
	
For debian buster use

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/debian-buster-repo.list -o /etc/apt/sources.list.d/debian.list

Then update the repo and reconfigure debconf

    apt update
    dpkg-reconfigure debconf

Select dialog. i use critical

    apt -y install linux-headers-$(uname -r)
    apt -y install untangle-development-build firmware-bnx2x build-essential libncurses5-dev bison flex bc curl libelf-dev
    git clone https://github.com/untangle/ngfw_kernels

answer n to _git substitution

Step 10: Checkout the proper version from git

    cd ~/ngfw_kernels
    checkout 15.0.0-20200218T23-sync

Step 11: Change directories to the appropriate kernel

For debian stretch use

    cd ~/ngfw_kernels/debian-4.9.0

For debian buster use

    cd ~/ngfw_kernels/debian-4.19.0

step 12: Download the actual kernel source

    make patch
    make deps
	
Change to the linux build directory

    cd linux-4.9.189

Apply upnatom's unified patch for 57810 + 57711 nic families then build the module

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/bnx2x_warpcore_8727_2_5g_sgmii_txfault.patch | patch -p1
    cd ..
    make pkgs

don't worry about any warnings during the doc build as we wont be using them anyways

Step 10: Get the path of the new kernel module

    find ~ -name bnx2x.ko

You are looking for the file from the linux image directory

ex: /root/ngfw_kernels/debian-4.9.0/linux-4.9.189/debian/linux-image-4.9.0-11-untangle-amd64/lib/modules/4.9.0-11-untangle-amd64/kernel/drivers/net/ethernet/broadcom/bnx2x/bnx2x.ko \
ex: /root/ngfw_kernels/debian-4.19.0/linux-4.19.98/debian/linux-image-4.19.0-8-untangle-amd64-unsigned/lib/modules/4.19.0-8-untangle-amd64/kernel/drivers/net/ethernet/broadcom/bnx2x/bnx2x.ko

This is the file you will copy to your production machine. I copied the module to ~/latest

ssh into the working router and install the kernel packages

    cp ~/latest/bnx2x.ko /lib/modules/$(uname -r)/kernel/drivers/net/ethernet/broadcom/bnx2x/
    update-initramfs -u -k all
    reboot

Done!

### How to verify if the bnx2x kernel module has been patched

    modinfo -p bnx2x | grep -q mask_tx_fault && echo PATCHED || echo NOT PATCHED

## Acknowledgements. Need Help?

These instructions are in support of the work done by upnatom to enable 2.5G link speeds needed for GPON SFP ONTs used by providers such Bell Canada for their FTTH services.

Post your questions in the Bell Canada forum on dslreports found here: \
https://www.dslreports.com/forum/r32230041-Internet-Bypassing-the-HH3K-up-to-2-5Gbps-using-a-BCM57810S-NIC


## HOW-TO setup Bell IPTV using untangle

See https://github.com/JAMESMTL/snippets/blob/master/bnx2x/untangle/iptv/README.md
