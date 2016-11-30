#!/bin/bash

set -x


source conf.sh

CONFIG_FILE=./conf_files/cinder.conf

sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/MANAGEMENT_IP/$my_management_ip/g" $CONFIG_FILE
sed -i -e "s/CINDER_PASS/$CINDER_PASS/g" $CONFIG_FILE
sed -i -e "s/CINDER_DBPASS/$CINDER_DBPASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE
sed -i -e "s/NEUTRON_PASS/$NEUTRON_PASS/g" $CONFIG_FILE

CONFIG_FILE=./conf_files/lvm.conf

# If your storage nodes use LVM on the operating system disk, 
# you must also add the associated device to the filter at lvm.conf.
sed -i -e "s/PHYSICAL_VOLUME/$PHYSICAL_VOLUME/g" $CONFIG_FILE

apt-get install -y lvm2
pvcreate /dev/$PHYSICAL_VOLUME
vgcreate cinder-volumes /dev/$PHYSICAL_VOLUME

cp ./conf_files/lvm.conf /etc/lvm/lvm.conf
chmod 644 /etc/lvm/lvm.conf
chown root:root /etc/lvm/lvm.conf 

apt-get install -y cinder-volume

cp ./conf_files/cinder.conf /etc/cinder/cinder.conf
chmod 644 /etc/cinder/cinder.conf
chown cinder:cinder /etc/cinder/cinder.conf 

service tgt restart
service cinder-volume restart

set +x

