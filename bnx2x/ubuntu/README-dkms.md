## HOW TO BUILD THE BCM KERNEL MODULE FOR UBUNTU VIA DKMS

Where to download Ubuntu? see https://ubuntu.com/download/server \
What is DKMS (Dynamic Kernel Module Support)? see https://help.ubuntu.com/community/DKMS

<b>This WILL be preformed on the production host</b>

Step 1: Install Ubuntu

Step 2: Login to Ubuntu via SSH or console

Step 3: Enable root user (optional otherwise skip to step 6)

```
sudo passwd root
sudo passwd -u root
```

Step 4: Enable root SSH access
```
su
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
/usr/sbin/service sshd restart
```

Step 5: Login to Ubuntu as root via SSH or console

If you choose to setup dkms under root then leave out the sudo from the instructions below

Step 6: Update & upgrade Ubuntu
```
sudo apt update
sudo apt upgrade
```

Step 7: Install dkms, git, ettool, and dependencies
```
sudo apt install -y dkms git ethtool curl
```

Step 8: Run dkms init script (https://github.com/JAMESMTL/snippets/blob/master/bnx2x/patches/dkms-init.sh)
```
curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/dkms-init.sh | sudo sh | tee /usr/src/dkms-init.log
```

Step 9: Verify that the kernel module was patched correctly
```
modinfo -p bnx2x | grep -q mask_tx_fault && echo PATCHED || echo NOT PATCHED
```

Step 10. Reboot 
```
reboot
```

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

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/dkms-update.sh | sudo sh | tee /usr/src/dkms-init.log

This should only be required if there has been a major update to the underlying kernel branch.

## Acknowledgements. Need Help?

These instructions are in support of the work done by upnatom to enable 2.5G link speeds needed for GPON SFP ONTs used by providers such Bell Canada for their FTTH services.

Special thanks zinc/severnt for the original dkms instructions based on the 4.19 kernel found here: https://github.com/severnt/bnx2x-2_5g-dkms 

Post your questions on the CPE bypass discord server or the Bell Canada forum on dslreports found here: \
https://discord.gg/NM6MwN7D \
https://www.dslreports.com/forum/r32230041-Internet-Bypassing-the-HH3K-up-to-2-5Gbps-using-a-BCM57810S-NIC


