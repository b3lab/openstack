#!/bin/bash

echo "This patch updates Sahara Ambari plugin files so that "
echo "a Hortonworks Data Platform 2.4 cluster can be launched "
echo "on a OpenStack Mitaka release"
echo -n "Do you want to continue? (y/n): "
read resp

if [ $resp != "y" ];
then
  exit 1
fi

if [ -z "$OS_USERNAME" ] && [ "${OS_USERNAME+xxx}" = "xxx" ] || [ "$OS_USERNAME" != "admin" ];
then
  echo "You should export OpenStack admin user settings before running this script."
  exit 1
fi

ambari_hortonworks2_4_image_name="ambari_hortonworks2_4"

wget http://sahara-files.mirantis.com/images/upstream/newton/sahara-newton-ambari-2.2.1.0-centos.qcow2

openstack image create $ambari_hortonworks2_4_image_name --disk-format qcow2 --container-format bare --file sahara-newton-ambari-2.2.1.0-centos.qcow2 --public

image_id=$(openstack image show $ambari_hortonworks2_4_image_name -f value -c id)

glance image-update $image_id --property _sahara_tag_2.4=True --property _sahara_tag_ambari=True --property _sahara_username=cloud-user

sahara_loc=$(pip show sahara | grep Location | awk '{print $2}')

sudo cp ./ambari_plugin_files/deploy.py $sahara_loc/sahara/plugins/ambari/deploy.py
sudo cp ./ambari_plugin_files/plugin.py $sahara_loc/sahara/plugins/ambari/plugin.py
sudo cp ./ambari_plugin_files/configs-2.4.json $sahara_loc/sahara/plugins/ambari/resources/configs-2.4.json

sudo service sahara-api restart
sudo service sahara-engine restart
sudo service apache2 restart

echo "You can try Hortonworks Data Platform 2.4 from Horizon."

