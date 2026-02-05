#!/bin/bash
# Install Docker
dnf update -y
dnf install -y docker
service docker start
usermod -a -G docker ec2-user
chkconfig docker on

# Login to ECR
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${repository_url}

# Fetch Image Tag from SSM
IMAGE_TAG=$(aws ssm get-parameter --name "${ssm_image_tag_name}" --region ${aws_region} --query "Parameter.Value" --output text)

# Run Container
docker run -d --restart always -p 80:80 -e DEPLOYMENT_VERSION=$IMAGE_TAG --name app ${repository_url}:$IMAGE_TAG
