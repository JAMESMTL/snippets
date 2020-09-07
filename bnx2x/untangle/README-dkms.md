## HOW TO BUILD THE BCM KERNEL MODULE FOR UNTANGLE NG FIREWALL (v15.0.x, v15.1.x) VIA DKMS

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

Step 9. Run dkms init script (https://github.com/JAMESMTL/snippets/blob/master/bnx2x/patches/init-dkms.sh)

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/init-dkms.sh | sh | tee /usr/src/init-dkms.log

Step 10. Verify bnx2x module version is prepended with 99 (ex. 99.1.713.36-0) then Reboot 

    modinfo bnx2x
    reboot

Done!

### Optional kernel module parameters

To set these parameters, create a file in /etc/modprobe.d and include the required options

To enable debug mode

    modprobe bnx2x debug=0x4102034

To disable SFP TX fault detection

    options bnx2x mask_tx_fault=1

where :\
0 = SFP TX fault detection enabled on both ports (default)\
1 = SFP TX fault detection disabled on port 0\
2 = SFP TX fault detection disabled on port 1\
3 = SFP TX fault detection disabled on both ports

### How to verify 2.5G link

Use ethtool to verify the wan interface (ex. ens224f0)

    ethtool ens224f0

### Warnings (read me twice)

DKMS will try and rebuild the kernel module whenever the kernel is updated. If for some reason you are missing the proper headers the build will fail and the system will fall back to the distribution kernel module and the link will be limited to 1G on the Huawei and Alcatel ONTs.

<b>If this happens and you have the nokia ONT, you will lose connectivity and you will required to install the headers manually either via a secondary network adapter or via USB thumb drive</b>

### Updateting and recovery instructions for dkms kernel module

For the Huawei and Alcatel ONTs the procedure is fairly staright forward.

    apt install -y linux-headers-$(uname -r)
    dkms install bnx2x/99.1.712.30-0 -k $(uname -r)
    reboot

For the Nokia ONT, one method you can use to recover connectivity is by installig the headers manually.

Step 1. Browse the repo using your computer by visiting here:\
http://updates.untangle.com/public/buster/pool/main/l/linux/

Step 2. Download the linux-header files that coresponds to your kernel.  
ex linux-headers-4.19.0-8-untangle-amd64_4.19.98-1+untangle3buster_amd64.deb &  
ex linux-headers-4.19.0-8-common-untangle_4.19.98-1+untangle3buster_all.deb for kernel version 4.19.0-8

Step 3. Copy those files to your root user home directory (/root or ~/)

Step 4. install the headers, dkms install for new kernel, and reboot

    dpkg -i ~/linux-headers-4.19.0-8-untangle-amd64_4.19.98-1+untangle3buster_amd64.deb
    dpkg -i ~/linux-headers-4.19.0-8-common-untangle_4.19.98-1+untangle3buster_all.deb
    dkms install bnx2x/99.1.712.30-0 -k $(uname -r)
    reboot

## Acknowledgements. Need Help?

These instructions are in support of the work done by upnatom to enable 2.5G link speeds needed for GPON SFP ONTs used by providers such Bell Canada for their FTTH services.

Special thanks zinc/severnt for the original dkms instructions based on the 4.19 kernel found here: https://github.com/severnt/bnx2x-2_5g-dkms 

Post your questions in the Bell Canada forum on dslreports found here: \
https://www.dslreports.com/forum/r32230041-Internet-Bypassing-the-HH3K-up-to-2-5Gbps-using-a-BCM57810S-NIC

## HOW-TO SETUP IPTV

<b>Note: IGMPPROXY is not available in the standard install nor does untangle's GUI firewall handle proto 2 (igmp)</b>

step 1: create your secondary wan interafce on vlan 36, select dhcp, DO NOT select use peer dns

step 2: connect via ssh

Step 3: Add the appropriate debian repo

For debian stretch use

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/debian-stretch-repo.list -o /etc/apt/sources.list.d/debian.list
	
For debian buster use

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/debian-buster-repo.list -o /etc/apt/sources.list.d/debian.list

Update the repo

    apt update
    apt install igmpproxy
    rm /etc/apt/sources.list.d/debian.list
    apt update
    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/igmpproxy.conf -o /etc/igmpproxy.conf
    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/dhclient-exit-hooks -o /etc/dhcp/dhclient-exit-hooks
    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/rc.local -o /etc/rc.local
    chmod 755 /etc/rc.local
    reboot

step 4: Add to CONFIG - NETWORK - ADVANCED - DNS&DHCP

    conf-file=/opt/dnsmasq.iptv

Done.

To test DNS forward zones + routing to 10.2/16

     dig discovery.iptv.microsoft.com

Answer should be along the lines of 10.2.76.132

![](https://i.imgur.com/ehbrxyh.png)

![](https://i.imgur.com/Hgct553.png)

If you do something in the GUI that overwrites the scripted route or firewall rules just reboot

you can browse the iptv files here https://github.com/JAMESMTL/snippets/tree/master/bnx2x/untangle
