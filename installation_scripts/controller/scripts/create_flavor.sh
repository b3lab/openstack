#!/bin/bash

set +x


openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano

openstack flavor create --id 1 --vcpus 1 --ram 512 --disk 1 m1.tiny

openstack flavor create --id 2 --vcpus 1 --ram 2048 --disk 20 m1.small

openstack flavor create --id 3 --vcpus 2 --ram 4096 --disk 40 m1.medium

openstack flavor create --id 4 --vcpus 4 --ram 8192 --disk 80 m1.large

openstack flavor create --id 5 --vcpus 8 --ram 16384 --disk 80 m1.xlarge

set -x

