# Grafana使用

Prometheus UI提供了快速验证PromQL以及临时可视化支持的能力，而在大多数场景下引入监控系统通常还需要构建可以长期使用的监控数据可视化面板（Dashboard）。这时用户可以考虑使用第三方的可视化工具如Grafana，Grafana是一个开源的可视化平台，并且提供了对Prometheus的完整支持。

# **部署Grafana**

```bash
wget https://dl.grafana.com/oss/release/grafana-10.0.3.linux-amd64.tar.gz
tar xf grafana-10.0.3.linux-amd64.tar.gz
cd grafana-10.0.3/bin
nohup /opt/grafana-10.0.3/bin/grafana-server web >>/opt/grafana-10.0.3/grafina.log 2>&1 &

#创建 grafana 启动脚本
cat <<EOF >> /usr/lib/systemd/system/grafana.service 
[Unit]
Description=grafana
Documentation=https://dl.grafana.com/
After=network.target
 
[Service]
Type=simple
User=prometheus
ExecStart=/data/grafana/bin/grafana-server web
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
```

通过`http://localhost:3000`​就可以进入到Grafana的界面中，默认情况下使用账户admin/admin进行登录。在Grafana首页中显示默认的使用向导，包括：安装、添加数据源、创建Dashboard、邀请成员、以及安装应用和插件等主要流程:

‍
