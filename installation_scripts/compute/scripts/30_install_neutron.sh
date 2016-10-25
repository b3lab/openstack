#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/neutron.conf
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE
sed -i -e "s/NEUTRON_PASS/$NEUTRON_PASS/g" $CONFIG_FILE

CONFIG_FILE=./conf_files/linuxbridge_agent.ini
sed -i -e "s/MANAGEMENT_IP/$my_management_ip/g" $CONFIG_FILE
sed -i -e "s/PROVIDER_INTERFACE/$provider_network_interface/g" $CONFIG_FILE


apt-get install -y neutron-linuxbridge-agent

cp ./conf_files/neutron.conf  /etc/neutron/neutron.conf 
chmod 640  /etc/neutron/neutron.conf 
chown root:neutron  /etc/neutron/neutron.conf 

cp ./conf_files/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini
chmod 644 /etc/neutron/plugins/ml2/linuxbridge_agent.ini 
chown root:neutron /etc/neutron/plugins/ml2/linuxbridge_agent.ini

service nova-compute restart
service neutron-linuxbridge-agent restart

