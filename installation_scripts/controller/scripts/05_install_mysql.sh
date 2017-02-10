#!/bin/bash

set -x

source conf.sh


CONFIG_FILE=./conf_files/99-openstack.cnf
TARGET_KEY=bind-address
REPLACEMENT_VALUE=$my_management_ip

sed -i "s/\($TARGET_KEY *= *\).*/\1$REPLACEMENT_VALUE/" $CONFIG_FILE

apt-get install -y mariadb-server python-pymysql

cp ./conf_files/99-openstack.cnf /etc/mysql/mariadb.conf.d/99-openstack.cnf
chmod 644 /etc/mysql/mariadb.conf.d/99-openstack.cnf


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


