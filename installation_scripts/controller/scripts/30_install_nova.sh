#!/bin/bash

set -x


source conf.sh

CONFIG_FILE=./conf_files/nova.conf


sed -i -e "s/NOVA_DBPASS/$NOVA_DBPASS/g" ./sql_scripts/nova.sql

sed -i -e "s/NOVA_DBPASS/$NOVA_DBPASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/MANAGEMENT_IP/$my_management_ip/g" $CONFIG_FILE
sed -i -e "s/NOVA_PASS/$NOVA_PASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE
sed -i -e "s/NEUTRON_PASS/$NEUTRON_PASS/g" $CONFIG_FILE
sed -i -e "s/METADATA_SECRET/$METADATA_SECRET/g" $CONFIG_FILE



mysql -u root -p$DB_PASS < ./sql_scripts/nova.sql

export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3

expect -c '
  spawn openstack user create --domain default --password-prompt nova
  expect "*?assword:*"
  send "'"$NOVA_PASS"'\r";
  expect "*?assword:*"
  send "'"$NOVA_PASS"'\r";
  interact '

openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute


openstack endpoint create --region RegionOne compute public http://$controller_node_hostname:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://$controller_node_hostname:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://$controller_node_hostname:8774/v2.1/%\(tenant_id\)s


apt-get install -y nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler

cp ./conf_files/nova.conf /etc/nova/nova.conf
chown nova:nova /etc/nova/nova.conf
chmod 640 /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage db sync" nova

service nova-api restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart


set +x

