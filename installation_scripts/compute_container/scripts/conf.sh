#!/bin/bash

# ALL OPTIONS ARE NECESSARY!

ADMIN_PASS=
DEMO_PASS=
GLANCE_PASS=
NEUTRON_PASS=
NOVA_PASS=
PLACEMENT_PASS=
RABBIT_PASS=
METADATA_SECRET=
TUNNEL_IP=''
controller_node_hostname='<controller_node_hostname>'
controller_node_management_ip='<<controller_node_management_ip>'

my_hostname='<my_hostname>'
my_management_ip='<my_management_ip>'

# we need 2 network interfaces, one for management network second for provider network
provider_network_interface='<provider_network_interface>'
