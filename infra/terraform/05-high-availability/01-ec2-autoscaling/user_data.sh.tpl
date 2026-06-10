#!/bin/bash
# Install Docker
dnf update -y
dnf install -y docker
service docker start
usermod -a -G docker ec2-user
chkconfig docker on

# Login to ECR (one login covers both repos in the same registry)
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${repository_url_landing}

# Fetch Image Tag from SSM (shared across all sites)
IMAGE_TAG=$(aws ssm get-parameter --name "${ssm_image_tag_name}" --region ${aws_region} --query "Parameter.Value" --output text)

# Run Landing Container — host:443 -> container:8443 
docker run -d --restart always -p 443:8443 -e DEPLOYMENT_VERSION=$IMAGE_TAG --name landing ${repository_url_landing}:$IMAGE_TAG

# Run Academy Container — host:8443 -> container:8443
docker run -d --restart always -p 8443:8443 -e DEPLOYMENT_VERSION=$IMAGE_TAG --name academy ${repository_url_academy}:$IMAGE_TAG
