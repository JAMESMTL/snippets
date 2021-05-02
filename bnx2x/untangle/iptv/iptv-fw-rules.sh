#!/bin/sh

/sbin/iptables -L INPUT | /bin/sed -n '3p' | /bin/grep -q igmp || /sbin/iptables -I INPUT -p igmp -j ACCEPT
/sbin/iptables -L FORWARD | /bin/sed -n '3p' | /bin/grep -Eq '10\.2\.0\.0/16 *239\.0\.0\.0/8' || /sbin/iptables -I FORWARD -i eth0.36 -s 10.2.0.0/16 -d 239.0.0.0/8 -p udp -j ACCEPT
