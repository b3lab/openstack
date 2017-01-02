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

controller_node_hostname='<controller_node_hostname>'
my_management_ip='<my_management_ip>'

# we need 2 network interfaces, one for management network second for provider network
provider_network_interface='<provider_network_interface>'
# tunnel ip will be used if you choose neutron install with openvswitch
TUNNEL_IP='<TUNNEL_IP>'

admin_user_pass=
demo_user_pass=

LINUX_BRIDGE_INTERFACE_DRIVER='neutron.agent.linux.interface.BridgeInterfaceDriver'
OVS_INTERFACE_DRIVER='neutron.agent.linux.interface.OVSInterfaceDriver'

LINUX_BRIDGE_MECHANISM_DRIVERS='linuxbridge,l2population'
OVS_MECHANISM_DRIVERS='openvswitch,l2population'

global_ntp_server='<global_ntp_server>'


# Following options will be used to initialize network

PROVIDER_NETWORK_CIDR=
PROVIDER_NETWORK_GATEWAY=
DNS_RESOLVER=
START_IP_ADDRESS=
END_IP_ADDRESS=

SELFSERVICE_NETWORK_CIDR=
SELFSERVICE_NETWORK_GATEWAY=


# Following options will be set during installation, do not modify

DB_PASS=
ADMIN_TOKEN=

