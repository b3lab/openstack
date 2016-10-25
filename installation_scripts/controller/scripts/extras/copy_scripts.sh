#!/bin/bash 

for ip in `cat ./host_list`; do
  scp -r ../* root@$ip:/root/
done


