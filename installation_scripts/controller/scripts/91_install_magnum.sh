#!/bin/bash

set -x

source conf.sh

sed -i -e "s/MAGNUM_DBPASS/$MAGNUM_DBPASS/g" ./sql_scripts/magnum.sql

CONFIG_FILE=./conf_files/magnum.conf
sed -i -e "s/MAGNUM_DBPASS/$MAGNUM_DBPASS/g" $CONFIG_FILE
sed -i -e "s/MAGNUM_PASS/$MAGNUM_PASS/g" $CONFIG_FILE
sed -i -e "s/MAGNUM_DOMAIN_ADMIN_PASS/$MAGNUM_DOMAIN_ADMIN_PASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/MANAGEMENT_IP/$my_management_ip/g" $CONFIG_FILE
sed -i -e "s/PUBLIC_IP/$my_public_ip/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE



mysql -u root -p$DB_PASS < ./sql_scripts/magnum.sql

export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

expect -c '
  spawn openstack user create --domain default --password-prompt magnum
  expect "*?assword:*"
  send "'"$MAGNUM_PASS"'\r";
  expect "*?assword:*"
  send "'"$MAGNUM_PASS"'\r";
  interact '

openstack role add --project service --user magnum admin

openstack service create --name magnum \
  --description "OpenStack Container Infrastructure Management Service" \
  container-infra

openstack endpoint create --region RegionOne \
  container-infra public http://$controller_node_hostname:9511/v1

openstack endpoint create --region RegionOne \
  container-infra internal http://$controller_node_hostname:9511/v1

openstack endpoint create --region RegionOne \
  container-infra admin http://$controller_node_hostname:9511/v1

openstack domain create --description "Owns users and projects \
  created by magnum" magnum

expect -c '
  spawn openstack user create --domain magnum --password-prompt magnum_domain_admin
  expect "*?assword:*"
  send "'"$MAGNUM_DOMAIN_ADMIN_PASS"'\r";
  expect "*?assword:*"
  send "'"$MAGNUM_DOMAIN_ADMIN_PASS"'\r";
  interact '

openstack role add --domain magnum --user-domain magnum --user \
  magnum_domain_admin admin

DEBIAN_FRONTEND=noninteractive apt-get install -y magnum-api magnum-conductor python-magnumclient


cp ./conf_files/magnum.conf /etc/magnum/magnum.conf
chmod 640 /etc/magnum/magnum.conf
chown magnum:magnum /etc/magnum/magnum.conf

su -s /bin/sh -c "magnum-db-manage upgrade" magnum

service magnum-api restart
service magnum-conductor restart

set +x

