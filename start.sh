#!/bin/bash

# update packages
yum update -y

# disable selinux
sed s/enforcing/disabled/ /etc/selinux/config

# disable firewall
systemctl stop firewalld
systemctl disable firewalld
