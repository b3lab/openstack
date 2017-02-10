#!/bin/bash

set -x

apt-get -y update
apt-get install -y python-openstackclient

set +x
