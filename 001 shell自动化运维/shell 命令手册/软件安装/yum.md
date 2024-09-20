# yum

　　基于RPM的软件包管理器

　　**yum命令** 是在Fedora和RedHat以及SUSE中基于rpm的软件包管理器，它可以使系统管理人员交互和自动化地更新与管理RPM软件包，能够从指定的服务器自动下载RPM包并且安装，可以自动处理依赖性关系，并且一次安装所有依赖的软体包，无须繁琐地一次次下载、安装。

　　yum提供了查找、安装、删除某一个、一组甚至全部软件包的命令，而且命令简洁而又好记。

### 语法

```
yum(选项)(参数)
-h：显示帮助信息；
-y：对所有的提问都回答“yes”；
-c：指定配置文件；
-q：安静模式；
-v：详细模式；
-d：设置调试等级（0-10）；
-e：设置错误等级（0-10）；
-R：设置yum处理一个命令的最大等待时间；
-C：完全从缓存中运行，而不去下载或者更新任何头文件。
```

### 参数

```
install：安装rpm软件包；
update：更新rpm软件包；
check-update：检查是否有可用的更新rpm软件包；
remove：删除指定的rpm软件包；
list：显示软件包的信息；
search：检查软件包的信息；
info：显示指定的rpm软件包的描述信息和概要信息；
clean：清理yum过期的缓存；
shell：进入yum的shell提示符；
resolvedep：显示rpm软件包的依赖关系；
localinstall：安装本地的rpm软件包；
localupdate：显示本地rpm软件包进行更新；
deplist：显示rpm软件包的所有依赖关系；
provides：查询某个程序所在安装包。

```

### 实例

```bash
yum install              #全部安装
yum install package1     #安装指定的安装包package1
yum groupinsall group1   #安装程序组group1
yum update               #全部更新
yum update package1      #更新指定程序包package1
yum check-update         #检查可更新的程序
yum upgrade package1     #升级指定程序包package1
yum groupupdate group1   #升级程序组group1
# 检查 MySQL 是否已安装
yum list installed | grep mysql
yum list installed mysql*
yum info package1        #显示安装包信息package1
yum list                 #显示所有已经安装和可以安装的程序包
yum list package1        #显示指定程序包安装情况package1
yum groupinfo group1     #显示程序组group1信息yum search string 根据关键字string查找安装包

yum remove &#124; erase package1   #删除程序包package1
yum groupremove group1             #删除程序组group1
yum deplist package1               #查看程序package1依赖情况

yum clean packages       # 清除缓存目录下的软件包
yum clean headers        # 清除缓存目录下的 headers
yum clean oldheaders     # 清除缓存目录下旧的 headers
```

# 配置 YUM 源

## **阿里源**

　　[https://developer.aliyun.com/mirror/](https://developer.aliyun.com/mirror/ "https://developer.aliyun.com/mirror/")

```bash
# 备份Linux本地现有的yum仓库文件
cd /etc/yum.repos.d
mkdir backup
mv ./* backup/

# 下载新的仓库文件
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo

curl -o  /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
curl -o  /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo

# 其他(非阿里云ECS用户会出现出现 curl#6 - "Could not resolve host: mirrors.cloud.aliyuncs.com; Unknown error")
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/*.repo

# 清空之前的yum缓存，生成新缓存
yum clean all &&  yum makecache 
```

## **本地源**

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

## **局域网源**

　　*配置本地源*
nginx 部署

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

# 通过yum命令只下载rpm包不安装

　　经常遇到服务器没有网络的情况下部署环境，或者创建自己的 yum 仓库等。每次都是在网上搜搜搜，都是五花八门，自己整理了下自己用到的以下三种方式，这里没有太多废话，只是如何安装并示例经常用到的方式，如果还需要更多参数 ，可以通过 --help 查看手册：

## 方法一：yumdownloader

　　如果只想通过 yum 下载软件的软件包，但是不需要进行安装的话，可以使用 yumdownloader 命令；   yumdownloader 命令在软件包 yum-utils 里面。

```
# yum install yum-utils -y
```

　　常用参数说明：

```
--destdir 指定下载的软件包存放路径
--resolve 解决依赖关系并下载所需的包
```

　　示例：

```
# yumdownloader --destdir=/tmp --resolve httpd
```

## 方法二：yum --downloadonly

　　yum命令的参数有很多，其中就有只是下载而不需要安装的命令，并且也会自动解决依赖；通常和 --downloaddir 参数一起使用。

　　示例：

```
# yum install --downloadonly --downloaddir=/tmp/ vsftpd

# yum reinstall --downloadonly --downloaddir=/tmp/ vsftpd
```

　　说明：如果该服务器已经安装了需要下载的软件包，那么使用 install下载就不行，可以使用reinstall下载。 放心（不会真的安装和重新安装，因为后面加了 --downloadonly，表明只是下载。

　　如果提示没有--downloadonly选项则需要安装yum-plugin-downloadonly软件包；

```
# yum install yum-plugin-downloadonly
```

## 方法三：reposync

　　该命令更加强大，可以将远端yum仓库里面的包全部下载到本地。这样构建自己的yum仓库，就不会遇到网络经常更新包而头痛的事情了。 该命令也是来自与 yum-utils 里面。

```
# yum install yum-utils -y
```

　　常用参数说明：

```
-r    指定已经本地已经配置的 yum 仓库的 repo源的名称。
-p    指定下载的路径
```

　　示例：

```
# reposync -r epel -p /opt/local_epel
```

　　‍

# createrepo - 创建YUM仓库

```
createrepo [选项] <目录>
```

　　​`createrepo`​是一个程序，它从一组RPM创建一个RPM元数据存储库，即YUM仓库。

## 选项

```
-u  --baseurl <url>
# 指定Base URL的地址

-o --outputdir <url>
# 指定元数据的输出位置

-x --excludes <packages>
# 指定在形成元数据时需要排除的包

-i --pkglist <filename>
# 指定一个文件，该文件内的包信息将被包含在即将生成的元数据中，格式为每个包信息独占一行，不含通配符、正则，以及范围表达式。

-n --includepkg
# 通过命令行指定要纳入本地库中的包信息，需要提供URL或本地路径。

-q --quiet
# 安静模式执行操作，不输出任何信息。

-g --groupfile <groupfile>
# 指定本地软件仓库的组划分，示例：createrepo -g comps.xml /path/to/rpms
# 注意：组文件需要和rpm包放置于同一路径下。

-v --verbose
# 输出详细信息。

-c --cachedir <path>
# 指定一个目录，用作存放软件仓库中软件包的校验和信息。
# 当createrepo在未发生明显改变的相同仓库文件上持续多次运行时，指定cachedir会明显提高其性能。

--basedir
# Basedir为repodata中目录的路径，默认为当前工作目录。

--update
# 如果元数据已经存在，且软件仓库中只有部分软件发生了改变或增减，
# 则可用update参数直接对原有元数据进行升级，效率比重新分析rpm包依赖并生成新的元数据要高很多。

--skip-stat
# 跳过--update上的stat()调用，假设如果文件名相同，则文件仍然相同(仅在您相当信任或容易受骗时使用此方法)。

--update-md-path
# 从这个路径使用现有的repodata来升级。

-C --checkts
# 不要生成回购元数据，如果它们的时间戳比rpm更新。如果您碰巧开启了该选项，则此选项将再次大幅减少处理时间一个未修改的回购，但它(目前)与——split选项互斥。注意:当包从repo中删除时，这个命令不会注意到。使用——update来处理这个。

--split
# 在拆分媒体模式下运行。与其传递单个目录，不如获取一组对应于媒体集中不同卷的目录。

-p --pretty
# 以整洁的格式输出xml文件。

--version
# 输出版本。

-h --help
# 显示帮助菜单。

-d --database
# 该选项指定使用SQLite来存储生成的元数据，默认项。

--no-database
# 不要在存储库中生成sqlite数据库。

-S --skip-symlinks
# 忽略包的符号链接

-s --checksum
# 选择repmed .xml中使用的校验和类型以及元数据中的包。默认值现在是“sha256”(如果python有hashlib)。旧的默认值是“sha”，它实际上是“sha1”，但是显式使用“sha1”在旧版本(3.0.x)的yum上不起作用，您需要指定“sha”。

--profile
# 输出基于时间的分析信息。

--changelog-limit CHANGELOG_LIMIT
# 只将每个rpm中的最后N个变更日志条目导入元数据

--unique-md-filenames
# 在元数据文件名中包含文件的校验和，有助于HTTP缓存(默认)

--simple-md-filenames
# 不要在元数据文件名中包含文件的校验和。

--retain-old-md
# 保留旧repodata的最新(按时间戳)N个副本(这样使用旧repodata .xml文件的客户端仍然可以访问它)。默认为0。

--distro
指定发行版标签。可以多次指定。可选语法，指定cpeid(http://cpe.mitre.org/)——distro=cpeid,distrotag

--content
# 指定关于存储库内容的关键字/标记。可以多次指定。

--repo
# 指定关于存储库本身的关键字/标签。可以多次指定。

--revision
# 存储库修订的任意字符串。

--deltas
# 告诉createrepo生成增量数据和增量元数据

--oldpackagedirs PATH
# 寻找更老的PKGS来对抗的路径。可以指定多次吗

--num-deltas int
# 要进行增量处理的旧版本的数量。默认为1

--read-pkgs-list READ_PKGS_LIST
# 使用——update将路径输出到PKGS实际读起来很有用

--max-delta-rpm-size MAX_DELTA_RPM_SIZE
# 要运行deltarpm的RPM的最大大小(以字节为单位)

--workers WORKERS
# 为读取RPMS而生成的工作线程数

--compress-type
# 指定要使用的压缩方法:compat(默认)，xz(可能不可用)，gz, bz2。

```

## 返回值

　　返回状态为成功除非给出了非法选项或非法参数。

## 例子

```
# 生成带有groups文件的存储库。注意groups文件应该和rpm包在同一个目录下(即/path/to/rpms/comps.xml)。
createrepo -g comps.xml /path/to/rpms
```
