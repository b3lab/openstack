#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/memcached.conf
TARGET_KEY='-l'
REPLACEMENT_VALUE=$my_management_ip


sed -i "s/^$TARGET_KEY .*/$TARGET_KEY $REPLACEMENT_VALUE/" $CONFIG_FILE

apt-get install -y memcached python-memcache
cp ./conf_files/memcached.conf /etc/memcached.conf
chmod 644 /etc/memcached.conf

service memcached restart

set +x
