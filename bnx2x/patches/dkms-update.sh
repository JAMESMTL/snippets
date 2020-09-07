#!/bin/sh

# Sparse checkout of bnx2x kernel module source from kernel.org
git -C /usr/src/linux/ reset --hard
git -C /usr/src/linux/ pull
git -C /usr/src/linux/ checkout linux-$(uname -r | cut -d'.' -f1-2).y

# Apply upnatom's patch to bnx2x kernel module source
curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/bnx2x_warpcore_8727_2_5g_sgmii_txfault.patch | patch -p1 -d/usr/src/linux

# Get bnx2x version and create bnx2x dkms directory
BNX2XVER=$(grep DRV_MODULE_VERSION /usr/src/linux/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h | sed 's/.*\"\(.*\)\"/\1/')
BNX2XDKMSDIR=/usr/src/bnx2x-99.${BNX2XVER}
[ ! -d "$BNX2XDKMSDIR" ] && mkdir $BNX2XDKMSDIR || rm ${BNX2XDKMSDIR}/*

# Copy bnx2x kernel module source to dkms directory
cp /usr/src/linux/drivers/net/ethernet/broadcom/bnx2x/* $BNX2XDKMSDIR
cp /usr/src/linux/drivers/net/ethernet/broadcom/cnic_if.h $BNX2XDKMSDIR

# Apply dkms patch to bnx2x kernel module source and prepend 99. to bnx2x kernel module version
curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/dkms.patch | patch -p1 -d${BNX2XDKMSDIR}
sed -i "s/\($BNX2XVER\)/99.\1/" ${BNX2XDKMSDIR}/bnx2x.h
sed -i "s/\(99.9.999.99-9\)/99.${BNX2XVER}/" ${BNX2XDKMSDIR}/dkms.conf

# build and install dkms module
dkms remove bnx2x/99.${BNX2XVER} --all
dkms install bnx2x/99.${BNX2XVER} -k $(uname -r)