#! /bin/bash

# 🍏 Get the current directory
current_dir=$(pwd)

# 🍊 List all files in the directory and sort them by modification date
files=($(find "$current_dir" -type f -exec stat --format="%Y %n" {} \; | sort -n | awk '{print $2}'))

# 🍇 Count the total number of files
total_files=${#files[@]}

# 🍐 Get the name of the first file
first_file=${files[0]}

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
ls -lah /home/x3c2p7q7ry12/mail/arch/${current_date}
sleep 10

# 🍍 HTML content of the email with a basic template
html_body="
<!DOCTYPE html>
<html>
<head>
  <title>🔸🔸🔸🔸🔸🔸 Logs & Mails 🔸🔸🔸🔸🔸🔸 </title>
</head>
<body>
  <h1>📢 Descarga los archivos y respaldalos en una memoria</h1>
  <p><strong>Total archivos:</strong> $total_files</p>
  <p><strong>Primer archivo:</strong> $first_file</p>
  <p><strong>Lista de los primeros 25 archivos:</strong></p>
  <ul>
  "
for ((i=0; i<25; i++)); do
    html_body+="    <li>${files[$i]}</li>"
done
html_body+="
  </ul>
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

echo 'listando la data en base 64 '
echo "$(cat "/home/x3c2p7q7ry12/mail/arch/${current_date}/${current_date}.tar.gz" | base64 -w 0)"
echo "------------"

echo '🐪 sleep 120 seconds to generate json content '
sleep 120
echo '🚀 script wakeup, request to send mail'

# 🍎 Configure cURL request to send the email through SendGrid 🚀
curl -X "POST" "https://api.sendgrid.com/v3/mail/send" \
     -H "Authorization: Bearer $api_key" \
     -H "Content-Type: application/json" \
     -d "@$json_file" >> archivo-respuesta.txt