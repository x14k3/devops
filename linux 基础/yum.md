#command/yum

# 源码包
安装一个源码包，是需要我们自己把**源代码编译成二进制的可执行文件**。使用源码包的好处除了可以自定义修改源代码外还可以定制相关的功能，因为源码包在编译的时候是可以附加额外的选项的。

```bash
yum install gcc gcc-c++ make automake
make && make install
```

# RPM
RPM包是**预先在linux机器上编译好并打包好的文件，安装起来非常快捷**。但是也有一些缺点，比如**安装的环境必须与编译时的环境一致或者相当**；包与包之间存在着相互依赖的情况。

```bash
rpm -qa                        # 查看所有已经安装的包 
rpm -qi pkg_name       # 查看已安装包的详细信息，例如安装时间 
rpm -qf file_name        # 查看一个文件属于哪个rpm 包 
rpm -ql pkg_name       # 查看已安装的包里面有哪些文件 
rpm -qpl pkg_name     # 查看一个RPM包里有哪些文件 
rpm -Uvh pkg_name   # 升级rpm包 
rpm -ivh pkg_name     # 安装所有指定的包，通常会保留原包，-v 显示安装过程
rpm -ivh --nodeps      # 忽略依赖包安装
rpm -ivh --nodeps --force # 强制安装
rpm -Fvh pkg_name   # 只安装比当前版本更高的包
rpm -e pkg_name       # 正常卸载软件包
rpm -e --nodeps         # 强力卸载rpm包

```

# YUM
Yum(全称为 Yellow dogUpdater, Modified)是一个在Fedora和RedHat以及CentOS中的Shell前端软件包管理器。基于RPM包管理，能够从指定的服务器**自动下载RPM包并且安装，可以自动处理依赖性关系**，yum提供了查找、安装、删除某一个、一组甚至全部软件包的命令，而且命令简洁而又好记。

```bash
yum search php       # 使用YUM查找软件包
yum list php             # 列出所有可安装的软件包
yum list updates      # 列出所有可更新的软件包
yum list installed     # 列出所有已安装的软件包
yum check-update   # 检查可更新的rpm包
yum update             # 更新所有软件命令;
yum update PACKAGE_NAME  # 更新具体的yum包
yum remove            # 卸载yum包装
yum install --downloadonly --downloaddir=/tmp package-name # 只下载不安装
yum clearn all         # 清除暂存中旧的rpm头文件和包文件
yum history            # 显示yum历史 
yum repolist           # 显示已启用的yum存储库的列表
yum info PACKAGE_NAME # 显示yum包的信息
yum localinstall --nogpgcheck PACKAGE_NAME # 在本地寻找依赖，离线安装。--nogpgcheck 参数用来禁止检查gpg签名

yum -y install yum-utils
yum-config-manager
```


## 配置yum源

### 阿里源
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




### 本地源
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





### 局域网yum源
==*配置本地源*==
[[nginx 部署]]  
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

==*在客户端配置局域网yum源*==
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

 

# DNF

DNF代表Dandified YUM是基于RPM的Linux发行版的软件包管理器。它用于在Fedora / RHEL / CentOS操作系统中安装，更新和删除软件包。 它是Fedora 22，CentOS8和RHEL8的默认软件包管理器。 DNF是YUM的下一代版本，并打算在基于RPM的系统中替代YUM。 DNF功能强大且具有健壮的特征。DNF使维护软件包组变得容易，并且能够自动解决依赖性问题。

```bash
yum install epel-release -y
yum install dnf

# 已安装包的列表
dnf list installed
# 查找与安装软件包
dnf search nginx
# 安装httpd包命令
dnf install nginx
# 重新安装软件nginx
dnf reinstall nginx
# 查看nginx包的详细信息
dnf info nginx
# 检查系统安装包更新
dnf check-update
# 更新所有安装包
dnf update
# 更新nginx
dnf update nginx
# 卸载nginx
dnf remove nginx
# 去掉不需要的依赖包
dnf autoremove
# 清除所有缓存
dnf clean all
```

# APT

**debian 11.x (bullseye)**

编辑/etc/apt/sources.list文件(需要使用sudo), 在文件最前面添加以下条目(操作前请做好相应备份)

```
deb https://mirrors.aliyun.com/debian/ bullseye main non-free contrib
deb-src https://mirrors.aliyun.com/debian/ bullseye main non-free contrib
deb https://mirrors.aliyun.com/debian-security/ bullseye-security main
deb-src https://mirrors.aliyun.com/debian-security/ bullseye-security main
deb https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
deb-src https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
deb https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib
deb-src https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib
```

`apt-get update`