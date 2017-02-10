#!/bin/bash

set -x

source conf.sh

export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

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
