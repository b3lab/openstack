#!/bin/bash

set -x

apt install -y software-properties-common


expect -c '
  spawn add-apt-repository cloud-archive:ocata
  expect "to continue or ctrl-c to cancel adding it"
  send "\r";
  interact '

apt-get -y update && apt-get -y dist-upgrade

echo "##########################################"
echo "####     SYSTEM WILL BE REBOOTED      ####"
echo "##########################################"

sleep 10

reboot

set +x
