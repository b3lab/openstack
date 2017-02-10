#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/glance-api.conf

sed -i -e "s/GLANCE_DBPASS/$GLANCE_DBPASS/g" ./sql_scripts/glance.sql

sed -i -e "s/GLANCE_DBPASS/$GLANCE_DBPASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/GLANCE_PASS/$GLANCE_PASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE



CONFIG_FILE=./conf_files/glance-registry.conf

sed -i -e "s/GLANCE_DBPASS/$GLANCE_DBPASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/GLANCE_PASS/$GLANCE_PASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE


mysql -u root -p$DB_PASS < ./sql_scripts/glance.sql


export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2


expect -c '
  spawn openstack user create --domain default --password-prompt glance
  expect "*?assword:*"
  send "'"$GLANCE_PASS"'\r";
  expect "*?assword:*"
  send "'"$GLANCE_PASS"'\r";
  interact '

openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image

openstack endpoint create --region RegionOne image public http://$controller_node_hostname:9292
openstack endpoint create --region RegionOne image internal http://$controller_node_hostname:9292
openstack endpoint create --region RegionOne image admin http://$controller_node_hostname:9292


apt install -y glance

cp ./conf_files/glance-api.conf  /etc/glance/glance-api.conf
chown glance:glance /etc/glance/glance-api.conf
chmod 644 /etc/glance/glance-api.conf

cp ./conf_files/glance-registry.conf /etc/glance/glance-registry.conf 
chown glance:glance /etc/glance/glance-registry.conf
chmod 644 /etc/glance/glance-registry.conf

su -s /bin/sh -c "glance-manage db_sync" glance

service glance-registry restart
service glance-api restart

set +x

