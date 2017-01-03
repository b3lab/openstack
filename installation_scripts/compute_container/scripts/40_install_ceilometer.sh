#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/ceilometer.conf


sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/CEILOMETER_PASS/$CEILOMETER_PASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE


apt-get install -y ceilometer-agent-compute

cp ./conf_files/ceilometer.conf /etc/ceilometer/ceilometer.conf
chown ceilometer:ceilometer /etc/ceilometer/ceilometer.conf
chmod 644 /etc/ceilometer/ceilometer.conf

service ceilometer-agent-compute restart
service nova-compute restart

set +x
