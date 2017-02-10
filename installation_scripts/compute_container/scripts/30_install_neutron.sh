#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/neutron.conf
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE
sed -i -e "s/NEUTRON_PASS/$NEUTRON_PASS/g" $CONFIG_FILE

echo 'Select network method:'
echo  '[1] Linux Bidge '
echo '[2] Openvswitch '
read choice
if [ $choice -eq 1 ]; then

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
fi

if [ $choice -eq 2 ]; then
	CONFIG_FILE=./conf_files/openvswitch_agent.ini
        sed -i -e "s/TUNNEL_IP/$TUNNEL_IP/g" $CONFIG_FILE
	 apt-get install -y neutron-openvswitch-agent neutron-plugin-ml2
	
	cp ./conf_files/neutron.conf /etc/neutron/neutron.conf
        chmod 640 /etc/neutron/neutron.conf
        chown root:neutron /etc/neutron/neutron.conf

	cp ./conf_files/openvswitch_agent.ini /etc/neutron/plugins/ml2/openvswitch_agent.ini
        chmod 644 /etc/neutron/plugins/ml2/openvswitch_agent.ini
        chown root:neutron /etc/neutron/plugins/ml2/openvswitch_agent.ini
	
	cp ./conf_files/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
        chmod 644 /etc/neutron/plugins/ml2/ml2_conf.ini
        chown root:neutron /etc/neutron/plugins/ml2/ml2_conf.ini

	service nova-compute restart
	service neutron-openvswitch-agent restart

fi
