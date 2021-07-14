## HOW TO BUILD THE UNIFIED BCM 57711/57810 KERNEL MODULE FOR PROXMOX (5.4, 6.x,7.x)
Updated 2021-07-13 (v7 untested)

For the proxmox bnx2x kernel module build instruction using DKMS see : https://github.com/JAMESMTL/snippets/blob/master/bnx2x/proxmox/README-dkms.md 

<b>Note: I have literraly zero experience with Proxmox other than building the kernel module. I can't help anyone with any questions regarding configuration or running a proxmox host</b>

<b>DO NOT perform the build on a production host.</b> Create a build VM. I recommend creating a build VM with 48GB disk space.

The sole objective of this post is to build the module, I have only added enough dependencies to get that far and there may be a couple that are not actually needed but that wont affect the build.

<b>Step 1.</b> Before going any further you need to identify the kernel of the target VM host. You can do this by logging in via ssh and running

    root@pve:~# uname -a

This will give you a result such as :

    Linux pve 5.11.22-1-pve #1 SMP PVE 5.11.22-2 (Fri, 02 Jul 2021 16:22:45 +0200) x86_64 GNU/Linux

Once you have that information you can proceed to create your build environment

<b>Step 2.</b> Install proxmox as a VM guest. I used the Proxmox VE (5.4, 6.x, 7.x) ISO Installers located here https://www.proxmox.com/en/downloads/category/iso-images-pve

Do not bother doing any setup on the new proxmox VM as everything will be done via ssh

<b>Step 3.</b> log into the new VM via ssh

<b>Step 4.</b> Double check that the kernel of your build VM matches the target kernel

    root@pve:~# uname -a

<b>Step 5.</b> Get the Debian release used to build Proxmox

    DEBIANVER=$(awk '{print $3}' /etc/apt/sources.list.d/pve-enterprise.list) && echo $DEBIANVER

<b>Step 6.</b> Download the Debian sources file that matches your release and save it to /etc/apt/sources.list

    wget https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/proxmox/sources.list_${DEBIANVER} -O /etc/apt/sources.list

then delete /etc/apt/sources.list.d/pve-enterprise.list

    rm /etc/apt/sources.list.d/pve-enterprise.list


and update the apt sources

    apt update


<b>DO NOT do an apt upgrade or apt dist-upgrade, doing so will download updated kernels</b>

<b>Step 7.</b> Now install the packages you will need to build the module

    apt install git build-essential fakeroot libncurses5-dev xz-utils libssl-dev bc flex libelf-dev bison curl dpkg-dev debhelper asciidoc libiberty-dev lintian xmlto libdw-dev libnuma-dev libslang2-dev zlib1g-dev


<b>Step 8.</b> Install the headers file corresponding to your target

You will need to get a link for the headers that match the target build.

you can construct the filename you need based on the version learned from the target

ex: pve-headers-4.15.18-12-pve_4.15.18-35_amd64.deb\
ex: pve-headers-5.0.15-1-pve_5.0.15-1_amd64.deb\
ex: pve-headers-5.4.34-1-pve_5.4.34-2_amd64.deb (Note -1 vs -2)\
ex: pve-headers-5.11.22-1-pve_5.11.22-2_amd64.deb (Note -1 vs -2)

Alternatively you can browse proxmox's Buster repo directly in your browser here :\
http://download.proxmox.com/debian/pve/dists/buster/pve-no-subscription/binary-amd64/ \

or proxmox's Bullseye repo here: \
http://download.proxmox.com/debian/pve/dists/bullseye/pve-no-subscription/binary-amd64/

Example for kernel release 5.11.22-1-pve / kernel version 5.11.22-2

    wget http://download.proxmox.com/debian/pve/dists/${DEBIANVER}/pve-no-subscription/binary-amd64/pve-headers-5.11.22-1-pve_5.11.22-2_amd64.deb
    dpkg -i pve-headers-5.11.22-1-pve_5.11.22-2_amd64.deb

<b>Step 9.</b> You will also need to get the repo commit number that matches your target build

goto https://git.proxmox.com/?p=pve-kernel.git and search for the target kernel (ex 4.15.18-35, 5.0.15-1, 5.4.34-2, or 5.11.22)

You may see more than one commit.

For v5.4 you would want the update ABI file for 4.15.18-12-pve (bump version to 4.15.18-35)\
For v6.0 you would want update ABI file for 5.0.15-1-pve (update ABI file for 5.0.15-1-pve)\
For v6.2 you would want bump version to 5.4.34-2 (bump version to 5.4.34-2)\
For v7.0 you would want update ABI file for 5.11.22-2-pve

Once you click on the version you want you will be able to get the commit number ex:

v5.4 (4.15.18-35) 2b3306dee456c6b172a8fdbbce2598f67d0b2569\
v6.0 (5.0.15-1) de6fe5c8ffa1ffd870bc128b39864d1e49e27de1\
v6.2 (5.4.34-2) 80c08de2e4909e4411cf0db3aa37c5532db0c693\
v7.0 (5.11.22-2) 1686139dd18594b19ee588578965d033826db57d

<b>Step 10.</b> Get the source code

    git clone git://git.proxmox.com/git/pve-kernel.git
    cd pve-kernel

and checkout the version that matches your target

v5.4 (4.15.18-35)

    git checkout 2b3306dee456c6b172a8fdbbce2598f67d0b2569

v6.0 (5.0.15-1)

    git checkout de6fe5c8ffa1ffd870bc128b39864d1e49e27de1

v6.2 (5.4.34-2)

    git checkout 80c08de2e4909e4411cf0db3aa37c5532db0c693
    
v7.0 (5.11.22-2)

    git checkout 1686139dd18594b19ee588578965d033826db57d

And make the submodules needed to build the kernel module (this takes time)

    make

The make process will error out but that's ok as we have gone as far as we need to.

<b>Step 11.</b> Switch to the kernel build directory

v5.4 (4.15.18-35)

    cd ~/pve-kernel/build/ubuntu-bionic

v6.0 (5.0.15-1)

    cd ~/pve-kernel/build/ubuntu-disco

v6.2 (5.4.34-2)

    cd ~/pve-kernel/build/ubuntu-focal
    
v7.0 (5.11.22-2)

    cd ~/pve-kernel/build/ubuntu-hirsute

<b>Step 12.</b> Download and apply upnatom's unified patch for 57810 + 57711 nic families then build the module

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/bnx2x_warpcore_8727_2_5g_sgmii_txfault.patch | patch -p1
    cp /usr/src/linux-headers-$(uname -r)/.config .
    cp /usr/src/linux-headers-$(uname -r)/Module.symvers .
    make modules_prepare
    make M=drivers/net/ethernet/broadcom/bnx2x
    strip --strip-debug drivers/net/ethernet/broadcom/bnx2x/bnx2x.ko
    cp drivers/net/ethernet/broadcom/bnx2x/bnx2x.ko ~/

a copy of your modified kernel module can be found root user's home directory\
~/bnx2x.ko

on your production host you need to copy that file to:\
/lib/modules/$(uname -r)/kernel/drivers/net/ethernet/broadcom/bnx2x/

BEFORE copying the module backup the original just in case

then run

    update-initramfs -u -k all
    reboot

Done!

### How to verify if the bnx2x kernel module has been patched

    modinfo -p bnx2x | grep -q mask_tx_fault && echo PATCHED || echo NOT PATCHED