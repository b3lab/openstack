#!/bin/bash

file=/etc/ssh/sshd_config
cp -p $file $file.old &&
awk '
$1=="PermitRootLogin" {$2="yes"}
$1=="PasswordAuthentication" {$2="yes"}
{print}
' $file.old > $file

service ssh restart

