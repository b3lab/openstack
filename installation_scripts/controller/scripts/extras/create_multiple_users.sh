#!/bin/bash

#################################################
#          MODIFY FOLLOWING VALUES              #
#################################################

controller_node_hostname=
openstack_admin_password=
provider_network_name=
dns_nameserver=

num_of_users=
project_name_base=
user_name_base=
password=""  # randomly generated 8 digit

instance_quota=15
cores_quota=60
ram_quota=61440
floating_ips_quota=15
ports_quota=200
secgroups_quota=100
secgrouprules_quota=1000
#################################################
#################################################


#################################################
#                 OUTPUT FILE                   #
#################################################
file=yoaccounts.txt
#################################################
#################################################


echo -e "PROJECT NAME\tUSER NAME\tPASSWORD" >> $file
echo "" >> $file

set -x
for (( cnt=1; cnt<=$num_of_users; cnt++ ))
do
    project_name=$project_name_base"_"$cnt
    user_name=$user_name_base"_"$cnt
    password=$(shuf -i 10000000-99999999 -n 1)

    net_name=private"_"$user_name
    subnet_name=private"_"$user_name
    router_name=router"_"$user_name

    echo -e "$project_name\t$user_name\t$password" >> $file

    export OS_PROJECT_DOMAIN_NAME=default
    export OS_USER_DOMAIN_NAME=default
    export OS_PROJECT_NAME=admin
    export OS_USERNAME=admin
    export OS_PASSWORD=$openstack_admin_password
    export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
    export OS_IDENTITY_API_VERSION=3
    export OS_IMAGE_API_VERSION=2

    # create project
    openstack project create --domain default  --description $project_name" Project" $project_name

    # create user and set password
    expect -c '
      spawn openstack user create --domain default --password-prompt '$user_name'
      expect "*?assword:*"
      send "'"$password"'\r";
      expect "*?assword:*"
      send "'"$password"'\r";
      interact '

    # add user role to new user
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

    # create private network
    neutron net-create $net_name
    neutron subnet-create --name $subnet_name \
      --dns-nameserver $dns_nameserver --gateway 172.16.1.1 \
      $net_name 172.16.1.0/24

    neutron router-create $router_name
    neutron router-interface-add $router_name $subnet_name
    neutron router-gateway-set $router_name $provider_network_name

    # open ssh port
    nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
    # open http port
    nova secgroup-add-rule default tcp 80 80 0.0.0.0/0
done
set +x
