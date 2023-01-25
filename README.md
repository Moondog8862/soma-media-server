# soma-media-server
small office media server appliance SOMA

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


