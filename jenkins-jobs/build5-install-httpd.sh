#!/bin/bash
set -e

echo "=== Build 5: Installing HTTPD on all EC2 Instances ==="

REGION="us-east-1"
INSTANCE_IDS_FILE="${WORKSPACE}/instance_ids.txt"
SSH_KEY="/home/jenkins/.ssh/id_rsa"

if [ ! -f "$INSTANCE_IDS_FILE" ]; then
    echo "ERROR: Instance IDs file not found: $INSTANCE_IDS_FILE"
    exit 1
fi

echo "Reading instance IDs..."
INSTANCE_IDS=$(cat "$INSTANCE_IDS_FILE")

echo "Fetching Public IP addresses..."
PUBLIC_IPS=$(aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids $INSTANCE_IDS \
    --query 'Reservations[].Instances[].PublicIpAddress' \
    --output text)

echo ""
echo "Found Public IPs:"
echo "$PUBLIC_IPS"
echo ""

for IP in $PUBLIC_IPS; do
    echo "------ Installing HTTPD on $IP ------"

    ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" ec2-user@$IP << 'EOSSH'
        sudo yum install -y httpd
        sudo systemctl start httpd
        sudo systemctl enable httpd

        HOSTNAME_VALUE=$(hostname)
        PRIVATE_IP=$(hostname -I | awk '{print $1}')
        PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

        sudo bash -c "cat > /var/www/html/index.html <<EOF2
<html>
    <body>
        <h1 style='color: green;'>Welcome to WebServer - Jenkins Deployment</h1>
        <h2>Hostname: $HOSTNAME_VALUE</h2>
        <h2>Private IP: $PRIVATE_IP</h2>
        <h2>Public IP: $PUBLIC_IP</h2>
    </body>
</html>
EOF2"
EOSSH

    echo "HTTPD installed + Hostname/IP displayed on $IP"
done

echo ""
echo "=== Build 5 completed successfully! ==="
