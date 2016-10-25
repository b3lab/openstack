#!/bin/bash

set -x

source conf.sh

sed -i -e "s/NEUTRON_DBPASS/$NEUTRON_DBPASS/g" ./sql_scripts/neutron.sql

CONFIG_FILE=./conf_files/neutron.conf
sed -i -e "s/NEUTRON_DBPASS/$NEUTRON_DBPASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE
sed -i -e "s/NEUTRON_PASS/$NEUTRON_PASS/g" $CONFIG_FILE
sed -i -e "s/NOVA_PASS/$NOVA_PASS/g" $CONFIG_FILE

CONFIG_FILE=./conf_files/linuxbridge_agent.ini
sed -i -e "s/MANAGEMENT_IP/$my_management_ip/g" $CONFIG_FILE
sed -i -e "s/PROVIDER_INTERFACE/$provider_network_interface/g" $CONFIG_FILE

CONFIG_FILE=./conf_files/openvswitch_agent.ini
sed -i -e "s/MANAGEMENT_IP/$my_management_ip/g" $CONFIG_FILE


CONFIG_FILE=./conf_files/metadata_agent.ini
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/METADATA_SECRET/$METADATA_SECRET/g" $CONFIG_FILE


mysql -u root -p$DB_PASS < ./sql_scripts/neutron.sql

export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3

expect -c '
  spawn openstack user create --domain default --password-prompt neutron
  expect "*?assword:*"
  send "'"$NEUTRON_PASS"'\r";
  expect "*?assword:*"
  send "'"$NEUTRON_PASS"'\r";
  interact '

openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network

openstack endpoint create --region RegionOne network public http://$controller_node_hostname:9696
openstack endpoint create --region RegionOne network internal http://$controller_node_hostname:9696
openstack endpoint create --region RegionOne network admin http://$controller_node_hostname:9696

echo "Linux Bridge ile kurulum için 1, Openvswitch ile kurulum için 2'yi tıklayınız"
read choice
if [ $choice -eq 1 ]; then

	apt-get install -y neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent

	 CONFIG_FILE=./conf_files/dhcp_agent.ini
        sed -i -e "s/INTERFACE_DRIVER/$LINUX_BRIDGE_INTERFACE_DRIVER/g" $CONFIG_FILE

        CONFIG_FILE=./conf_files/ml2_conf.ini
        sed -i -e "s/MECHANISM_DRIVERS/$LINUX_BRIDGE_MECHANISM_DRIVERS/g" $CONFIG_FILE

        CONFIG_FILE=./conf_files/l3_agent.ini
        sed -i -e "s/INTERFACE_DRIVER/$LINUX_BRIDGE_INTERFACE_DRIVER/g" $CONFIG_FILE

	cp ./conf_files/neutron.conf /etc/neutron/neutron.conf
	chmod 640 /etc/neutron/neutron.conf
	chown root:neutron /etc/neutron/neutron.conf

	cp ./conf_files/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini
	chmod 644 /etc/neutron/plugins/ml2/linuxbridge_agent.ini
	chown root:neutron /etc/neutron/plugins/ml2/linuxbridge_agent.ini

	cp ./conf_files/dhcp_agent.ini /etc/neutron/dhcp_agent.ini
	chmod 644 /etc/neutron/dhcp_agent.ini
	chown root:neutron /etc/neutron/dhcp_agent.ini

	cp ./conf_files/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
	chmod 644 /etc/neutron/plugins/ml2/ml2_conf.ini
	chown root:neutron /etc/neutron/plugins/ml2/ml2_conf.ini

	cp ./conf_files/l3_agent.ini /etc/neutron/l3_agent.ini 
	chmod 644 /etc/neutron/l3_agent.ini
	chown root:neutron /etc/neutron/l3_agent.ini

	cp ./conf_files/metadata_agent.ini /etc/neutron/metadata_agent.ini
	chmod 644 /etc/neutron/metadata_agent.ini
	chown root:neutron /etc/neutron/metadata_agent.ini
	su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

	service nova-api restart
	service neutron-server restart
	service neutron-linuxbridge-agent restart
	service neutron-dhcp-agent restart
	service neutron-metadata-agent restart
	service neutron-l3-agent restart

fi

if [ $choice -eq 2 ]; then

        apt-get install -y neutron-server neutron-plugin-ml2 neutron-openvswitch-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent
	
	ovs-vsctl add-br br-provider
	ovs-vsctl add-port br-provider $provider_network_interface
	
	CONFIG_FILE=./conf_files/dhcp_agent.ini
        sed -i -e "s/INTERFACE_DRIVER/$OVS_INTERFACE_DRIVER/g" $CONFIG_FILE

	CONFIG_FILE=./conf_files/ml2_conf.ini
        sed -i -e "s/MECHANISM_DRIVERS/$OVS_MECHANISM_DRIVERS/g" $CONFIG_FILE
	
	CONFIG_FILE=./conf_files/l3_agent.ini
        sed -i -e "s/INTERFACE_DRIVER/$OVS_INTERFACE_DRIVER/g" $CONFIG_FILE

	
	cp ./conf_files/neutron.conf /etc/neutron/neutron.conf
        chmod 640 /etc/neutron/neutron.conf
        chown root:neutron /etc/neutron/neutron.conf

        cp ./conf_files/openvswitch_agent.ini /etc/neutron/plugins/ml2/openvswitch_agent.ini
        chmod 644 /etc/neutron/plugins/ml2/openvswitch_agent.ini
        chown root:neutron /etc/neutron/plugins/ml2/openvswitch_agent.ini

        cp ./conf_files/dhcp_agent.ini /etc/neutron/dhcp_agent.ini
        chmod 644 /etc/neutron/dhcp_agent.ini
        chown root:neutron /etc/neutron/dhcp_agent.ini

        cp ./conf_files/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
        chmod 644 /etc/neutron/plugins/ml2/ml2_conf.ini
        chown root:neutron /etc/neutron/plugins/ml2/ml2_conf.ini

        cp ./conf_files/l3_agent.ini /etc/neutron/l3_agent.ini
        chmod 644 /etc/neutron/l3_agent.ini
        chown root:neutron /etc/neutron/l3_agent.ini

        cp ./conf_files/metadata_agent.ini /etc/neutron/metadata_agent.ini
        chmod 644 /etc/neutron/metadata_agent.ini
        chown root:neutron /etc/neutron/metadata_agent.ini


	su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

        service nova-api restart
        service neutron-server restart
        service neutron-openvswitch-agent restart
        service neutron-dhcp-agent restart
        service neutron-metadata-agent restart
        service neutron-l3-agent restart
fi


set +x
