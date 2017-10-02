#!/bin/bash

set -x

source conf.sh

CONFIG_FILE=./conf_files/gnocchi.conf

sed -i -e "s/GNOCCHI_DBPASS/$GNOCCHI_DBPASS/g" ./sql_scripts/gnocchi.sql

sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" ./conf_files/uwsgi.ini

sed -i -e "s/GNOCCHI_PASS/$GNOCCHI_PASS/g" $CONFIG_FILE
sed -i -e "s/GNOCCHI_DBPASS/$GNOCCHI_DBPASS/g" $CONFIG_FILE
sed -i -e "s/CONTROLLER_HOSTNAME/$controller_node_hostname/g" $CONFIG_FILE
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g" $CONFIG_FILE

mysql -u root -p$DB_PASS < ./sql_scripts/gnocchi.sql

pip install gnocchi[mysql,file,keystone]==3.1.9

adduser --system --group --shell /bin/false --home /var/lib/gnocchi --disabled-password gnocchi
mkdir /etc/gnocchi
mkdir /var/log/gnocchi/
mkdir /var/cache/gnocchi

cp ./conf_files/gnocchi.conf /etc/gnocchi/gnocchi.conf
cp ./conf_files/api-paste.ini /etc/gnocchi/api-paste.ini
cp ./conf_files/uwsgi.ini /etc/gnocchi/uwsgi.ini

chown -R gnocchi:gnocchi /etc/gnocchi/
chown gnocchi:gnocchi /var/log/gnocchi/
chown gnocchi:gnocchi /var/cache/gnocchi/
chown -R gnocchi:gnocchi /var/lib/gnocchi/

gnocchi-upgrade

cp ./conf_files/gnocchi-metricd.service /etc/systemd/system/gnocchi-metrics.service

systemctl start gnocchi-metricd.service

#cp ./conf_files/gnocchi-httpd.conf /etc/apache2/sites-available/gnocchi-httpd.conf
#a2ensite gnocchi-httpd.conf
#service apache2 reload

pip install gnocchiclient==3.1.0
pip install uwsgi
uwsgi /etc/gnocchi/uwsgi.ini


set +x
