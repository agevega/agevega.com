#!/bin/bash
# Install Docker
dnf update -y
dnf install -y docker
service docker start
usermod -a -G docker ec2-user
chkconfig docker on

# Login to ECR
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${repository_url}

# Run Container
docker run -d --restart always -p 80:80 --name app ${repository_url}:latest
