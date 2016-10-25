#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/chrony.conf
TARGET_KEY=server
REPLACEMENT_VALUE=$global_ntp_server

sed -i "s/^$TARGET_KEY .*/$TARGET_KEY $REPLACEMENT_VALUE iburst/" $CONFIG_FILE

apt-get install -y chrony

cp ./conf_files/chrony.conf /etc/chrony/chrony.conf
chmod 644 /etc/chrony/chrony.conf

service chrony restart

set +x
