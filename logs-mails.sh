#! /bin/bash

# 🐽 Get the absolute path of the script's directory in execution
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 🐏 Load environment variables from the .env file
if [ -f "$script_dir/.env" ]; then
  export $(cat "$script_dir/.env" | xargs)
fi

# 🐐 Get the current date in YMD format (year, month, day)
current_date=$(date +"%Y%m%d")

# 🐪 SendGrid credentials setup
api_key="$SENDGRID_API_KEY"
from_email="logs-mail_$current_date@$ENDPOINT"
to_email="$TO_EMAIL"
subject="Logs & Mails mantained $current_date"

# Crea un directorio para la fecha
mkdir -p /home/x3c2p7q7ry12/mail/arch/${current_date}

# Comprime todos los archivos que tenga la carpeta
tar -cf /home/x3c2p7q7ry12/mail/arch/${current_date}/${current_date}.tar.gz -P /home/x3c2p7q7ry12/mail/cur/*

sleep 10

echo $(cat "/home/x3c2p7q7ry12/mail/arch/${current_date}/${current_date}.tar.gz" | base64 -w 0)

exit 1

# 🦔 HTML content of the email with a basic template
html_body="
<!DOCTYPE html>
<html>
<head>
  <title>🔸🔸🔸🔸🔸🔸 Logs & Mails 🔸🔸🔸🔸🔸🔸 </title>
</head>
<body>
  <h1>Download files to storage</h1>
</body>
</html>
"

# 🦇 Create a temporary JSON file with the data
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
      "content": "$(cat "$/home/x3c2p7q7ry12/mail/arch/${current_date}/${current_date}.tar.gz" | base64 -w 0)",
      "filename": "${current_date}.tar.gz",
      "type": "application/gzip",
      "disposition": "attachment"
    }
  ]
}
EOF

# 🐻 Configure cURL request to send the email through SendGrid 🚀
curl -X "POST" "https://api.sendgrid.com/v3/mail/send" \
     -H "Authorization: Bearer $api_key" \
     -H "Content-Type: application/json" \
     -d "@$json_file"