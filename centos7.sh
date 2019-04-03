#!/bin/bash

# update packages
yum update -y

# disable selinux
sed s/enforcing/disabled/ /etc/selinux/config

# disable firewall
systemctl stop firewalld.service
systemctl disable firewalld.service

# install apache
yum install httpd -y
systemctl start httpd.service
systemctl enable httpd.service

# install php
yum install epel-release -y
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum install --enablerepo=remi,remi-php73 php -y

# install mysql
yum remove mariadb-libs -y
rm -rf /var/lib/mysql
rpm -ivh http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
yum install mysql-community-server -y
systemctl start mysqld.service
systemctl enable mysqld.service

# install samba
yum install samba samba-client samba-common -y

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
dos charset = CP932
unix charset = UTF8
display charset = UTF8

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
