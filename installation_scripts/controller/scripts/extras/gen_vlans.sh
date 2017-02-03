#!/bin/bash

set -x

source conf.sh

apt-get install -y vlan

modprobe 8021q
echo 8021q >> /etc/modules

vconfig add eth0 100
ifconfig eth0.100 $my_management_ip netmask 255.255.255.0

vconfig add eth0 200
ifconfig eth0.200 $my_provider_network_ip netmask 255.255.255.0

##################################################################
##################################################################
# To make the IP address assigned at boot, add the following lines
# to ‘/etc/network/interfaces’ file

# auto eth0.100
# iface eth0.100 inet static
# address <my_management_ip>
# netmask 255.255.255.0
# vlan-raw-device eth0

# auto eth0.200
# iface eth0.100 inet static
# address <my_provider_network_ip>
# netmask 255.255.255.0
# vlan-raw-device eth0
##################################################################
##################################################################

set +x
