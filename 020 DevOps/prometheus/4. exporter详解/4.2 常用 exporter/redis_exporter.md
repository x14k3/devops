# redis_exporter

## 部署redis\_exporter

　　这里使用二进制部署启动Redis以及Redis Exporter，具体安装细节就不做重复了

```
mkdir /data/redis_exporter
sudo wget https://github.com/oliver006/redis_exporter/releases/download/v1.3.2/redis_exporter-v1.3.2.linux-amd64.tar.gz
tar -xvf  redis_exporter-v1.3.2.linux-amd64.tar.gz
mv redis_exporter-v1.3.2.linux-amd64 /data/redis_exporter

wget  https://grafana.com/api/dashboards/763/revisions/1/download

## 无密码
./redis_exporter redis//172.26.42.229:6379
## 有密码
./redis_exporter -redis.addr 172.26.42.229:6379  -redis.password 123456

cat > /etc/systemd/system/redis_exporter.service <<EOF

[Unit]
Description=redis_exporter
After=network.target

[Service]
Type=simple
User=prometheus
ExecStart=/data/redis_exporter/redis_exporter -redis.addr 172.26.42.229:6379  -redis.password 123456
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


- job_name: redis
static_configs:
  - targets: ['1172.26.42.229:9121']
    labels:
      instance: redis120
```

　　‍

　　‍
