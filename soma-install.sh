#!/bin/sh
#####################
# SOMA Installer
#####################
CP=/bin/cp

# Installer Logfile
LOG=soma-install.log

# Install needed packages for networking
apt install -y hostapd netplan ufw samba
apt install -y nfs-kernel-server nfs-common
# Install Kodi as frontend
apt install -y kodi kodi-pvr-tvheadend-hts kodi-pvr-hts
echo "Installing tvheadend from snap store..."
apt install -y snap snapd
snap install tvheadend

# Install configs
$CP hostapd/* /etc/hostapd/
$CP netplan/01-netcfg.yaml /etc/netplan/
$CP dnsmasq/dnsmasq.conf /etc/
$CP ufw/before.rules /etc/ufw/
$CP ufw/user.rules /etc/ufw/
$CP ufw/sysctl.conf /etc/ufw/
$CP ufw/ufw /etc/default/
$CP smb/smb.conf /etc/samba/ 
$CP tvheadend/tvheadend /etc/init.d/ 
$CP nfs/exports /etc/
exportfs -ra
$CP somastart /usr/bin
$CP sysctl.conf /etc/
$CP 90-dvb-adapter.rules /etc/udev/rules.d/

echo "Initializing SOMA-Installer Logfile in install directory." > $LOG

# Install crontab job for starting soma-server
echo "Install soma startup job? Yes to install, enter to skip"

# Install soma startup job, check if crontab file is not patched
if [ $(grep -c "somastart" /var/spool/cron/crontabs/root) -eq 0 ]; then
  echo "Patching crontab file for startup job" >> $LOG
  echo "# Start soma server \n@reboot /usr/bin/somastart" >> /var/spool/cron/crontabs/root
fi
if [ $(! -d "/etc/rc5.d/S90somastart") ]; then
  ln -s /usr/bin/somastart /etc/rc0.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc1.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc2.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc3.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc4.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc5.d/S90somastart
  ln -s /usr/bin/somastart /etc/rc6.d/S90somastart
fi
# Antique code
#cp rc.local /etc

# Install samba default user, check if userfile is not patched
#if [ $(cat /etc/hosts | grep 10.0.0.1) == "" ]; then
#  echo " " >> /etc/samba/smbpasswd
#fi

# Install dns entries, check if hosts file is not patched
if [ $(grep -c "10.0.0.1" /etc/hosts) -eq 0 ]; then
  echo "Patching hosts file for dns entry of networks" >> $LOG
  echo "# Subnet addresses" >> /etc/hosts
  echo "10.0.0.1        access.wifi.lan" >> /etc/hosts
  echo "10.0.50.1       access.fiber.lan" >> /etc/hosts
fi

# Restarting system services
service smbd restart
service tvheadend restart
service dnsmasq restart
service hostapd restart
netplan generate; netplan apply
ufw reload

# User Info
echo "Done installing SOMA server. Access the tvheadend Webfrontend at: https://127.0.0.1:9981"
echo "Done installing SOMA server. Access the tvheadend Webfrontend at: https://access.fiber.lan:9981"
echo "Change passwords for default users. user Login: admin / admin"
