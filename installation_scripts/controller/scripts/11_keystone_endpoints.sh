#!/bin/bash


set -x

source conf.sh

export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3

openstack service create --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne identity public http://$controller_node_hostname:5000/v3
openstack endpoint create --region RegionOne identity internal http://$controller_node_hostname:5000/v3
openstack endpoint create --region RegionOne identity admin http://$controller_node_hostname:35357/v3


set +x
