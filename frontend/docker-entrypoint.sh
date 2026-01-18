#!/bin/sh

# Default values (Fallback for Local Dev or Error)
AZ="Unknown (Local/Error)"
INSTANCE_ID="Unknown (Local/Error)"
INSTANCE_TYPE="Unknown (Local/Error)"

# Try to get AWS IMDSv2 Token (Timeout 2s to not block startup long)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s --connect-timeout 2)

if [ -n "$TOKEN" ]; then
    # Fetch Metadata
    AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/placement/availability-zone)
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/instance-id)
    INSTANCE_TYPE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/instance-type)
fi

# Generate meta.json in Nginx root
cat <<EOF > /usr/share/nginx/html/meta.json
{
  "availabilityZone": "$AZ",
  "instanceId": "$INSTANCE_ID",
  "instanceType": "$INSTANCE_TYPE"
}
EOF

# Exec the main container command (Nginx)
exec "$@"
