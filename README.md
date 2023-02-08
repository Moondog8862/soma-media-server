# soma-media-server
small office media server appliance SOMA

****************************
Installs and configures a tv-tuner, mediaserver and file server with 2 networks (10.10.0.0/24 and 10.10.50.0/24)
After setup, Kodi can be used on any device in the network to stream live-tv, movies and pictures from the central tvheadend server.

Requirements

OS
Distributor ID:	elementary
Description:	elementary OS 5.1.7 Hera
Release:	5.1.7
Codename:	hera

Based on: Ubuntu bionic based (18.04)

Check your OS: lsb_release -a

TV-Tuner

Bus 003 Device 006: ID 2040:8268 Hauppauge 
  iManufacturer           3 HCW
  iProduct                1 soloHD

Check your tuner: lsusb -v

Caution
Please be careful to install on a configured system as it will overwrite existing IP addresses and networks with the new configuration.

Hardware requireements
4K capable graphics card with 2GPU and min 2GB RAM (I used an ASUS GeForce GT 1030 2G BRK with no problems
For my installation, I used a Intel(R) Core(TM) i5-4570S CPU @ 2.90GHz with 4 cores and 32GB RAM, other setup is certainly also possible, 
please report your experience.

Installation

git clone https://github.com/Moondog8862/soma-media-server

cd soma-media-server

chmod +x soma-install.sh

./soma-install.sh

-----------------------------------------------------

Adding other usb devices for sound system (eg. Philips Audio Set)

If you need to enable a sound system, you can activate the usb connection if it does not automatically open the usb ports with the script in the udev folder. Please note: You need to compile c files so install a gcc compiler for your system to create the executable.

apt-get install libusb-dev gcc

Compile:
gcc -Wall usb_pc_link.c -o usb_pc_link -lusb

To activate the device when a connection is being monitored (check with udevadm monitor) place the script in:
cp /etc/udev/rules.d/991-usb-philips.rules


