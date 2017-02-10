#!/bin/bash

set -x

source conf.sh


CONFIG_FILE=./conf_files/keystone.conf

sed -i -e "s/KEYSTONE_DBPASS/$KEYSTONE_DBPASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE

sed -i -e "s/KEYSTONE_DBPASS/$KEYSTONE_DBPASS/g" ./sql_scripts/keystone.sql

mysql -u root -p$DB_PASS < ./sql_scripts/keystone.sql

apt  install -y keystone

cp ./conf_files/keystone.conf /etc/keystone/keystone.conf
chmod 644 /etc/keystone/keystone.conf

su -s /bin/sh -c "keystone-manage db_sync" keystone

keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

keystone-manage bootstrap --bootstrap-password $ADMIN_PASS \
  --bootstrap-admin-url http://$controller_node_hostname:35357/v3/ \
  --bootstrap-internal-url http://$controller_node_hostname:35357/v3/ \
  --bootstrap-public-url http://$controller_node_hostname:5000/v3/ \
  --bootstrap-region-id RegionOne

CONFIG_FILE=./conf_files/apache2.conf
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
cp ./conf_files/apache2.conf /etc/apache2/apache2.conf
chmod 644 /etc/apache2/apache2.conf

service apache2 restart

rm -f /var/lib/keystone/keystone.db

set +x


