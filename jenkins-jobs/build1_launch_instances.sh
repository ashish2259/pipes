#!/bin/bash
set -euo pipefail

REGION="us-east-1"
LAUNCH_TEMPLATE_ID="lt-0795ff7fe13a87132"
COUNT=5

WORKSPACE="${WORKSPACE:-$(pwd)}"
OUTFILE="$WORKSPACE/instance_ids.txt"

echo "[INFO] Launching $COUNT EC2 instances using Launch Template: $LAUNCH_TEMPLATE_ID"

# Remove old file if exists
rm -f "$OUTFILE"

for i in $(seq 1 $COUNT); do
  NAME="WebServer-$i"

  IID=$(aws ec2 run-instances \
    --region "$REGION" \
    --launch-template LaunchTemplateId="$LAUNCH_TEMPLATE_ID" \
    --count 1 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAME},{Key=ManagedBy,Value=Jenkins},{Key=Environment,Value=Production}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

  echo "$IID" >> "$OUTFILE"
  echo "[INFO] Launched $NAME : $IID"
done

echo "[INFO] Waiting for instances to enter 'running' state..."
aws ec2 wait instance-running --region "$REGION" --instance-ids $(tr '\n' ' ' < "$OUTFILE")
echo "[INFO] All instances are running. Saved to $OUTFILE"

