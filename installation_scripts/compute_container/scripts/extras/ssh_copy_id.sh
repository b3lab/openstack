#!/bin/bash 

for ip in `cat ./host_list`; do
  ssh-copy-id -i ~/.ssh/id_rsa.pub $ip
done


