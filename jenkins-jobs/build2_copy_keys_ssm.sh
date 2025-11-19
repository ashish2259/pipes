#!/bin/bash
set -euo pipefail

REGION="us-east-1"
PUBKEY_PATH="/home/jenkins/.ssh/id_rsa.pub"

WORKSPACE="${WORKSPACE:-$(pwd)}"
INST_FILE="$WORKSPACE/instance_ids.txt"

if [ ! -f "$INST_FILE" ]; then
  echo "[ERROR] instance_ids.txt not found. Run Build 1 first."
  exit 1
fi

if [ ! -f "$PUBKEY_PATH" ]; then
  echo "[ERROR] Public key not found at $PUBKEY_PATH"
  exit 1
fi

echo "[INFO] Reading public key..."
PUBKEY=$(cat "$PUBKEY_PATH" | sed 's/"/\\"/g')

SSM_CMD=$(cat <<EOF
mkdir -p /home/ec2-user/.ssh
echo "$PUBKEY" >> /home/ec2-user/.ssh/authorized_keys
chmod 600 /home/ec2-user/.ssh/authorized_keys
chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
EOF
)

echo "[INFO] Sending SSM command to all instances..."

CMDID=$(aws ssm send-command \
  --region "$REGION" \
  --instance-ids $(cat "$INST_FILE" | tr '\n' ' ') \
  --document-name "AWS-RunShellScript" \
  --comment "Inject Jenkins SSH Key" \
  --parameters commands=["$SSM_CMD"] \
  --query "Command.CommandId" \
  --output text)

echo "[INFO] SSM Command ID: $CMDID"
echo "[INFO] Waiting 5 seconds before checking status..."
sleep 5

for IID in $(cat "$INST_FILE"); do
  echo "---- Instance: $IID ----"
  aws ssm list-command-invocations \
    --region "$REGION" \
    --command-id "$CMDID" \
    --instance-id "$IID" \
    --details \
    --output table || true
done

echo "[INFO] Build 2 completed."
