#!/bin/sh

# Default values (Fallback for Local Dev or Error)
PROVIDER="Local (Simulated)"
REGION="Local"
AZ="Unknown (Local/Error)"
INSTANCE_ID="Unknown (Local/Error)"
INSTANCE_TYPE="Unknown (Local/Error)"
ARCH=$(uname -m)

# Try to get AWS IMDSv2 Token (Timeout 2s to not block startup long)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s --connect-timeout 2)

if [ -n "$TOKEN" ]; then
    # We are on AWS if we got a token
    PROVIDER="AWS"
    
    # Fetch Metadata
    REGION=$(curl -f -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/placement/region | tr -d '\n\r"')
    AZ=$(curl -f -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/placement/availability-zone | tr -d '\n\r"')
    INSTANCE_ID=$(curl -f -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/instance-id | tr -d '\n\r"')
    INSTANCE_TYPE=$(curl -f -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/instance-type | tr -d '\n\r"')
    ARCH=$(curl -f -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/architecture | tr -d '\n\r"')
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
