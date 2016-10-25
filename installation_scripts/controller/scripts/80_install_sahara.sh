#!/bin/bash

set -x

source conf.sh

sed -i -e "s/SAHARA_DBPASS/$SAHARA_DBPASS/g" ./sql_scripts/sahara.sql

CONFIG_FILE=./conf_files/sahara.conf
sed -i -e "s/SAHARA_DBPASS/$SAHARA_DBPASS/g" $CONFIG_FILE
sed -i -e "s/SAHARA_PASS/$SAHARA_PASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE



mysql -u root -p$DB_PASS < ./sql_scripts/sahara.sql

export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3

expect -c '
  spawn openstack user create --domain default --password-prompt sahara
  expect "*?assword:*"
  send "'"$SAHARA_PASS"'\r";
  expect "*?assword:*"
  send "'"$SAHARA_PASS"'\r";
  interact '

openstack role add --project service --user sahara admin
openstack service create --name sahara \
  --description "OpenStack Data-Processing" data-processing
openstack endpoint create --region RegionOne \
  data-processing public http://$controller_node_hostname:8386/v1.1/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  data-processing internal http://$controller_node_hostname:8386/v1.1/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  data-processing admin http://$controller_node_hostname:8386/v1.1/%\(tenant_id\)s

apt-get install -y sahara


cp ./conf_files/sahara.conf /etc/sahara/sahara.conf
chmod 640 /etc/sahara/sahara.conf
chown root:sahara /etc/sahara/sahara.conf

cp ./conf_files/my.cnf /etc/mysql/my.cnf
chmod 640 /etc/mysql/my.cnf
chown root:mysql /etc/mysql/my.cnf

sahara-db-manage --config-file /etc/sahara/sahara.conf upgrade head

service mysql restart
service sahara-api restart
service sahara-engine restart
set +x

