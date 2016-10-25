#!/bin/bash

set -x

source conf.sh

export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$admin_user_pass
export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2


neutron net-create --shared --provider:physical_network provider --provider:network_type flat provider

neutron subnet-create --name provider \
  --allocation-pool start=$START_IP_ADDRESS,end=$END_IP_ADDRESS \
  --dns-nameserver $DNS_RESOLVER --gateway $PROVIDER_NETWORK_GATEWAY \
  provider $PROVIDER_NETWORK_CIDR

neutron net-update provider --router:external

export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=$demo_user_pass
export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2


neutron net-create selfservice

neutron subnet-create --name selfservice \
  --dns-nameserver $DNS_RESOLVER --gateway $SELFSERVICE_NETWORK_GATEWAY \
  selfservice $SELFSERVICE_NETWORK_CIDR

neutron router-create router
neutron router-interface-add router selfservice
neutron router-gateway-set router provider

ip netns

set +x