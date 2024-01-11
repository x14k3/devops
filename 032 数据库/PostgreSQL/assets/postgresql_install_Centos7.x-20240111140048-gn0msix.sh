#!/bin/bash
# 下载PostgreSQL 源码包
wget http://ftp.postgresql.org/pub/source/v12.15/postgresql-12.15.tar.gz
tar -zxvf postgresql-12.15.tar.gz

# 查看INSTALL 文件()
# INSTALL 文件中Short Version 部分解释了如何安装PostgreSQL 的命令，
# Requirements 部分描述了安装PostgreSQL 所依赖的lib

# 安装依赖CentOS
yum install -y  gcc gcc-c++ wget make openssl-devel pam-devel libxml2-devel libxslt-devel openldap-devel systemd-devel tcl-devel python-devel bzip2 gmp-devel mpfr-devel llvm5.0 llvm5.0-devel clang libicu-devel perl-ExtUtils-Embed readline-devel

#Ubuntu
#sudo apt-get install libreadline-dev

# 安装到指定目录
mkdir -p /data/pgsql
cd postgresql-12.15/
./configure --prefix=/data/pgsql --enable-nls --with-python --with-perl --with-tcl --with-gssapi --with-icu --with-openssl --with-pam --with-ldap --with-systemd --with-libxml --with-libxslt --enable-thread-safety --enable-debug

# 编译安装
make -j4
make install

# 安装contrib目录下的一些工具
cd contrib
make
make install

# 添加用户postgres
useradd postgres && echo "8ql6,yhY" |passwd --stdin postgres
# useradd -m postgres && echo "postgres:Ninestar123" | chpasswd

# 添加环境变量
# vim /home/postgres/.bash_profile添加下列内容
cat >>/home/postgres/.bash_profile <<EOF
export PGHOME=/data/pgsql
export PGUSER=postgres
export PGPORT=5432
export PGDATA=/data/pgsql/data
export PGLOG=/data/pgsql/log/postgres.log
export PATH=$PGHOME/bin:$PATH:$HOME/bin
export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
EOF

# 创建数据目录
mkdir -p /data/pgsql/data/
chown -R postgres.postgres /data/pgsql

cat <<EOF
###### 安装完成，请参考以下命令，启动数据库 ########

# 切换到postgres用户
su - postgres

# 初始化数据库
/data/pgsql/bin/initdb

# 服务启动，将在后台启动服务器并且把输出放到指定的日志文件中
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ -l /data/pgsql/data/pg.log start
# 停止服务
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ stop
# 重新加载配置文件
/data/pgsql/bin/pg_ctl -D /data/pgsql/data/ reload

###### 参考以下命令，创建数据库及用户 ######
# 创建数据库
CREATE DATABASE exampledb OWNER dbuser;

# 创建用户
CREATE USER dbuser WITH PASSWORD '<CUSTOM PASSWORD>';

# 将 exampledb 数据库的搜索权限都赋予给 dbuser ：
GRANT ALL PRIVILEGES ON DATABASE exampledb TO dbuser.
EOF
