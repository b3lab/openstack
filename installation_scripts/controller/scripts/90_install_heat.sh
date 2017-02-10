#!/bin/bash

set -x


source conf.sh

CONFIG_FILE=./conf_files/heat.conf


sed -i -e "s/HEAT_DBPASS/$HEAT_DBPASS/g" ./sql_scripts/heat.sql

sed -i -e "s/HEAT_DBPASS/$HEAT_DBPASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/HEAT_PASS/$HEAT_PASS/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE
sed -i -e "s/HEAT_DOMAIN_PASS/$HEAT_DOMAIN_PASS/g" $CONFIG_FILE



mysql -u root -p$DB_PASS < ./sql_scripts/heat.sql


export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2


expect -c '
  spawn openstack user create --domain default --password-prompt heat
  expect "*?assword:*"
  send "'"$HEAT_PASS"'\r";
  expect "*?assword:*"
  send "'"$HEAT_PASS"'\r";
  interact '

openstack role add --project service --user heat admin

openstack service create --name heat --description "Orchestration" orchestration
openstack service create --name heat-cfn --description "Orchestration"  cloudformation

openstack endpoint create --region RegionOne orchestration public http://$controller_node_hostname:8004/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne orchestration internal http://$controller_node_hostname:8004/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne orchestration admin http://$controller_node_hostname:8004/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne cloudformation public http://$controller_node_hostname:8000/v1

openstack endpoint create --region RegionOne cloudformation internal http://$controller_node_hostname:8000/v1

openstack endpoint create --region RegionOne cloudformation admin http://$controller_node_hostname:8000/v1

openstack domain create --description "Stack projects and users" heat

expect -c '
  spawn openstack user create --domain heat --password-prompt heat_domain_admin
  expect "*?assword:*"
  send "'"$HEAT_DOMAIN_PASS"'\r";
  expect "*?assword:*"
  send "'"$HEAT_DOMAIN_PASS"'\r";
  interact '

openstack role add --domain heat --user-domain heat --user heat_domain_admin admin

openstack role create heat_stack_owner

openstack role add --project demo --user demo heat_stack_owner

openstack role create heat_stack_user

apt  install -y heat-api heat-api-cfn heat-engine

cp ./conf_files/heat.conf /etc/heat/heat.conf
chown heat:heat /etc/heat/heat.conf
chmod 640 /etc/heat/heat.conf

su -s /bin/sh -c "heat-manage db_sync" heat


service heat-api restart
service heat-api-cfn restart
service heat-engine restart

set +x

