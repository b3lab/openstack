#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/chrony.conf
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE

apt-get install -y chrony

cp ./conf_files/chrony.conf /etc/chrony/chrony.conf
chmod 644 /etc/chrony/chrony.conf

service chrony restart

set +x 
