#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/memcached.conf
REPLACEMENT_VALUE=$my_management_ip


sed -i -e "s/HOST_IP/$REPLACEMENT_VALUE/g" $CONFIG_FILE


apt install -y memcached python-memcache
cp ./conf_files/memcached.conf /etc/memcached.conf
chmod 644 /etc/memcached.conf

service memcached restart

set +x
