# process_exporter

‍

### 1. Process Exporter简介

在Prometheus中，可以借助process-exporter用以检测所选进程的状态信息。

用法:

```bash
process-exporter [options] -config.path filename.yml
```

若选择监控的进城并对其进行分组，可以使用命令行参数或者`yaml配置文件`​。推荐使用`-config.path`​指定配置文件路径。

详细.yaml配置文件格式及规则参考https://github.com/ncabatoff/process-exporter

​`vim /opt/process-exporter-0.7.5.linux-amd64/process-conf.yaml`​

```yaml
# 若监控主机上所有进程
process_names:
  - name: "{{.Comm}}"
    cmdline:
    - '.+'
```

```yaml
# 若监控主机上某个进程
process_names:
    - name: "137.30-zcopy"
      cmdline:
      - 'zcopy'
    - name: "137.30-dmserver"
      cmdline:
      - 'dmserver'
```

可用的模板变量如下

```bash
{{.Comm}}           包含原始可执行文件的基本名称，即 /proc/<pid>/stat
{{.ExeBase}}        包含可执行文件的基本名称
{{.ExeFull}}        包含可执行文件的标准路径
{{.Username}}       包含有效用户的用户名
{{.Matches}}        包含所有由于应用cmdline正则表达式而产生的匹配项
{{.PID}}            包含过程的PID。请注意，使用PID意味着该组将仅包含一个进程
{{.StartTime}}      包含过程的开始时间。与PID结合使用时，这很有用，因为PID会随着时间的推移而被重用
```

> 不建议使用PID或StartTime

### 2. 安装Process Exporter

[process-exporter GibHUB地址](https://github.com/ncabatoff/process-exporter)  
[process-exporter 下载地址](https://github.com/ncabatoff/process-exporter/releases/download/v0.7.5/process-exporter-0.7.5.linux-amd64.tar.gz)

```bash
# 下载
wget https://github.com/ncabatoff/process-exporter/releases/download/v0.7.5/process-exporter-0.7.5.linux-amd64.tar.gz
```

```bash
# 解压并安装
tar -zxvf process-exporter-0.7.5.linux-amd64.tar.gz -C /usr/local
# 重命名
mv process-exporter-0.7.5.linux-amd64/ process_exporter
```

注册到系统服务

```bash
cat << EOF >> /etc/systemd/system/process_exporter.service 
[Unit]
Description=process_exporter
Documentation=https://github.com/ncabatoff/process-exporter
After=network.target
 
[Service]
Type=simple
ExecStart=/usr/local/process_exporter/process-exporter -config.path=/usr/local/process_exporter/process-conf.yaml
Restart=always
 
[Install]
WantedBy=multi-user.target
EOF
```

加载并开机自启

```bash
systemctl daemon-reload 
systemctl enable process_exporter
systemctl start process_exporter
```

启动process exporter后查看metric信息

http://192.168.137.30:9256/metrics

‍

## 3. grafana出图

process-exporter对应的dashboard为：[https://grafana.com/grafana/dashboards/249](https://grafana.com/grafana/dashboards/249)
