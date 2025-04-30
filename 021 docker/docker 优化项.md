# docker 优化项

## **docker仓库改为阿里源**

```bash
mkdir -p /etc/docker
vim /etc/docker/daemon.json
-------------------------------------------------------------
{
  "registry-mirrors": ["https://tu2ax1rl.mirror.aliyuncs.com"],
  "insecure-registries": ["0.0.0.0"]
}
-------------------------------------------------------------
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## docker pull 使用代理

docker已换阿里源，某些冷门或较新镜像仍然会从docker.io进行下载，需要代理。

对于docker这种级别的应用，环境变量需要经由systemd传入。

```bash
mkdir /etc/systemd/system/docker.service.d
cat <<EOF >> /etc/systemd/system/docker.service.d/proxy.conf

# Add content below

[Service]
Environment="HTTP_PROXY=http://127.0.0.1:10809"
Environment="HTTPS_PROXY=http://127.0.0.1:10809"
Environment="NO_PROXY=localhost,127.0.0.1,.example.com"
EOF

systemctl daemon-reload
systemctl stop docker.socket
systemctl start docker.socket
```

## 容器使用宿主机的代理

```bash
#方法一： 直接在容器内使用（推荐
export ALL_PROXY='socks5://172.17.0.1:10808'
```

## 默认存储路径/var/lib/docker

```bash
# 修改docker默认运行目录 /data/docker
# 停止的docker相关服务:
systemctl stop docker
systemctl stop docker.socket
systemctl stop containerd
#在新选择的磁盘上创建docker使用目录，建议选择有50G以上空闲的磁盘
mkdir -p /data
# 把原来的docker目录移动到/data3:
mv /var/lib/docker /data
# 修改或创建docker配置文件: /etc/docker/daemon.json
vim /etc/docker/daemon.json
# 添加配置项:
root@doshell docker $ cat  /etc/docker/daemon.json 
{ 
    "insecure-registries": ["0.0.0.0/0"],
    "data-root": "/data/docker"
}
# 保存/etc/docker/daemon.json文件后重新启动docker服务:
systemctl start docker
# 执行这条命令docker相关的服务也都会启动了
# 检查下修改生效了没:
docker info -f '{{ .DockerRootDir}}'
# 如果输出的是新的路径就代表修改成功了,从这里也可以看出这个配置的官方名称叫 Docker Root Directory(Docker根目录)
```

## No swap limit support 解决

1. 编辑/etc/default/grub文件。在GRUB_CMDLINE_LINUX=" ",中并追加 cgroup_enable=memory swapaccount=1

    ```bash
    yang@master:~$ cat  /etc/default/grub
    # If you change this file, run 'update-grub' afterwards to update
    # /boot/grub/grub.cfg.
    # For full documentation of the options in this file, see:
    #   info -f grub -n 'Simple configuration'
     
    GRUB_DEFAULT=0
    GRUB_TIMEOUT_STYLE=hidden
    GRUB_TIMEOUT=0
    GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
    GRUB_CMDLINE_LINUX_DEFAULT="maybe-ubiquity"
    GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"

    注：如果GRUB_CMDLINE_LINUX=内有内容，切记不可删除，只需在后面追加cgroup_enable=memory swapaccount=1并用空格和前面的内容分隔开。
    ```

2. 保存、更新、重启服务器

    ```bash
    update-grub
    reboot
    ```
