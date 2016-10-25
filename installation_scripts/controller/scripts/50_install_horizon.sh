#!/bin/bash

set -x


source conf.sh

CONFIG_FILE=./conf_files/local_settings.py

sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE


apt-get install -y openstack-dashboard

cp ./conf_files/local_settings.py  /etc/openstack-dashboard/local_settings.py
chmod 644 /etc/openstack-dashboard/local_settings.py

service apache2 reload

set +x
