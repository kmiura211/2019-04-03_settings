#!/bin/bash

# update packages
yum update -y

# disable selinux
sed s/enforcing/disabled/ /etc/selinux/config

# disable firewall
systemctl stop firewalld
systemctl disable firewalld

# install apache
yum install -y httpd

# install php


# install mysql

# install samba
yum install -y samba samba-client samba-common

mv /etc/samba/smb.conf /etc/samba/smb.conf.bk
touch /etc/samba/smb.conf

cat <<EOF > /etc/samba/smb.conf
[global]
workgroup = MYGROUP
server string = Samba Server Version %v
netbios name = MYSERVER
log file = /var/log/samba/log.%m
max log size = 50
security = user
passdb backend = tdbsam
load printers = yes
cups options = raw

[homes]
comment = Home Directories
browseable = no
writable = yes

path = /
writable = yes
guest ok = yes
guest only = yes
create mode = 0777
directory mode = 0777
share modes = yes
EOF

systemctl enable smb.service
systemctl enable nmb.service
systemctl restart smb.service
systemctl restart nmb.service
