## HOW TO BUILD THE UNIFIED BCM 57711/57810 KERNEL MODULE FOR PROXMOX (6.x,7.x, 8.x) VIA DKMS
Updated 2023-09-05

What is Proxmox? see https://www.proxmox.com/en/proxmox-ve \
What is DKMS (Dynamic Kernel Module Support)? see https://help.ubuntu.com/community/DKMS 

For the Proxmox bnx2x kernel module build instruction via standard Proxmox build environment see: https://github.com/JAMESMTL/snippets/blob/master/bnx2x/proxmox/README.md

<b>Note: I have literraly zero experience with Proxmox other than building the kernel module. I can't help anyone with any questions regarding configuration or running a proxmox host</b>

<b>This WILL be preformed on the production host.</b>

<b>Step 1.</b> Get the Debian release used to build Proxmox

    DEBIANVER=$(awk '{print $3}' /etc/apt/sources.list.d/pve-enterprise.list) && echo $DEBIANVER

<b>Step 2.</b> If you are not using Proxmox with an enterprise subscription then you will need to remove the default enterprise repo and replace it with either the pve-no-subscription repo (recommended) or pvetest repo.

    rm /etc/apt/sources.list.d/pve-enterprise.list
    
then

    echo "deb http://download.proxmox.com/debian/pve ${DEBIANVER} pve-no-subscription" > /etc/apt/sources.list.d/pve.list

or

    echo "deb http://download.proxmox.com/debian/pve ${DEBIANVER} pvetest" > /etc/apt/sources.list.d/pve.list

<b>Step 3.</b> Update apt sources

    apt update

<b>Step 4.</b> Install dkms, git, ettool, and dependencies

    apt install -y dkms git ethtool pve-headers pve-headers-$(uname -r)

<b>Step 5.</b> Run dkms init script (https://github.com/JAMESMTL/snippets/blob/master/bnx2x/patches/dkms-init.sh)

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/dkms-init.sh | sh | tee /usr/src/dkms-init.log

<b>Step 6.</b> Verify bnx2x module has been patched then Reboot 

	modinfo -p bnx2x | grep -q mask_tx_fault && echo PATCHED || echo NOT PATCHED
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

### How to verify if the bnx2x kernel module has been patched

    modinfo -p bnx2x | grep -q mask_tx_fault && echo PATCHED || echo NOT PATCHED

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

If you have any questiopns or need support please visit the CPE Bypass discord server found here: \
https://discord.com/servers/8311-886329492438671420
