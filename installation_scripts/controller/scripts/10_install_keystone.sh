#!/bin/bash

set -x

source conf.sh

comm=$(openssl rand -hex 10)
token=${comm}


CONFIG_FILE=./conf_files/keystone.conf

sed -i "s/\(ADMIN_TOKEN *= *\).*/\1$token/" ./conf.sh

sed -i -e "s/ADMIN_TOKEN/$token/g" $CONFIG_FILE
sed -i -e "s/KEYSTONE_DBPASS/$KEYSTONE_DBPASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE

sed -i -e "s/KEYSTONE_DBPASS/$KEYSTONE_DBPASS/g" ./sql_scripts/keystone.sql

mysql -u root -p$DB_PASS < ./sql_scripts/keystone.sql


echo "manual" > /etc/init/keystone.override
apt-get install -y keystone apache2 libapache2-mod-wsgi

cp ./conf_files/keystone.conf /etc/keystone/keystone.conf
chmod 644 /etc/keystone/keystone.conf

su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

cp ./conf_files/wsgi-keystone.conf /etc/apache2/sites-available/wsgi-keystone.conf
chmod 644 /etc/apache2/sites-available/wsgi-keystone.conf

ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled

CONFIG_FILE=./conf_files/apache2.conf
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
cp ./conf_files/apache2.conf /etc/apache2/apache2.conf
chmod 644 /etc/apache2/apache2.conf

service apache2 restart

rm -f /var/lib/keystone/keystone.db

set +x


