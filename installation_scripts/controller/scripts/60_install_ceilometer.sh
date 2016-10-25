#!/bin/bash

set -x



source conf.sh

CONFIG_FILE=./conf_files/ceilometer.conf

sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/CEILOMETER_PASS/$CEILOMETER_PASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE
sed -i -e "s/CEILOMETER_DBPASS/$CEILOMETER_DBPASS/g" $CONFIG_FILE



mongo --host $controller_node_hostname --eval '
  db = db.getSiblingDB("ceilometer");
  db.addUser({user: "ceilometer",
  pwd: "'$CEILOMETER_DBPASS'",
  roles: [ "readWrite", "dbAdmin" ]})'


export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3


expect -c '
  spawn openstack user create --domain default --password-prompt ceilometer
  expect "*?assword:*"
  send "'"$CEILOMETER_PASS"'\r";
  expect "*?assword:*"
  send "'"$CEILOMETER_PASS"'\r";
  interact '

openstack role add --project service --user ceilometer admin
openstack service create --name ceilometer --description "Telemetry" metering

openstack endpoint create --region RegionOne metering public http://$controller_node_hostname:8777
openstack endpoint create --region RegionOne metering internal http://$controller_node_hostname:8777
openstack endpoint create --region RegionOne metering admin http://$controller_node_hostname:8777

apt-get install -y ceilometer-api ceilometer-collector ceilometer-agent-central ceilometer-agent-notification python-ceilometerclient

cp ./conf_files/ceilometer.conf /etc/ceilometer/ceilometer.conf
chmod 644 /etc/ceilometer/ceilometer.conf
chown ceilometer:ceilometer /etc/ceilometer/ceilometer.conf


service ceilometer-agent-central restart
service ceilometer-agent-notification restart
service ceilometer-api restart
service ceilometer-collector restart

service glance-registry restart
service glance-api restart

set +x
