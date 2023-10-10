#! /bin/bash

# 🍇 Get the absolute path of the script's directory in execution
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 🍈 Load environment variables from the .env file
if [ -f "$script_dir/.env" ]; then
  export $(cat "$script_dir/.env" | xargs)
fi

# 🍉 Get the current date in YMD format (year, month, day)
current_date=$(date +"%Y%m%d")

# 🍊 SendGrid credentials setup
api_key="$SENDGRID_API_KEY"
from_email="logs-mail_$current_date@$ENDPOINT"
to_email="$TO_EMAIL"
subject="Logs & Mails maintained $current_date"

# 🍋 Create a directory for the date
mkdir -p /home/x3c2p7q7ry12/mail/arch/${current_date}

# 🍌 Compress all files in the folder
tar -cf /home/x3c2p7q7ry12/mail/arch/${current_date}/${current_date}.tar.gz -P /home/x3c2p7q7ry12/mail/cur/*

echo '🦣 sleep 10 seconds to compress folder'
sleep 10

# 🍍 HTML content of the email with a basic template
html_body="
<!DOCTYPE html>
<html>
<head>
  <title>🔸🔸🔸🔸🔸🔸 Logs & Mails 🔸🔸🔸🔸🔸🔸 </title>
</head>
<body>
  <h1>📢 Download files to storage</h1>
</body>
</html>
"

# 🥭 Create a temporary JSON file with the data
json_file="/tmp/logs-mail-request.json"
cat <<EOF > "$json_file"
{
  "personalizations": [
    {
      "to": [
        {
          "email": "$to_email"
        }
      ],
      "subject": "$subject"
    }
  ],
  "from": {
    "email": "$from_email"
  },
  "content": [
    {
      "type": "text/html",
      "value": "$html_body"
    }
  ],
  "attachments": [
    {
      "content": "$(cat "/home/x3c2p7q7ry12/mail/arch/${current_date}/${current_date}.tar.gz" | base64 -w 0)",
      "filename": "${current_date}.tar.gz",
      "type": "application/gzip",
      "disposition": "attachment"
    }
  ]
}
EOF

echo '🐪 sleep 120 seconds to generate json content '
sleep 120
echo '🚀 script wakeup, request to send mail'

# 🍎 Configure cURL request to send the email through SendGrid 🚀
curl -X "POST" "https://api.sendgrid.com/v3/mail/send" \
     -H "Authorization: Bearer $api_key" \
     -H "Content-Type: application/json" \
     -d "@$json_file"