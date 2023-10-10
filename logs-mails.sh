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

# Comprime los archivos por fecha
for fecha in $(find /home/x3c2p7q7ry12/mail/cur -type f -mtime -1 -printf "%Y-%m-%d\n"); do
  # Crea un directorio para la fecha
  mkdir -p /home/x3c2p7q7ry12/mail/arch/${fecha}

  # Comprime los archivos de la fecha
  tar -cf /home/x3c2p7q7ry12/mail/arch/${fecha}.tar.gz /home/x3c2p7q7ry12/mail/cur/${fecha}/*
done

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
      "content": "$(cat "$/home/x3c2p7q7ry12/mail/arch/${fecha}.tar.gz" | base64 -w 0)",
      "filename": "${fecha}.tar.gz",
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