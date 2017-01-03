#!/bin/bash

# ALL OPTIONS ARE NECESSARY!

ADMIN_PASS=
CEILOMETER_DBPASS=
CEILOMETER_PASS=
CINDER_DBPASS=
CINDER_PASS=
DASH_DBPASS=
DEMO_PASS=
GLANCE_DBPASS=
GLANCE_PASS=
HEAT_DBPASS=
HEAT_DOMAIN_PASS=
HEAT_PASS=
KEYSTONE_DBPASS=
NEUTRON_DBPASS=
NEUTRON_PASS=
NOVA_DBPASS=
NOVA_PASS=
RABBIT_PASS=
SWIFT_PASS=
METADATA_SECRET=
TUNNEL_IP=''
controller_node_hostname=''
controller_node_management_ip=''

my_hostname=''
my_management_ip=''

# we need 2 network interfaces, one for management network second for provider network
provider_network_interface=''
