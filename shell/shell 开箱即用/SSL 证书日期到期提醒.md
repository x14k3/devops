
```bash
#!/bin/bash

cert_file="/etc/nginx/ssl/xxxxx.xyz.pem"

expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)
expiry_timestamp=$(date -d "$expiry_date" +%s)
current_timestamp=$(date +%s)
days_left=$(( (expiry_timestamp - current_timestamp) / 86400 ))

if [[ $days_left -le 5 ]];then
echo "证书文件: $cert_file"
echo "过期时间: $expiry_date"
echo "剩余天数: $days_left"

fi
```