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

# install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

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
