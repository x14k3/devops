# CentOS yum

### yum常用命令

```
[root@zutuanxue ~]# yum clean all
如果有些时候你发现yum运行不太正常，这可能是yum缓存数据错误导致的，所以你需要将yum的缓存清除
查看软件包
[root@zutuanxue ~]# yum list

查看有哪些可用组
[root@zutuanxue ~]# yum grouplist
   
查看dhcp-server这个包的信息   
[root@zutuanxue ~]# yum info dhcp-server	

搜索dhcp-server这个软件包
[root@zutuanxue ~]# yum search dhcp-server
```

#### **阿里源**

[https://developer.aliyun.com/mirror/](https://developer.aliyun.com/mirror/ "https://developer.aliyun.com/mirror/")

```bash
# 备份Linux本地现有的yum仓库文件
cd /etc/yum.repos.d
mkdir backup
mv ./* backup/

# 下载新的仓库文件
## 这是第一个仓库
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
## 下载第二个epel仓库
wget -O /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo

# 其他(非阿里云ECS用户会出现出现 curl#6 - "Could not resolve host: mirrors.cloud.aliyuncs.com; Unknown error")
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo

# 清空之前的yum缓存，生成新缓存
yum clean all &&  yum makecache 
```

#### **本地源**

```bash
# 备份Linux本地现有的yum仓库文件
cd /etc/yum.repos.d
mkdir backup
mv ./* backup/

# 挂载镜像iso文件（要与操作系统版本一致）
## CentOS-7-x86_64-DVD-2003.iso 上传镜像至/opt目录
mkdir /media/cdrom 
mount -t iso9660 -o loop /opt/CentOS-7-x86_64-DVD-2009.iso /media/cdrom 

# 永久挂载
echo '/opt/CentOS-7-x86_64-DVD-2009.iso /media/cdrom iso9660 defaults,ro,loop 0 0' >> /etc/fstab
mount -a

# 创建一个新的yum源文件
cat <<EOF > /etc/yum.repos.d/local.repo
[local]
name=local
baseurl=file:///media/cdrom
gpgcheck=0
enabled=1
EOF

# 清空之前的yum缓存，生成新缓存
yum clean all &&  yum makecache
```

#### **局域网源**

*配置本地源*<br />安装2. nginx 部署

```bash
# 安装nginx
./configure \
--prefix=/data/nginx --with-http_addition_module --with-http_gunzip_module \
--with-http_gzip_static_module --with-http_degradation_module
make && make install

# 关闭防火墙和firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

# 修改nginx配置文件
----------------------------------------------------
server {
    listen       8080;
    server_name  localhost;
  
    location / {
        root   /opt/yumrepo;
        index  index.html index.htm;
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header REMOTE-HOST $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

----------------------------------------------------

# 启动nginx
/data/nginx/sbin/nginx -c /data/nginx/conf/nginx.conf -t
/data/nginx/sbin/nginx -c /data/nginx/conf/nginx.conf

```

*在客户端配置局域网yum源*

```bash
# 备份
cd /etc/yum.repos.d/
mkdir backup
mv ./* backup/

# 创建一个新的wlanyum源文件
cat <<EOF > /etc/yum.repos.d/wlanyum.repo
[wlanyum]
# 源名称
name=wlanyum
# 源基本地址
baseurl=http://192.168.130.138:8080
# 不启用gpg签名效验
gpgcheck=0
# 启用该yum源
enabled=1
EOF

# 清空之前的yum缓存，生成新缓存
yum clean all &&  yum makecache 
```

‍
