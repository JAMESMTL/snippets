## HOW TO BUILD THE UNIFIED BCM 57711/57810 KERNEL MODULE FOR PROXMOX (6.x) VIA DKMS
Updated and tested 2020-09-03

What is Proxmox? see https://www.proxmox.com/en/proxmox-ve \
What is DKMS (Dynamic Kernel Module Support)? see https://help.ubuntu.com/community/DKMS 

For the Proxmox bnx2x kernel build instruction via standard Proxmox build environment see: https://github.com/JAMESMTL/snippets/blob/master/bnx2x/proxmox/README.md

<b>Note: I have literraly zero experience with Proxmox other than building the kernel module. I can't help anyone with any questions regarding configuration or running a proxmox host</b>

<b>This WILL be preformed on the production host.</b>

Step 1: If you are not using Proxmox with an enterprise subscription then you will need to remove the default enterprise repo and replace it with either the pve-no-subscription repo (recommended) or pvetest repo.

    rm /etc/apt/sources.list.d/pve-enterprise.list
    
then

    echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" > /etc/apt/sources.list.d/pve.list

or

    echo "deb http://download.proxmox.com/debian/pve buster pvetest" > /etc/apt/sources.list.d/pve.list

Step 2: Update apt sources

    apt update

Step 3: Install dkms + git + ethtool

    apt -y install dkms git ethtool

Step 4: Clone bnx2x sources

    cd /usr/src
    git clone https://github.com/JAMESMTL/bnx2x-dkms-linux-5.4.y bnx2x-99.1.713.36-0

Step 5: Get hernel headers, have dkms build the kernel module, and reboot the Proxmox server

    apt -y install pve-headers-$(uname -r)
    dkms install bnx2x/99.1.713.36-0 -k $(uname -r)
    reboot

Done!

### How to verify 2.5G link

Use ethtool to verify the wan interface (ex. ens224f0)

    ethtool ens224f0

### Warnings (read me twice)

DKMS will try and rebuild the kernel module whenever the kernel is updated and this will fail as the needed kernel headers will not be installed along with the new kernel image from the proxmox repo.

Proxmox's generic kernel headers for the pve-no-subscription and pvetest repos contain newer kernels than the stable entreprise subscription repo. This Will cause the module build to fail and proxmox will fall back to the distribution kernel module and link will be limited to 1G on the Huawei and Alcatel ONTs.

<b>The nokia ONT will not link up and will require that the headers are either present on the machine before upgrading the kernel, or loading the headers manually via USB thumb drive</b>

Hopefully these warnings will be temporary and a solution will be obtained from the proxmox community or devs.

### Updateting and recovery instructions for dkms kernel module

For the Huawei and Alcatel ONTs the procedure is fairly staright forward and is to literally step 5 from above.

    apt -y install pve-headers-$(uname -r)
    dkms install bnx2x/99.1.713.36-0 -k $(uname -r)
    reboot

For the Nokia ONT, one method you can use to recover connectivity is by installig the headers manually.

Step 1. Browse the repo using your computer by visiting here:\
http://download.proxmox.com/debian/pve/dists/buster/pve-no-subscription/binary-amd64/

Step 2. Download the pve-headers file that coresponds to your kernel. ex pve-headers-5.4.60-1-pve_5.4.60-1_amd64.deb for kernel version 5.4.60-1

Step 3. Copy that file to your root user home directory (/root or ~/)

Step 4. install the headers, dkms install for new kernel, and reboot

    dpkg -i ~/pve-headers-5.4.60-1-pve_5.4.60-1_amd64.deb
    dkms install bnx2x/99.1.713.36-0 -k $(uname -r)
    reboot

Alternatively you can install the needed headers prior to updating the kernel which will permit dkms to build the kernel module automatically. ex for kernel 5.4.60-1

    apt -y install pve-headers-5.4.60-1-pve

## Need Help?

Post your questions in the Bell Canada forum on dslreports found here: \
https://www.dslreports.com/forum/r32230041-Internet-Bypassing-the-HH3K-up-to-2-5Gbps-using-a-BCM57810S-NIC
