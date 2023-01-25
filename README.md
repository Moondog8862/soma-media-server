# soma-media-server
small office media server appliance SOMA

****************************
NEEDS TO BE FINISHED FOR FIRST RELEASE!!!
in install script. replace these values with sed and ask vor values from user:

dnsmasq.conf
change values for:
interface=enp3s0,wlp4s0,lxcbr0
except-interface=enp0s20u4u1
no-dhcp-interface=enp0s20u4u1,lo
dhcp-option=wlp4s0,3,10.0.0.1
dhcp-option=enp3s0,3,10.0.50.1
dhcp-option=lxcbr0,3,10.220.50.1

UFW
before.rules
#Forward traffic from the alias range 10.0.0.xxx through enp0s20u4u3
-A POSTROUTING -s 10.0.0.0/24 -o enp0s20u1 -j MASQUERADE
-A POSTROUTING -s 10.0.50.0/24 -o enp0s20u1 -j MASQUERADE
-A POSTROUTING -s 10.220.50.0/24 -o enp0s20u1 -j MASQUERADE

smb.conf
change all occurences of USER variable with current user

checkdvb.sh
#/sbin/start-stop-daemon -o --start \
#  -u "USER" -g "USER" --chuid "USER:USER" -b --exec "$DAEMON"

****************************

Installs and configures a tv-tuner, mediaserver and file server with 2 networks (10.0.0.0/24 and 10.0.50.0/24)
After setup, Kodi can be used on any device in the network to stream live-tv, movies and pictures from the central tvheadend server.


Requirements

OS (lsb_release -a)

Distributor ID:	elementary
Description:	elementary OS 5.1.7 Hera
Release:	5.1.7
Codename:	hera

means: Ubuntu bionic based (18.04)

TV-Tuner (lsusb .v)

Bus 003 Device 006: ID 2040:8268 Hauppauge 
  iManufacturer           3 HCW
  iProduct                1 soloHD

Caution

Please be careful to install on a configured system as it will overwrite existing IP addresses and networks with the new configuration.

Installation

git clone https://github.com/Moondog8862/soma-media-server

cd soma-media-server

chmod +x soma-install.sh

./soma-install.sh

-----------------------------------------------------

Adding other usb devices for sound system (eg. Philips Audio Set)

If you need to enable a sound system, you can enable the usb connection if it does not automatically open the usb ports with the script in the udev folder. Please note: You need to be able to compile c files so install a gcc compiler for your system to create the executable.

apt-get install libusb-dev gcc

Compile:
gcc -Wall usb_pc_link.c -o usb_pc_link -lusb

To activate the device when a connection is being monitored (check with udevadm monitor) place the script:
cp /etc/udev/rules.d/991-usb-philips.rules


