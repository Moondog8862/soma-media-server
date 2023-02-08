#!/bin/sh
##########################################################################
# SOMA Installer - Small Office Media Appliance
# Feedback and support please directly on github on the project site
# https://github.com/Moondog8862/soma-media-server
# Thanks, Adrian a.schmid@pm.me
##########################################################################
CP=/bin/cp
MKDIR=/bin/mkdir

# Creating soma-script-and-backup-folder
SOMA_BASE=/var/lib/soma
# rm -rf $SOMA_BASE
$MKDIR -p $SOMA_BASE/backup
$MKDIR -p $SOMA_BASE/admin
$MKDIR /opt/dnsmasq

# Installer Logfile
LOG=$SOMA_BASE/soma-install.log

# Install needed packages for networking
apt install net-tools

RELEASE=$(lsb_release -sr)
case $RELEASE in
 22.04)
   apt install -y netplan.io kodi-pvr-hts
   ;;
 18.04)
  apt install -y netplan kodi-pvr-tvheadend-hts
  ;;
esac
apt install -y hostapd ufw samba
apt install -y nfs-kernel-server nfs-common
# Install Kodi as frontend
apt install -y kodi
echo "Installing tvheadend from snap store..."
apt install -y snap snapd
snap install tvheadend

# Interactive Installer
echo "Starting interactive installer. Here we will configure the base values for your system"
echo "Primary Network Interface: Please enter the name of your interface for 4K TV streaming (ethernet or fastwifi/wifi6 network. Choose from available interfaces list.)"
#ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d'
ip -o link show | awk -F ':' '{print $1 $2}'
read int1
cat << EOF
Wireless Network Interface: Enter the name of your secondary interface used for small file transfer (Fileserver)
and office internet (not voip/streaming/large file transfer).
If you are not sure based on the output above it is usually the one mentioned in the following output (IEEE).
EOF
iwconfig
read int2
echo "Gateway Network Interface: Enter the name of the interface facing the internet, usually located on the line with the ip address in the router column."
route -n
read int3
# Get ip accress from gateway interface
int3gw=$(route -n | grep $int3 | grep UG | awk '{print $2}')

# Install configs
cd ./config
echo "Please enter a name for your WiFi"
read wifiname
echo "Please enter a password for your WiFi"
read wifipass
# need to change the following with a sed replacement
# interface= interface= ssid=
$CP hostapd/* /etc/hostapd/
$CP netplan/01-netcfg.yaml netplan/01-netcfg.tmp
sed -i 's/int4k/'$int1'/g' netplan/01-netcfg.tmp
sed -i 's/intwifi/'$int2'/g' netplan/01-netcfg.tmp
sed -i 's/intgw/'$int3gw'/g' netplan/01-netcfg.tmp
$CP netplan/01-netcfg.tmp /etc/netplan/01-netcfg.yaml
$CP dnsmasq/dnsmasq.conf dnsmasq/dnsmasq.tmp
sed -i 's/int4k/'$int1'/g' dnsmasq/dnsmasq.tmp
sed -i 's/intwlan/'$int2'/g' dnsmasq/dnsmasq.tmp
sed -i 's/intgw/'$int3'/g' dnsmasq/dnsmasq.tmp
ipdns=$(route -n | grep 'UG[ \t]' | awk '{print $2}')
sed -i 's/ipdns/'$ipdns'/g' dnsmasq/dnsmasq.tmp
$CP dnsmasq/dnsmasq.tmp /etc/dnsmasq.conf
$CP ufw/before.rules ufw/before.tmp
sed -i 's/intgw/'$int3'/g' ufw/before.tmp
$CP ufw/before.tmp /etc/ufw/before.rules
$CP ufw/user.rules /etc/ufw/
$CP ufw/sysctl.conf /etc/ufw/
$CP ufw/ufw /etc/default/
CUSER=$(id -u -n)
$CP smb/smb.conf smb/smb.tmp
sed -i 's/USER/'$CUSER'/g' smb/smb.tmp
$CP smb/smb.tmp /etc/samba/
$CP nfs/exports /etc/
exportfs -ra
$CP sysctl.conf /etc/
sysctl -p

echo "Now Installing TVHeadend server..."
TVUSER=hts
TVGROUP=video
/usr/sbin/useradd -m $TVUSER
/usr/sbin/groupadd $TVGROUP
$CP tvheadend/tvheadend /etc/init.d/ 
$CP 90-dvb-adapter.rules /etc/udev/rules.d/
$CP somastart $SOMA_BASE
ln -s $SOMA_BASE/somastart /usr/bin/somastart
chmod +x $SOMA_BASE/somastart
$CP admin/soma-config-backup.sh $SOMA_BASE/admin/
chmod +x $SOMA_BASE/admin/soma-config-backup.sh
$CP admin/checkdvb.sh admin/checkdvb.tmp
sed -i 's/USER/'$TVUSER'/g' admin/checkdvb.tmp
sed -i 's/GROUP/'$TVGROUP'/g' admin/checkdvb.tmp
$CP admin/checkdvb.tmp $SOMA_BASE/admin/checkdvb.sh
chmod +x $SOMA_BASE/admin/checkdvb.sh

echo "" > $LOG
echo "Initializing SOMA-Installer Logfile in install directory." | tee $LOG
echo "Install soma weekly backup job, check if crontab file is not patched" | tee $LOG
if [ ! -f "/etc/cron.weekly/tv-config-backup.sh" ]; then
  echo "Creating crontab file for weekly TV-Backup" >> $LOG
  $CP cron/tv-config-backup.sh /etc/cron.weekly/
fi

echo "Install soma startup job, check if crontab file is not patched" | tee $LOG
CRONTAB=/var/spool/cron/crontabs/root
if [ ! -f "$CRONTAB" ]; then
  touch $CRONTAB
fi
if [ $(grep -c "somastart" $CRONTAB) -eq 0 ]; then
  echo "Patching crontab file for startup job" >> $LOG
  echo "# Start soma server \n@reboot /usr/bin/somastart" >> $CRONTAB
fi
if [ ! -d "/etc/rc5.d/S90somastart" ]; then
  ln -s /usr/bin/somastart /etc/rc0.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc1.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc2.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc3.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc4.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc5.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc6.d/S90somastart
fi

echo "Install samba default user, check if userfile is not patched" | tee $LOG
#if [ $(cat /etc/hosts | grep 10.10.0.1) == "" ]; then
#  echo " " >> /etc/samba/smbpasswd
#fi

echo "Install dns entries, check if hosts file is not patched" | tee $LOG
if [ $(grep -c "10.10.0.1" /etc/hosts) -eq 0 ]; then
  echo "Patching hosts file for dns entry of networks" >> $LOG
  echo "# Subnet addresses" >> /etc/hosts
  echo "10.10.0.1        access.wifi.lan" >> /etc/hosts
  echo "10.10.50.1       access.fiber.lan" >> /etc/hosts
fi

# Restarting system services
service smbd restart
# service tvheadend restart
# service dnsmasq restart
# service hostapd restart

netplan generate; netplan apply
ufw enable; ufw reload

# User Info
echo "Done installing SOMA server. Please access the tvheadend Webfrontend at one of the following locations:" http://127.0.0.1:9981" | tee $LOG
echo "From local machine: http://127.0.0.1:9981\n http://access.fiber.lan:9981" | tee $LOG
echo "From network: http://10.10.50.1:9981" | tee $LOG
echo "Notice for configuring tvheadend:" | tee $LOG
echo "Configuration options for installer:\n -- Allowed network: 10.10.50.0/24" | tee $LOG
echo "Access the fileshares with the server ip 10.10.50.1 with a client from within this network or from the wireless network 10.10.0.1" | tee $LOG
echo "Change passwords for default users. user Login: admin / admin" | tee $LOG

