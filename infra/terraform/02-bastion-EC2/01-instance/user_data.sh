#!/bin/bash
dnf update -y
dnf install -y docker
service docker start
usermod -a -G docker ec2-user
chkconfig docker on
