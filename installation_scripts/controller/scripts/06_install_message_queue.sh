#!/bin/bash

set -x

source conf.sh

apt-get install -y rabbitmq-server
rabbitmqctl add_user openstack $RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

set +x
