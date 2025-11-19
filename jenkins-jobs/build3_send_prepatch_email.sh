#!/bin/bash
set -euo pipefail

TO_EMAIL="m.ashish2017@gmail.com"
FROM_EMAIL="m.ashish2017@gmail.com"
SUBJECT="PRE-PATCHING APPROVAL REQUIRED"
BODY="Patching will start soon. Click this link to approve: https://your-jenkins-url/job/build4-patching/build"

SMTP_USER="$SES_USERNAME"
SMTP_PASS="$SES_PASSWORD"

cat <<EOF > send_mail.py
import smtplib
from email.mime.text import MIMEText

to_addr = "$TO_EMAIL"
from_addr = "$FROM_EMAIL"
subject = "$SUBJECT"
body = "$BODY"

msg = MIMEText(body)
msg["Subject"] = subject
msg["From"] = from_addr
msg["To"] = to_addr

smtp = smtplib.SMTP("email-smtp.us-east-1.amazonaws.com", 587)
smtp.starttls()
smtp.login("$SMTP_USER", "$SMTP_PASS")
smtp.sendmail(from_addr, [to_addr], msg.as_string())
smtp.quit()
EOF

python3 send_mail.py
echo "[INFO] Email sent successfully via Python SMTP."
