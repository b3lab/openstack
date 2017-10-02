#!/bin/bash

set -x


source conf.sh

CONFIG_FILE=./conf_files/nova.conf


sed -i -e "s/NOVA_DBPASS/$NOVA_DBPASS/g" ./sql_scripts/nova.sql

sed -i -e "s/NOVA_DBPASS/$NOVA_DBPASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/MANAGEMENT_IP/$my_management_ip/g" $CONFIG_FILE
sed -i -e "s/NOVA_PASS/$NOVA_PASS/g" $CONFIG_FILE
sed -i -e "s/PLACEMENT_PASS/$PLACEMENT_PASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE
sed -i -e "s/NEUTRON_PASS/$NEUTRON_PASS/g" $CONFIG_FILE
sed -i -e "s/METADATA_SECRET/$METADATA_SECRET/g" $CONFIG_FILE



mysql -u root -p$DB_PASS < ./sql_scripts/nova.sql


export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2


expect -c '
  spawn openstack user create --domain default --password-prompt nova
  expect "*?assword:*"
  send "'"$NOVA_PASS"'\r";
  expect "*?assword:*"
  send "'"$NOVA_PASS"'\r";
  interact '

openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute


openstack endpoint create --region RegionOne compute public http://$controller_node_hostname:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://$controller_node_hostname:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://$controller_node_hostname:8774/v2.1


expect -c '
  spawn openstack user create --domain default --password-prompt placement
  expect "*?assword:*"
  send "'"$PLACEMENT_PASS"'\r";
  expect "*?assword:*"
  send "'"$PLACEMENT_PASS"'\r";
  interact '


openstack role add --project service --user placement admin
openstack service create --name placement --description "Placement API" placement


openstack endpoint create --region RegionOne placement public http://$controller_node_hostname:8778
openstack endpoint create --region RegionOne placement internal http://$controller_node_hostname:8778
openstack endpoint create --region RegionOne placement admin http://$controller_node_hostname:8778


apt  install -y nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler nova-placement-api

cp ./conf_files/nova.conf /etc/nova/nova.conf
chown nova:nova /etc/nova/nova.conf
chmod 640 /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova

service nova-api restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart


set +x

