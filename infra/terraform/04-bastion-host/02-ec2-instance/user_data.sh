#!/bin/bash
dnf update -y
dnf install -y docker
dnf install -y git
dnf install -y python3.14 python3.14-pip

# Iniciar Docker y configurar para iniciar al arrancar
service docker start
usermod -a -G docker ec2-user
chkconfig docker on

# Instalación de Certbot y plugin Route53 para AL2023 (Usando Python 3.14)
python3.14 -m venv /opt/certbot/
/opt/certbot/bin/pip install --upgrade pip
/opt/certbot/bin/pip install certbot certbot-dns-route53
ln -s /opt/certbot/bin/certbot /usr/bin/certbot
