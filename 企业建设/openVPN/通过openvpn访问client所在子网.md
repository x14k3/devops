我们使用OpenVPN组网，目标让 **client02（192.168.133.133）能够访问 client01（192.168.10.135）所在子网的所有服务器。这意味着我们需要在OpenVPN服务器上配置路由，使得client02的流量能够通过VPN隧道到达client01所在的局域网（LAN）。

修改 `/etc/openvpn/server/server.conf`：
```bash
push "route 192.168.10.0 255.255.255.0"  # 推送client01子网路由
```

重启服务
```bash
sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server
```


配置client01（子网网关）
```bash
# 在client01上启用IP转发
sudo sysctl -w net.ipv4.ip_forward=1
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf

# 配置NAT（关键步骤）
# 假设eth0是client01连接局域网的网卡
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
# 或（上面的命令可能不管用）
sudo iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -d 192.168.10.0/24 -o eth0 -j SNAT --to-source 192.168.10.135
# 持久化规则（根据系统选择工具如iptables-persistent）
```

验证访问
在client02上测试：
```bash
ping 192.168.10.100  # 替换为client01子网中的服务器IP
```

