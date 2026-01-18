#!/bin/sh

# Default values (Fallback for Local Dev or Error)
PROVIDER="Localhost"
REGION="Unknown"
AZ="Unknown"
INSTANCE_ID="Unknown"
INSTANCE_TYPE="Unknown"
ARCH=$(uname -m) # Use container arch as fallback

# Try to get AWS IMDSv2 Token (Timeout 2s to not block startup long)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s --connect-timeout 2)

if [ -n "$TOKEN" ]; then
    # We are on AWS if we got a token
    PROVIDER="AWS"
    
    # Fetch Metadata
    REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/placement/region)
    AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/placement/availability-zone)
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/instance-id)
    INSTANCE_TYPE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/instance-type)
    ARCH=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/architecture)
fi

# Generate meta.json in Nginx root
cat <<EOF > /usr/share/nginx/html/meta.json
{
  "provider": "$PROVIDER",
  "region": "$REGION",
  "availabilityZone": "$AZ",
  "instanceId": "$INSTANCE_ID",
  "instanceType": "$INSTANCE_TYPE",
  "architecture": "$ARCH"
}
EOF

# Exec the main container command (Nginx)
exec "$@"
