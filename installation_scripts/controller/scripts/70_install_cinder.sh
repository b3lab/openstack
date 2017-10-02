#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/cinder.conf


sed -i -e "s/CINDER_DBPASS/$CINDER_DBPASS/g" ./sql_scripts/cinder.sql

sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/MANAGEMENT_IP/$my_management_ip/g" $CONFIG_FILE
sed -i -e "s/CINDER_DBPASS/$CINDER_DBPASS/g" $CONFIG_FILE
sed -i -e "s/CINDER_PASS/$CINDER_PASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE


mysql -u root -p$DB_PASS < ./sql_scripts/cinder.sql

export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3


export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2



expect -c '
  spawn openstack user create --domain default --password-prompt cinder
  expect "*?assword:*"
  send "'"$CINDER_PASS"'\r";
  expect "*?assword:*"
  send "'"$CINDER_PASS"'\r";
  interact '


openstack role add --project service --user cinder admin
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

openstack endpoint create --region RegionOne volumev2 public http://$controller_node_hostname:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://$controller_node_hostname:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://$controller_node_hostname:8776/v2/%\(project_id\)s

openstack endpoint create --region RegionOne volumev3 public http://$controller_node_hostname:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://$controller_node_hostname:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://$controller_node_hostname:8776/v2/v3/%\(project_id\)s

apt-get install -y cinder-api cinder-scheduler

cp ./conf_files/cinder.conf /etc/cinder/cinder.conf
chown cinder:cinder /etc/cinder/cinder.conf
chmod 644 /etc/cinder/cinder.conf

su -s /bin/sh -c "cinder-manage db sync" cinder

service nova-api restart
service cinder-scheduler restart

set +x



