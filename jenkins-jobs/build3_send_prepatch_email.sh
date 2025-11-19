#!/bin/bash
set -euo pipefail

TO_EMAIL="demofortest1@fusionnex.net"
FROM_EMAIL="demofortest1@fusionnex.net"
SUBJECT="PRE-PATCHING APPROVAL REQUIRED"
BODY="Patching will start soon. Click this link to approve: https://your-jenkins-url/job/build4-patching/build"

SMTP_HOST="email-smtp.us-east-1.amazonaws.com"
SMTP_PORT="587"

# Jenkins provides these from credentials
SMTP_USER="$SES_USERNAME"
SMTP_PASS="$SES_PASSWORD"

sendEmail -f "$FROM_EMAIL" \
          -t "$TO_EMAIL" \
          -u "$SUBJECT" \
          -m "$BODY" \
          -s "$SMTP_HOST:$SMTP_PORT" \
          -xu "$SMTP_USER" \
          -xp "$SMTP_PASS" \
          -o tls=auto \
          -o ssl=auto \
          -o tls_version=TLSv1_2 \
          -o message-content-type=text


echo "[INFO] Email sent successfully."

