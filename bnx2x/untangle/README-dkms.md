## HOW TO BUILD THE BCM KERNEL MODULE FOR UNTANGLE NG FIREWALL (v15.0.x, v15.1.x, v16.x) VIA DKMS

What is untangle? see https://www.untangle.com/ \
What is DKMS (Dynamic Kernel Module Support)? see https://help.ubuntu.com/community/DKMS

<b>Note: I don't use untangle and can't provide much assistance beyond the scope of this post.</b>  
<b>The sole objective of this post is to build the kernel with a working module.</b>  
<b>This WILL be preformed on the production host.</b>

Step 1: Install Untangle. I installed untangle using the iso found here: https://wiki.untangle.com/index.php/NG_Firewall_Downloads

Step 2: Configure Untangle

Step 3: Enable ssh under CONFIG - NETWORK - ADVANCED - ACCESS RULES

Step 4: Identify the kernel version

From the untangle UI goto CONFIG - ABOUT

![](https://i.imgur.com/R249Yge.png)

4.9.x means it's debian stretch based  
4.19.x should mean its debian buster based

Step 5: Login via ssh

Step 6: Add the appropriate debian repo

For debian stretch use

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/debian-stretch-repo.list -o /etc/apt/sources.list.d/debian.list
	
For debian buster use

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/debian-buster-repo.list -o /etc/apt/sources.list.d/debian.list

Step 7. Update apt sources

    apt update

Step 8. Install dkms, git, ettool, and dependencies

    apt install -y dkms git ethtool

Step 9. Remove debian repo & update apt sources

    rm  /etc/apt/sources.list.d/debian.list
    apt update

Step 10. Run dkms init script (https://github.com/JAMESMTL/snippets/blob/master/bnx2x/patches/dkms-init.sh)

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/dkms-init.sh | sh | tee /usr/src/dkms-init.log

Step 11. Verify bnx2x module version is prepended with 99 (ex. 99.1.713.36-0) then Reboot 

    modinfo bnx2x
    reboot

Done!

### Optional kernel module parameters

To set these parameters, create a file in /etc/modprobe.d and include the required options

To enable debug mode

    options bnx2x debug=0x4102034

To disable SFP TX fault detection

    options bnx2x mask_tx_fault=1

where :\
0 = SFP TX fault detection enabled on both ports (default)\
1 = SFP TX fault detection disabled on port 0\
2 = SFP TX fault detection disabled on port 1\
3 = SFP TX fault detection disabled on both ports

After adding, modifying, or removing kernel module options update the initramfs image by running the following as root

    update-initramfs -u -k all

### How to verify 2.5G link

Use ethtool to verify the wan interface (ex. ens224f0)

    ethtool ens224f0

### Warnings (read me twice)

DKMS will try and rebuild the kernel module whenever the kernel is updated. If for some reason you are missing the proper headers the build will fail and the system will fall back to the distribution kernel module and the link will be limited to 1G on the Huawei and Alcatel ONTs.

<b>If this happens and you have the nokia ONT, you will lose connectivity and you will required to install the headers manually either via a secondary network adapter or via USB thumb drive</b>

### Reinstalling / updating bnx2x dkms kernel module sources

Run dkms update script (https://github.com/JAMESMTL/snippets/blob/master/bnx2x/patches/dkms-update.sh)

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/dkms-update.sh | sh | tee /usr/src/dkms-init.log

This should only be required if there has been a major update to the underlying kernel branch.

## Acknowledgements. Need Help?

These instructions are in support of the work done by upnatom to enable 2.5G link speeds needed for GPON SFP ONTs used by providers such Bell Canada for their FTTH services.

Special thanks zinc/severnt for the original dkms instructions based on the 4.19 kernel found here: https://github.com/severnt/bnx2x-2_5g-dkms 

Post your questions in the Bell Canada forum on dslreports found here: \
https://www.dslreports.com/forum/r32230041-Internet-Bypassing-the-HH3K-up-to-2-5Gbps-using-a-BCM57810S-NIC

## HOW-TO setup Bell IPTV using untangle

See https://github.com/JAMESMTL/snippets/blob/master/bnx2x/untangle/iptv/README.md
