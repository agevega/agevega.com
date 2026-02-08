#!/bin/bash
dnf update -y
dnf install -y docker
dnf install -y git
dnf install -y certbot
dnf install -y python3-certbot-dns-route53
service docker start
usermod -a -G docker ec2-user
chkconfig docker on
