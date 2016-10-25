#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/openstack.cnf
TARGET_KEY=bind-address
REPLACEMENT_VALUE=$my_management_ip

sed -i "s/\($TARGET_KEY *= *\).*/\1$REPLACEMENT_VALUE/" $CONFIG_FILE

apt-get install -y mariadb-server python-pymysql

cp ./conf_files/openstack.cnf /etc/mysql/conf.d/openstack.cnf
chmod 644 /etc/mysql/conf.d/openstack.cnf

CONFIG_FILE=/etc/mysql/my.cnf
TARGET_KEY=max_connections
NEW_VALUE=1000
sed -i "s/\(#$TARGET_KEY *= *\).*/$TARGET_KEY = $NEW_VALUE/" $CONFIG_FILE

service mysql restart

mysql_secure_installation

set +x

# Read Password
echo -n MySQL root password:
read -s password
echo
echo -n Retype MySQL root password:
read -s repassword
echo

if [ "$password" = "$repassword" ]; then
  sed -i "s/\(DB_PASS *= *\).*/\1$password/" ./conf.sh
else
  echo "Password do not match! Modify conf.sh and change DB_PASS manually!!!"
fi


