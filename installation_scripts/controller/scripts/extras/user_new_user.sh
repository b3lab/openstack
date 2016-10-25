#!/bin/bash

display_usage() {
    echo "This script generates an OpenStack user with the given parameters inside the script." 
    echo -e "\nUsage:\n$0 project_name user_name\n" 
}


if [  $# -ne 2 ]
then
    display_usage
    exit 1
fi


echo "This script generates an OpenStack user with the given parameters inside the script." 
echo -n "Do you want to continue? (y/n): "
read resp

if [ $resp != "y" ];
then
    exit 1
fi


set -x

project_name=$1
user_name=$2
password=$(shuf -i 10000000-99999999 -n 1)

controller_node_hostname=
provider_network_name=
dns_nameserver=

instance_quota=15
cores_quota=60
ram_quota=61440
floating_ips_quota=15
ports_quota=200
secgroups_quota=100
secgrouprules_quota=1000


source adminrc.sh

openstack project create --domain default  --description $project_name" Project" $project_name

expect -c '
  spawn openstack user create --domain default --password-prompt '$user_name'
  expect "*?assword:*"
  send "'"$password"'\r";
  expect "*?assword:*"
  send "'"$password"'\r";
  interact '

openstack role add --project $project_name --user $user_name user

# modify quotas
tenant=$(openstack project show -f value -c id $project_name)
openstack quota set --instances $instance_quota $tenant
openstack quota set --cores $cores_quota $tenant
openstack quota set --ram $ram_quota $tenant
openstack quota set --floating-ips $floating_ips_quota $tenant
openstack quota set --ports $ports_quota $tenant
openstack quota set --secgroups $secgroups_quota $tenant
openstack quota set --secgroup-rules $secgrouprules_quota $tenant


export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=$project_name
export OS_USERNAME=$user_name
export OS_PASSWORD=$password
export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

net_name=private"_"$user_name
subnet_name=private"_"$user_name
router_name=router"_"$user_name

neutron net-create $net_name
neutron subnet-create --name $subnet_name \
  --dns-nameserver $dns_nameserver --gateway 172.16.1.1 \
  $net_name 172.16.1.0/24

neutron router-create $router_name
neutron router-interface-add $router_name $subnet_name
neutron router-gateway-set $router_name $provider_network_name

nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default tcp 80 80 0.0.0.0/0


set +x

echo "##################################"
echo "Password for $user_name: $password" 
echo "##################################"
