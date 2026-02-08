#!/bin/bash

# Configuration
DOMAIN="agevega.com"
EMAIL="admin@agevega.com" # Replace with valid email if needed

# 1. Install Certbot y asegurar el plugin solo si faltan
if [ ! -f "/opt/certbot/bin/certbot" ]; then
    echo "Entorno Certbot no encontrado en /opt/certbot. Instalando..."
    sudo python3.13 -m venv /opt/certbot/
    sudo /opt/certbot/bin/pip install --upgrade pip
    sudo /opt/certbot/bin/pip install certbot certbot-dns-route53
    sudo ln -sf /opt/certbot/bin/certbot /usr/bin/certbot
# Si existe el entorno, verificamos que el plugin de Route53 esté cargado
elif ! certbot plugins | grep -q "dns-route53"; then
    echo "Certbot detectado pero falta el plugin Route53. Instalando..."
    sudo /opt/certbot/bin/pip install certbot-dns-route53
else
    echo "Certbot y plugin Route53 ya están listos en /opt/certbot."
fi

# 2. Stop existing frontend
echo "Stopping any running frontend container..."
sudo docker stop frontend || true

# 3. Request Certificate (Using Route53)
echo "Requesting certificate for $DOMAIN and www.$DOMAIN using Route53..."
sudo certbot certonly --dns-route53 \
  -d "$DOMAIN" -d "www.$DOMAIN" -d "dev.$DOMAIN" \
  --email "$EMAIL" \
  --agree-tos \
  --non-interactive \
  --keep-until-expiring

echo "------------------------------------------------"
echo "Certificate setup finished."
echo "Certificates location: /etc/letsencrypt/live/$DOMAIN/"
