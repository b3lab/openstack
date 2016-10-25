#!/bin/bash

set -x


source conf.sh

CONFIG_FILE=./conf_files/nova.conf


sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/MANAGEMENT_IP/$my_management_ip/g" $CONFIG_FILE
sed -i -e "s/NOVA_PASS/$NOVA_PASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE
sed -i -e "s/NEUTRON_PASS/$NEUTRON_PASS/g" $CONFIG_FILE


apt-get install -y nova-compute

cp ./conf_files/nova.conf /etc/nova/nova.conf
chmod 640 /etc/nova/nova.conf
chown nova:nova /etc/nova/nova.conf 

service nova-compute restart

set +x
