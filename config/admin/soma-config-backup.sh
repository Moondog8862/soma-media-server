#!/bin/sh
##########################################################################
# SOMA Installer - Small Office Media Appliance
# Feedback and support please directly on github on the project site
# https://github.com/Moondog8862/soma-media-server
# Thanks, Adrian a.schmid@pm.me
##########################################################################
CP=/bin/cp
MKDIR=/bin/mkdir

DATE=$(/bin/date +%Y-%m-%d-week%w)

# soma-script-and-backup-folder
SOMA_BASE=/var/lib/soma

# Backup configs
cd $SOMA_BASE/config

# Print current routing table as systeminfo
printf %s\\n "$(route -n | column -t -s "|" )"  > system-setup/$DATE-routing-table.txt

$CP /etc/hostapd/hostapd.conf hostapd/
$CP /etc/netplan/01-netcfg.yaml netplan/
$CP /etc/dnsmasq.conf dnsmasq/
$CP /etc/ufw/before.rules ufw/
$CP /etc/ufw/user.rules ufw/
$CP /etc/ufw/sysctl.conf ufw/
$CP /etc/default/ufw ufw/
$CP /etc/samba/smb.conf smb/ 
$CP /etc/init.d/tvheadend/ tvheadend/
$CP /etc/exports nfs/
$CP $SOMA_BASE/somastart ./
$CP /etc/sysctl.conf ./
$CP /etc/udev/rules.d/90-dvb-adapter.rules ./

# ONLY BACKUP
$MKDIR $SOMA_BASE/config/backup-only
cd $SOMA_BASE/config/backup-only
$CP /etc/ssh/sshd_config ./
$CP /etc/resolv.conf ./
$CP /etc/hosts ./
$CP /etc/rc.local ./
$CP /etc/iptables/rules.v4 ./
rsync -rvpog /etc/modprobe.d ./
# cp /etc/default/lxc default/
