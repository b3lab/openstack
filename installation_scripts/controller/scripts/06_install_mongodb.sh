#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/mongodb.conf
TARGET_KEY=bind_ip
REPLACEMENT_VALUE=$my_management_ip

sed -i "s/\($TARGET_KEY *= *\).*/\1$REPLACEMENT_VALUE/" $CONFIG_FILE


apt-get install -y mongodb-server mongodb-clients python-pymongo

cp ./conf_files/mongodb.conf /etc/mongodb.conf
chmod 644 /etc/mongodb.conf

service mongodb stop
rm /var/lib/mongodb/journal/prealloc.*
service mongodb start

set +x
