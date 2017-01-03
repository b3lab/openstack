#!/bin/bash

set -x

source ../conf.sh

export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3

wget http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-root.tar.gz
############################################################################################
#lxd için kullanılacak imaja hypervisor_type=lxd verdiğimiz gibi diğer imajlara da         # #hypervisor_type=kvm vermek gerekir. Yoksa nova diğer imajları container nodu üzerinde boot#   #etmeye çalışabilir.                                                                       #  
############################################################################################
glance image-create --name="ubuntu-trusty-lxd" --visibility public --progress \
--container-format=bare --disk-format=raw \
--file trusty-server-cloudimg-amd64-root.tar.gz \
--property hypervisor_type=lxd


set +x
