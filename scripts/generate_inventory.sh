#!/bin/bash
set -euo pipefail

WORKSPACE="${WORKSPACE:-$(pwd)}"
INST_FILE="$WORKSPACE/instance_ids.txt"
OUT_FILE="$WORKSPACE/ansible/inventory/inventory.ini"
REGION="us-east-1"

if [ ! -f "$INST_FILE" ]; then
  echo "[ERROR] instance_ids.txt not found. Run Build 1 first."
  exit 1
fi

mkdir -p "$(dirname "$OUT_FILE")"
echo "[web]" > "$OUT_FILE"

while read -r IID; do
  [ -z "$IID" ] && continue

  IP=$(aws ec2 describe-instances \
    --instance-ids "$IID" \
    --region "$REGION" \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)

  if [ "$IP" = "None" ] || [ -z "$IP" ]; then
    echo "[WARN] No private IP for $IID"
    continue
  fi

  echo "$IP ansible_user=ec2-user ansible_ssh_private_key_file=/home/jenkins/.ssh/id_rsa" >> "$OUT_FILE"
done < "$INST_FILE"

echo "[INFO] Inventory generated at: $OUT_FILE"
