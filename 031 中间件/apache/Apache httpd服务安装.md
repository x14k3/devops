# Apache httpd服务安装

## `httpd`​安装

###  二进制程序安装

```bash
# 查询RPM包信息
rpm -qi httpd-2.4.6-67.el7.centos.6.x86_64.rpm

# 安装RPM包
rpm -ivh httpd-2.4.6-67.el7.centos.6.x86_64.rpm

# 卸载RPM包
rpm -e httpd-2.4.6-67.el7.centos.6.x86_64.rpm

# 推荐使用yum安装
yum install -y httpd
```

```bash
# 如果使用的LFS可以使用已经编译好的包安装
wget http://archive.apache.org/dist/httpd/binaries/linux/httpd-2.0.50-i686-pc-linux-gnu.tar.gz
tar -zxvf httpd-2.0.50-i686-pc-linux-gnu.tar.gz
cd httpd-2.0.50

# 安装到指定目录并启动
./install-bindist.sh /usr/local/apache2.0.50
./httpd start
```

---

### 源代码编译安装

> 为了方便源代码安装，可以使用`Apache Toolbox`​工具图形化安装`httpd`​服务。

-  **(1) 下载**

```bash
# 下载安装包并进行校验
wget http://archive.apache.org/dist/httpd/httpd-2.4.29.tar.bz2
wget http://archive.apache.org/dist/httpd/httpd-2.4.29.tar.bz2.md5


# 解压
tar -xjvpf httpd-2.4.29.tar.bz2 -C /usr/src
cd /usr/src/httpd-2.4.29
```

-  **(2) 编译需求**

```bash
# 编译要求
# 1. 空间需求（存放源码目录至少70MB，安装目录至少20MB）
# 2. 编译器需求（GCC编译器）
# 3. 时间需求（ntp服务同步）
# 4. 工具包需求（apr/apr-util）
# 5. APACI
ntpdate stdtime.gor.hk
hwclock -w
```

-  **(3) configure 脚本**

```bash
# 常用配置
# ./configure -h  可以查看更多参数选项信息
--prefix=/apache_patch: 指定Apache安装位置
--enable-module=so: 启用so模块，让Apache可以通过DSO方式加载模块
--enable-mods-shared=all: 以共享方式编译全部的模块，不包括核心模块
--enable-modules=all/most: 以静态方式编码全部的模块
--with-mpm=worker: 让Apache以worker方式运行
```

```bash
# 手动编译事例
CC="gcc" \
> ./configure --enable-modules="mod_proxy mod_so mod_authn_dbd"
```

-  **(4) 编译安装**

```bash
# 加速安装，一个CPU可以使用-j3，之后每增加一个+2
make -j9
make install
```

-  **(5) 清除调试符号**

```bash
strip /usr/local/apache2/bin/httpd
```
