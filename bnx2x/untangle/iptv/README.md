## HOW-TO SETUP BELL IPTV USING UNTANGLE

<b>Note: IGMPPROXY is not available in the standard untangle install nor does untangle's GUI firewall handle proto 2 (igmp)</b>

<b>step 1:</b> create your secondary wan interafce on vlan 36, select dhcp, DO NOT select use peer dns

![](https://i.imgur.com/Hgct553.png)

![](https://i.imgur.com/ehbrxyh.png)

<b>step 2:</b> connect via ssh

<b>step 3:</b> Add the appropriate debian repo

For debian stretch use

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/debian-stretch-repo.list -o /etc/apt/sources.list.d/debian.list
	
For debian buster use

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/debian-buster-repo.list -o /etc/apt/sources.list.d/debian.list

Install igmpproxy and remove the repo when done

    apt update
    apt install igmpproxy
    rm /etc/apt/sources.list.d/debian.list
    apt update

<b>step 4:</b> Download config files needed for IPTV

    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/iptv/igmpproxy.conf -o /etc/igmpproxy.conf
    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/iptv/dhclient-exit-hooks -o /etc/dhcp/dhclient-exit-hooks
    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/iptv/rc.local -o /etc/rc.local
    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/iptv/iptv-fw-watchdog -o /etc/cron.d/iptv-fw-watchdog
    curl https://raw.githubusercontent.com/JAMESMTL/snippets/master/bnx2x/untangle/iptv/iptv-fw-rules.sh -o /opt/iptv-fw-rules.sh
    chmod 755 /etc/rc.local

<b>step 5:</b> Update interface names to match your setup

By default the downstream lan interface is eth1. To change the interface to eth3

    sed -i 's/eth1/eth3/g' /etc/igmpproxy.conf

By default the upstream wan iptv interface is eth0.36. To change the interface name to eth2.36

    sed -i 's/eth0\.36/eth2\.36/g' {/etc/igmpproxy.conf,/etc/dhcp/dhclient-exit-hooks,/etc/rc.local,/opt/iptv-fw-rules.sh}

<b>step 6:</b> Reboot the untangle host

<b>step 7:</b> Add to CONFIG - NETWORK - ADVANCED - DNS&DHCP

    conf-file=/opt/dnsmasq.iptv

Done.

To test DNS forward zones + routing to 10.2/16

     dig discovery.iptv.microsoft.com

Answer should be along the lines of 10.2.76.132

If you do something in the GUI that overwrites the scripted route or firewall rules just reboot

you can browse the iptv files here https://github.com/JAMESMTL/snippets/tree/master/bnx2x/untangle/iptv

Post any questions you have to the dslreports.com BCM57810 thread found here:
https://www.dslreports.com/forum/r32230041-Internet-Bypassing-the-HH3K-up-to-2-5Gbps-using-a-BCM57810S-NIC
