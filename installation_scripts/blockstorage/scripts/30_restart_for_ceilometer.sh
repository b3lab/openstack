#!/bin/bash

set -x

# Restart the Block Storage services on the controller node:
#service cinder-api restart
#service cinder-scheduler restart

service cinder-volume restart

set +x
