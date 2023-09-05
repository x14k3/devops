# PostgreSQL部署

PostgreSQL 是一个开放源代码的通用对象关系数据库管理系统，具有许多高级功能，可让您创建复杂的Web应用程序

# yum安装

## 从CentOS仓库安装PostgreSQL

YUM 源 PostgreSQL的版本是 9.2.24，安装完成后，相关的操作命令 psql、postgresql-setup 会添加到 /usr/bin 目录下，可以在命令行下直接使用。

```bash
yum install postgresql-server postgresql-contrib
# 初始化,初始化之后，会生成postgresql相关配置文件和数据库文件，他们都会存放在路径/var/lib/pgsql/data下。
postgresql-setup initdb
# 启动数据库
systemctl start postgresql
systemctl enable postgresql
# 使用postgres用户登录（PostgresSQL安装后会自动创建postgres用户，无密码）
su - postgres
psql -c "SELECT version();"
```

## 从官方PostgreSQL仓库安装最新版本的PostgreSQL

```bash
# 如果需要安装其它版本，你可以将10改为11，12，13，14。
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
# 安装 PostgreSQL 12 服务 yum install -y postgresql12 postgresql12-server 
# 初始化数据库 
/usr/pgsql-12/bin/postgresql-12-setup initdb
# 启动postgreSQL服务
systemctl start postgresql-12
systemctl enable postgresql-12
su - postgres -c "/usr/pgsql-12/bin/psql -c 'SELECT version();'"
```

# 源码安装

源码下载地址：http://ftp.postgresql.org/pub/source/v12.15/

```bash
# 下载PostgreSQL 源码包
wget http://ftp.postgresql.org/pub/source/v12.15/postgresql-12.15.tar.gz
tar -zxvf postgresql-12.15.tar.gz
cd postgresql-12.15/

# 查看INSTALL 文件()
# INSTALL 文件中Short Version 部分解释了如何安装PostgreSQL 的命令，
# Requirements 部分描述了安装PostgreSQL 所依赖的lib

# 安装依赖
yum install -y  gcc gcc-c++ wget make openssl-devel pam-devel libxml2-devel libxslt-devel openldap-devel systemd-devel tcl-devel python-devel bzip2 gmp-devel mpfr-devel llvm5.0 llvm5.0-devel clang libicu-devel perl-ExtUtils-Embed readline-devel

# 安装到指定目录
mkdir /data/pgsql
./configure --prefix=/data/pgsql --enable-nls --with-python --with-perl --with-tcl --with-gssapi --with-icu --with-openssl --with-pam --with-ldap --with-systemd --with-libxml --with-libxslt --enable-thread-safety --enable-debug

# 编译安装
make -j 4
make install

# 安装contrib目录下的一些工具
cd contrib
make
make install

# 添加用户postgres
useradd postgres && echo "Ninestar123" |passwd --stdin postgres

# 添加环境变量
# vim /home/postgres/.bash_profile添加下列内容
export PGHOME=/data/pgsql
export PGUSER=postgres
export PGPORT=5432
export PGDATA=/data/pgsql/data
export PGLOG=/data/pgsql/log/postgres.log
export PATH=$PGHOME/bin:$PATH:$HOME/bin
export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
PATH=/usr/local/pgsql/bin:$PATH
export PATH

# 创建数据目录
mkdir /data/pgsql/data/
chown -R postgres.postgres /data/pgsql

# 切换到postgres用户
su - postgres

# 初始化数据库
/data/pgsql/bin/initdb
#/data/pgsql/bin/initdb -D /data/pgsql/data/ -U postgres -W -A peer -E UTF8

# 创建数据库日志目录
mkdir /data/pgsql/pgdata/logs
# 服务启动，将在后台启动服务器并且把输出放到指定的日志文件中
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ -l /data/pgsql/log/postgres.log start
# 停止服务
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ stop
# 重新加载配置文件
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ reload
```

## 编译安装参数说明

```bash
--with-includes=`DIRECTORIES` # `DIRECTORIES`是一个冒号分隔的目录列表，这些目录将被加入编译器的头文件搜索列表中。 如果你有一些可选的包（例如 GNU Readline）安装在非标准位置， 你就必须使用这个选项，以及可能还有相应的 `--with-libraries`选项。
--enable-nls=`LANGUAGES`      # 打开本地语言支持（NLS），也就是以非英文显示程序消息的能力。_`LANGUAGES`_是一个空格分隔的语言代码列表， 表示你想支持的语言。例如`--enable-nls='de fr'` （你提供的列表和实际支持的列表之间的交集将会自动计算出来）。如果你没有声明一个列表，那么就会安装所有可用的翻译。
--with-pgport=`NUMBER`        # 把_`NUMBER`_设置为服务器和客户端的默认端口。默认是 5432。 这个端口可以在以后修改，不过如果你在这里声明，那么服务器和客户端将有相同的编译好了的默认值。这样会非常方便些。 通常选取一个非默认值的理由是你企图在同一台机器上运行多个PostgreSQL服务器。
--with-perl                   # 制作PL/Perl服务器端编程语言。
--with-python                 # 制作PL/Python服务器端编程语言。
--with-tcl                    # 制作PL/Tcl服务器编程语言。
--with-gssapi                 # 编译 GSSAPI 认证支持。在很多系统上，GSSAPI（通常是 Kerberos 安装的一部分）系统不会被安装在默认搜索位置（例如`/usr/include`、`/usr/lib`），因此你必须使用选项`--with-includes`和`--with-libraries`来配合该选项。`configure`将会检查所需的头文件和库以确保你的 GSSAPI 安装足以让配置继续下去。
--with-icu                    # 支持ICU库。 这需要安装ICU4C软件包。 目前要求的最低ICU4C版本是4.2。
--with-openssl                # 编译SSL（加密）连接支持。这个选项需要安装OpenSSL包。`configure`将会检查所需的头文件和库以确保你的 OpenSSL安装足以让配置继续下去。
--with-pam                    # 编译PAM（可插拔认证模块）支持。
--with-bsd-auth               # 编译 BSD 认证支持（BSD 认证框架目前只在 OpenBSD 上可用）。
--with-ldap                   # 为认证和连接参数查找编译LDAP支持。
--with-systemd                # 编译对systemd 服务通知的支持。如果服务器是在systemd 机制下被启动，这可以提高集成度，否则不会有影响。要使用这个选项，必须安装libsystemd 以及相关的头文件。
--without-readline            # 避免使用Readline库（以及libedit）。这个选项禁用了psql中的命令行编辑和历史， 因此我们不建议这么做。
--with-bonjour                # 编译 Bonjour 支持。这要求你的操作系统支持 Bonjour。在 macOS 上建议使用。
--with-libxml                 # 编译 libxml （启用 SQL/XML 支持）。这个特性需要 Libxml 版本 2.6.23 及以上。
--with-libxslt                # 编译[xml2](http://www.postgres.cn/docs/12/xml2.html "F.45. xml2")模块时使用 libxslt。xml2依赖这个库来执行XML的XSL转换。
--disable-thread-safety       # 禁用客户端库的线程安全性。这会阻止libpq和ECPG程序中的并发线程安全地控制它们私有的连接句柄。
--enable-debug                # 把所有程序和库以带有调试符号的方式编译。这意味着你可以通过一个调试器运行程序来分析问题。 这样做显著增大了最后安装的可执行文件的大小，并且在非 GCC 的编译器上，这么做通常还要关闭编译器优化， 这些都导致速度的下降。但是，如果有这些符号的话，就可以非常有效地帮助定位可能发生问题的位置。目前，我们只是在你使用 GCC 的情况下才建议在生产安装中使用这个选项。但是如果你正在进行开发工作，或者正在使用 beta 版本，那么你就应该总是打开它。


# 使用较大数据块提升数据库IO性能
--with-blocksize=32           # 指定数据块大小为32KB
--with-wal-blocksize=32       # 指定WAL日志块为128KB
--with-wal-segsize=64         # 指定WAL日志文件为64MB
```

## initdb初始化参数

如果通过环境变量方式定义的初始化参数，就不用再指定了

参考PostgreSQL内置命令

```bash
# initdb 创建一个新的 PostgreSQL 数据库集群
/data/pgsql12/bin/initdb -D /data/pgsql12/pgdata/ -X /data/pgsql12/wal -E UTF8 -U postgres -W

-D [DIR]       # 指定应存储数据库集群的目录。但您可以通过设置 PGDATA 环境变量来避免写入它，这可能很方便，
-X [DIR]       # 指定应WAL日志（预写日志，类似redo）的目录
-E [ENCODING]  # 指定以后创建的任何数据库的默认编码
-U [NAME]      # 数据库超级用户的用户名，默认postgres
-W             # 提示超级用户设置口令
-A [METHOD]    # 指定本地连接的默认用户认证方式
-d             # 以调试模式运行，可以打印出很多调试消息
```

# 环境变量

建议通过环境变量方式初始化数据库

```pgsql
-- 以下环境变量可以使用
export PGHOME=/data/pgsql
export PGUSER=postgres
export PGPORT=5432
export PGDATA=/data/pgsql/data
export PGLOG=/data/pgsql/log/postgres.log
export PATH=$PGHOME/bin:$PATH:$HOME/bin
export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
PATH=/usr/local/pgsql/bin:$PATH
export PATH
```

‍

# pgsql 客户端

参考PostgreSQL内置命令

‍
