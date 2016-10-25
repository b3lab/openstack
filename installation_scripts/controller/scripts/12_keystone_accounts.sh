#!/bin/bash

set -x

source conf.sh

export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3

openstack domain create --description "Default Domain" default

openstack project create --domain default --description "Admin Project" admin


expect -c '
  spawn openstack user create --domain default --password-prompt admin
  expect "*?assword:*"
  send "'"$admin_user_pass"'\r";
  expect "*?assword:*"
  send "'"$admin_user_pass"'\r";
  interact '

openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --domain default --description "Service Project" service

openstack project create --domain default --description "Demo Project" demo


expect -c '
  spawn openstack user create --domain default --password-prompt demo
  expect "*?assword:*"
  send "'"$demo_user_pass"'\r";
  expect "*?assword:*"
  send "'"$demo_user_pass"'\r";
  interact '

openstack role create user
openstack role add --project demo --user demo user


set +x
