#!/bin/bash

set -x

source conf.sh

echo "" >> "/etc/hosts"
echo "$my_management_ip $controller_node_hostname" >> "/etc/hosts"

sed -i "s/^127.0.1.1 /# 127.0.1.1 /" /etc/hosts


set +x
