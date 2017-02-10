#!/bin/bash

set -x


source conf.sh

CONFIG_FILE=./conf_files/heat.conf


sed -i -e "s/HEAT_DBPASS/$HEAT_DBPASS/g" ./sql_scripts/heat.sql

sed -i -e "s/HEAT_DBPASS/$HEAT_DBPASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/HEAT_PASS/$HEAT_PASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE
sed -i -e "s/HEAT_DOMAIN_PASS/$HEAT_DOMAIN_PASS/g" $CONFIG_FILE





cp ./conf_files/heat.conf /etc/heat/heat.conf
chown heat:heat /etc/heat/heat.conf
chmod 640 /etc/heat/heat.conf



set +x

