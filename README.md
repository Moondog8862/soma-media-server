# soma-media-server
small office media server appliance SOMA

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

Please be careful to install on a configured system as it will overwrite existing IP addresses and networks with the configuration.

Installation

git clone https://github.com/Moondog8862/soma-media-server

cd soma-media-server

chmod +x soma-install.sh

./soma-install.sh

