#!/bin/sh

# Get kernel version
case $(uname -r) in
	*"-untangle-amd64" )
		KERNVER=linux-$(uname -r | cut -d'.' -f1-2).y
		;;

	*"-pve")
		KERNVER=v$(uname -r | grep -oE '([0-9]+\.){2}[0-9]+' | sed 's/\.0$//' )
		;;

	*)
		KERNVER=v$(uname -a | grep -oE '([0-9]+\.){2}[0-9]+' | tail -n1 | sed 's/\.0$//' ) 
		;;
esac

# Sparse checkout of bnx2x kernel module source from kernel.org
rm -R /usr/src/linux 2>/dev/null
git init /usr/src/linux
git -C /usr/src/linux/ config core.sparseCheckout true
echo "drivers/net/ethernet/broadcom/" > /usr/src/linux/.git/info/sparse-checkout
git -C /usr/src/linux/ remote add origin git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
git -C /usr/src/linux/ fetch --depth=1 origin ${KERNVER}
git -C /usr/src/linux/ merge FETCH_HEAD

# Apply upnatom's patch to bnx2x kernel module source
curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/bnx2x_warpcore_8727_2_5g_sgmii_txfault.patch | patch -p1 -d/usr/src/linux

# Get bnx2x version and create bnx2x dkms directory
BNX2XVER=$(grep '^#define DRV_MODULE_VERSION' /usr/src/linux/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h | sed 's/.*\"\(.*\)\"/\1/')
BNX2XDKMSDIR=/usr/src/bnx2x-99.${BNX2XVER}
mkdir $BNX2XDKMSDIR

# Copy bnx2x kernel module source to dkms directory
cp /usr/src/linux/drivers/net/ethernet/broadcom/bnx2x/* $BNX2XDKMSDIR
cp /usr/src/linux/drivers/net/ethernet/broadcom/cnic_if.h $BNX2XDKMSDIR

# Apply dkms patch to bnx2x kernel module source and prepend 99. to bnx2x kernel module version
curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/patches/dkms.patch | patch -p1 -d${BNX2XDKMSDIR}
sed -i "s/\($BNX2XVER\)/99.\1/" ${BNX2XDKMSDIR}/bnx2x.h
sed -i "s/\(99.9.999.99-9\)/99.${BNX2XVER}/" ${BNX2XDKMSDIR}/dkms.conf

# build and install dkms module
dkms install bnx2x/99.${BNX2XVER} -k $(uname -r)
