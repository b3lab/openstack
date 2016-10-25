#!/bin/bash

display_usage() {
    echo "This script exports OpenStack authentication variables for a user in accounts file or the given project name and password." 
    echo -e "\nUsage:\nsource $0 user_name [project_name] [password]\n" 
} 

if [  $# -eq 0 ] 
then
    display_usage
    exit 1
fi 

###########################
# MODIFY FOLLOWING VALUES #
###########################

controller_node_hostname=
accounts_filename=yoaccounts.txt

########################################
########################################

project_name=$2
user_name=$1
password=$3

if [ $# -eq 1  ]
then
  linesToSkip=2
  {
    for ((i=$linesToSkip;i--;)) ;do
        read
        done
    
    found=false
    while IFS=$'\t' read -r cproject_name cuser_name cpassword && [[ $found = false ]]; do
        if [ $cuser_name = $user_name ];
        then
            project_name=$cproject_name
            password=$cpassword
            found=true
        fi;
    done
  } < "$accounts_filename"
fi
##################
# AUTHENTICATION #
##################

export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=$project_name
export OS_USERNAME=$user_name
export OS_PASSWORD=$password
export OS_AUTH_URL=http://$controller_node_hostname:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2


