#!/bin/bash
set -euo pipefail

INST_FILE="${WORKSPACE}/instance_ids.txt"
INVENTORY="${WORKSPACE}/ansible/inventory/hosts"

if [ ! -f "$INST_FILE" ]; then
  echo "[ERROR] instance_ids.txt not found. Run Build 1."
  exit 1
fi

echo "[INFO] Generating dynamic Ansible inventory..."

echo "[aws]" > "$INVENTORY"

for IID in $(cat "$INST_FILE"); do
  IP=$(aws ec2 describe-instances \
        --instance-ids "$IID" \
        --query "Reservations[0].Instances[0].PrivateIpAddress" \
        --output text \
        --region us-east-1)

  echo "$IP ansible_user=ec2-user ansible_ssh_private_key_file=/home/jenkins/.ssh/id_rsa" >> "$INVENTORY"
done

echo "[INFO] Inventory created at $INVENTORY"
cat "$INVENTORY"
