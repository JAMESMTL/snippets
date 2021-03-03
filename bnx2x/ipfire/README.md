## HOW TO BUILD THE UNIFIED BCM57810 & BCM57711/2 KERNEL MODULE FOR IPFIRE (v2.x)
Full IPFire installation media (.iso) built from source \
Built using Debian Buster release debian-10.8.0-amd64-netinst \
Updated: 2021-03-02

What is IPFire see https://www.ipfire.org/

<b>Note: I have literally zero experience with IPFire other than building the kernel module. I can't help anyone with any questions regarding configuration or running an IPFire router</b>

The sole objective of this post is to build the installation media (.iso).

<b>Step 1:</b> Create a Debian Buster build environment on a VM or separate build machine. I used 32GB VM for the build (~10 mins)

I installed Debian using this source (net install): https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.8.0-amd64-netinst.iso

I suggest doing the install via regular text console and not via GUI (don't select graphical install).
Only enable ssh server and standard system utilities when selecting components.
why? because that will leave you in a known state.

<b>Step 2:</b> Enable root ssh access either by logging into console or ssh into the machine using the user account you created and then run the following as su

    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    /usr/sbin/service sshd restart

<b>Step 3:</b> log out then log back in as root via ssh

<b>Step 4:</b> The first thing that needs to be done is to modify /etc/apt/sources.list by running

    sed -i 's/buster main/buster main non-free/g' /etc/apt/sources.list

<b>Step 5:</b> Once you have updated apt sources list run the following to install the needed packages

    apt update
    apt install firmware-bnx2x build-essential libncurses5-dev bison flex bc curl libelf-dev libssl-dev git gcc g++ make patch bzip2 byacc python-urlgrabber gawk texinfo manpages-pl autoconf automake

<b>Step 6:</b> Clone the IPFire development repository and switch to our working directory

    git clone git://git.ipfire.org/ipfire-2.x.git
    cd ipfire-2.x

<b>Step 7:</b> Checkout a specific development branch (Optional, skip to use the master branch)

By default cloning the repository will checkout the master branch which holds the currently shipped code (see IPFire sources wiki)

You can browse the IPFire repo here: https://git.ipfire.org/?p=ipfire-2.x.git

To checkout the master branch, a named branch such as v2.25-core153, or a specific commit such as c6e032e13d5d1eff16189c50229f00522835aae5 use one of the following:

    git checkout master
    git checkout v2.25-core153
    git checkout c6e032e13d5d1eff16189c50229f00522835aae5

<b>Step 8:</b> Download upnatom's unified patch and patch the lfs/linux build script to include the bnx2x patch

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/bnx2x_warpcore_8727_2_5g_sgmii_txfault.patch -o ~/ipfire-2.x/src/patches/linux/bnx2x_warpcore_8727_2_5g_sgmii_txfault.patch
    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/ipfire/lfs-build.patch | patch -Np1

<b>Step 9:</b> Download the IPFire source (~10 Mins)

    ./make.sh downloadsrc

<b>Step 10:</b> Download the toolchain

    ./make.sh gettoolchain

<b>Step 11:</b> Build IPFire installation media (.iso) from source (~4 hours)

    ./make.sh build

your installation media can be found here:
~/ipfire-2.x/ipfire-2.25.x86_64-full-core153.iso

### Alternative install method

<b>Starting with IPFire 2.25 - Core Update 142 the IPFire devs enabled kernel module signing making it no loger posible to install unsigned modules.</b>

### References

These instructions are based on the following wiki articles: \
IPFire Wiki Sources: https://wiki.ipfire.org/devel/sources \
IPFire Wiki Build how-to: https://wiki.ipfire.org/devel/ipfire-2-x/build-howto

* Note: IPFire was in the process of a server migration when I did the original build and their wiki was offline so you may notice a few additional packages

You can view the bnx2x patch here: https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/bnx2x_warpcore_8727_2_5g_sgmii_txfault.patch \
You can view the lfs/linux patch here: https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/ipfire/lfs-build.patch
