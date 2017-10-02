#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/ceilometer.conf

sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/CEILOMETER_PASS/$CEILOMETER_PASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE
sed -i -e "s/CEILOMETER_DBPASS/$CEILOMETER_DBPASS/g" $CONFIG_FILE

export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2


expect -c '
  spawn openstack user create --domain default --password-prompt ceilometer
  expect "*?assword:*"
  send "'"$CEILOMETER_PASS"'\r";
  expect "*?assword:*"
  send "'"$CEILOMETER_PASS"'\r";
  interact '

openstack role add --project service --user ceilometer admin
openstack service create --name ceilometer --description "Telemetry" metering

expect -c '
  spawn openstack user create --domain default --password-prompt gnocchi
  expect "*?assword:*"
  send "'"$GNOCCHI_PASS"'\r";
  expect "*?assword:*"
  send "'"$GNOCCHI_PASS"'\r";
  interact '

openstack role add --project service --user gnocchi admin
openstack service create --name gnocchi --description "Metric Service" metric

openstack endpoint create --region RegionOne metric public http://$controller_node_hostname:8041
openstack endpoint create --region RegionOne metric internal http://$controller_node_hostname:8041
openstack endpoint create --region RegionOne metric admin http://$controller_node_hostname:8041

apt-get install -y ceilometer-collector ceilometer-agent-central ceilometer-agent-notification python-ceilometerclient

cp ./conf_files/ceilometer.conf /etc/ceilometer/ceilometer.conf
chmod 644 /etc/ceilometer/ceilometer.conf
chown ceilometer:ceilometer /etc/ceilometer/ceilometer.conf

ceilometer-upgrade --skip-metering-database

service ceilometer-agent-central restart
service ceilometer-agent-notification restart
service ceilometer-collector restart

service glance-registry restart
service glance-api restart

set +x
