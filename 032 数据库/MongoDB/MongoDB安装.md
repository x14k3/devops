# MongoDB安装

下载地址：[https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-7.0.9.tgz](https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-7.0.9.tgz)

‍

## 下载安装

二进制安装

```bash
# 下载
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-7.0.9.tgz
# 解压
tar -zxvf mongodb-linux-x86_64-rhel70-7.0.9.tgz -C /data
mv /data/mongodb-linux-x86_64-rhel70-7.0.9/ /data/mongodb
#创建dbpath和logpath的存储目录
mkdir -p /data/mongodb/data /data/mongodb/log


# 添加环境变量
echo "export PATH=/data/mongodb/bin:\$PATH" >> /etc/profile
source /etc/profile
```

rpm包安装个

```bash
wget https://repo.mongodb.org/yum/redhat/7/mongodb-org/7.0/x86_64/RPMS/mongodb-org-server-7.0.9-1.el7.x86_64.rpm
rpm -ivh mongodb-org-server-7.0.9-1.el7.x86_64.rpm
#创建dbpath和logpath的存储目录
mkdir -p /data/mongodb/data /data/mongodb/log
```

‍

## 启动mongodb服务

- 命令参数启动

```bash
mongod --port=27017 --dbpath=/mongodb/data --logpath=/mongodb/log/mongodb.log --bind_ip=0.0.0.0 --fork
    # 参数说明
    --port: 指定端口，默认为27017
    --dbpath: 指定数据文件存放目录
    --logpath: 指定日志文件，注意是指定文件不是目录
    --bind_ip: 默认只监听localhost网卡
    --fork: 后台启动
```

- 也可以将上面的参数写到配置文件中，如`/mongodb/conf/mongo.conf`​文件，必须是yaml格式

```ymal
systemLog:
  destination: file
  path: /mongodb/log/mongodb.log # log path
  logAppend: true
storage:
  dbPath: /mongodb/data # data directory
  engine: wiredTiger  #存储引擎，默认值就是wiredTiger
  journal:            #journal日志配置
    commitIntervalMs: 100 #mongod进程在日志操作之间允许的最大时间（以毫秒为单位）。值可以从1到500毫秒不等。较低的值会增加日志的耐用性，而牺牲了磁盘性能。在WiredTiger上，默认的日志提交间隔是100毫秒。此外，包含或暗示j:true的写入将导致期刊立即同步。
net:
  bindIp: 0.0.0.0
  port: 27017
processManagement:
  fork: true
```

- 将命令行参数直接转换为yaml:`--outputConfig`​

```bash
mongod --port=27017 --dbpath=/mongodb/data --logpath=/mongodb/log/mongodb.log --bind_ip=0.0.0.0 --fork --outputConfig
mongod --port=27017 --dbpath=/data/mongodb/data --logpath=/data/mongodb/log/mongodb.log --bind_ip=0.0.0.0 --fork --outputConfig > /data/mongodb/mongo.conf
```

```
net:
  bindIp: 0.0.0.0
  port: 27017
outputConfig: true
processManagement:
  fork: true
storage:
  dbPath: /data/mongodb/data
systemLog:
  destination: file
  path: /data/mongodb/log/mongodb.log
```

删除`outputConfig: true`​这一行，然后将其余内容复制到mongo.conf中

‍

- 关于配置参数的详细信息可以查看[官方文档](https://www.mongodb.com/docs/v7.0/reference/configuration-options/)

```bash
# 启动mongo服务
mongod -f /data/mongodb/mongo.conf

# 关闭mongo服务，注意：macos下不支持 --shutdown
mongod -f /data/mongodb/mongo.conf --shutdown
```

‍

### 安装mongoDB时可能遇到的问题

- 启动mongodb服务时，提示`mongod: error while loading shared libraries: libcrypto.so.1.1: cannot open shared object file: No such file or directory`​

```bash
wget  https://www.openssl.org/source/openssl-1.1.1w.tar.gz
tar -zxvf openssl-1.1.1w.tar.gz
cd openssl-1.1.1w
./config
# 如果make时提示 /bin/sh: gcc: command not found，需要先安装gcc：sudo yum install gcc -y
make && make install
ln -s /usr/local/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
ln -s /usr/local/lib64/libssl.so.1.1 /usr/lib64/libssl.so.1.1
```

‍

## shell客户端mongosh

使用`.tgz`​包安装服务器时，需要按照[mongosh安装说明](https://www.mongodb.com/docs/mongodb-shell/install/)下载并安装[mongosh](https://www.mongodb.com/docs/mongodb-shell/)。

rpm 安装

- 从mongodb6开始不再支持mongo命令，而是需要使用mongosh命令，关于mongosh命令的使用可以查看[官方文档](https://www.mongodb.com/docs/mongodb-shell/)
- mongosh命令的使用方式与mongo命令基本一致
- 下载地址：[mongosh下载地址](https://www.mongodb.com/try/download/shell)

二进制安装

```bash
wget https://downloads.mongodb.com/compass/mongosh-2.2.2-linux-x64-openssl11.tgz
# 解压
tar -zxvf mongosh-2.2.2-linux-x64-openssl11.tgz 
# 创建软连接
ln -s mongosh-2.2.2-linux-x64-openssl11 mongosh

# 修改/etc/profile，添加环境变量，方便执行MongoShell命令
export MONGODB_SHELL_HOME=/usr/local/soft/mongosh
PATH=$PATH:$MONGODB_SHELL_HOME/bin

#重新加载环境变量
source /etc/profile

# 查看版本
mongosh --version

```

### 连接mongodb server端

```bash

mongosh --host=127.0.0.1 --port=27017
# --host: mongodb server端ip地址
# --port: mongodb server端口
```

‍

### mongosh 使用说明

```bash
[root@localhost mongodb]# mongosh --help

  $ mongosh [options] [db address] [file names (ending in .js or .mongodb)]

  Options:

    -h, --help                                 Show this usage information
    -f, --file [arg]                           Load the specified mongosh script
        --host [arg]                           Server to connect to
        --port [arg]                           Port to connect to
        --build-info                           Show build information
        --version                              Show version information
        --quiet                                Silence output from the shell during the connection process
        --shell                                Run the shell after executing files
        --nodb                                 Don't connect to mongod on startup - no 'db address' [arg] expected
        --norc                                 Will not run the '.mongoshrc.js' file on start up
        --eval [arg]                           Evaluate javascript
        --json[=canonical|relaxed]             Print result of --eval as Extended JSON, including errors
        --retryWrites[=true|false]             Automatically retry write operations upon transient network errors (Default: true)

  Authentication Options:

    -u, --username [arg]                       Username for authentication
    -p, --password [arg]                       Password for authentication
        --authenticationDatabase [arg]         User source (defaults to dbname)
        --authenticationMechanism [arg]        Authentication mechanism
        --awsIamSessionToken [arg]             AWS IAM Temporary Session Token ID
        --gssapiServiceName [arg]              Service name to use when authenticating using GSSAPI/Kerberos
        --sspiHostnameCanonicalization [arg]   Specify the SSPI hostname canonicalization (none or forward, available on Windows)
        --sspiRealmOverride [arg]              Specify the SSPI server realm (available on Windows)

  TLS Options:

        --tls                                  Use TLS for all connections
        --tlsCertificateKeyFile [arg]          PEM certificate/key file for TLS
        --tlsCertificateKeyFilePassword [arg]  Password for key in PEM file for TLS
        --tlsCAFile [arg]                      Certificate Authority file for TLS
        --tlsAllowInvalidHostnames             Allow connections to servers with non-matching hostnames
        --tlsAllowInvalidCertificates          Allow connections to servers with invalid certificates
        --tlsCertificateSelector [arg]         TLS Certificate in system store (Windows and macOS only)
        --tlsCRLFile [arg]                     Specifies the .pem file that contains the Certificate Revocation List
        --tlsDisabledProtocols [arg]           Comma separated list of TLS protocols to disable [TLS1_0,TLS1_1,TLS1_2]
        --tlsUseSystemCA                       Load the operating system trusted certificate list
        --tlsFIPSMode                          Enable the system TLS library's FIPS mode

  API version options:

        --apiVersion [arg]                     Specifies the API version to connect with
        --apiStrict                            Use strict API version mode
        --apiDeprecationErrors                 Fail deprecated commands for the specified API version

  FLE Options:

        --awsAccessKeyId [arg]                 AWS Access Key for FLE Amazon KMS
        --awsSecretAccessKey [arg]             AWS Secret Key for FLE Amazon KMS
        --awsSessionToken [arg]                Optional AWS Session Token ID
        --keyVaultNamespace [arg]              database.collection to store encrypted FLE parameters
        --kmsURL [arg]                         Test parameter to override the URL of the KMS endpoint

  DB Address Examples:

        foo                                    Foo database on local machine
        192.168.0.5/foo                        Foo database on 192.168.0.5 machine
        192.168.0.5:9999/foo                   Foo database on 192.168.0.5 machine on port 9999
        mongodb://192.168.0.5:9999/foo         Connection string URI can also be used

  File Names:

        A list of files to run. Files must end in .js and will exit after unless --shell is specified.

  Examples:

        Start mongosh using 'ships' database on specified connection string:
        $ mongosh mongodb://192.168.0.5:9999/ships

  For more information on usage: https://docs.mongodb.com/mongodb-shell.
[root@localhost mongodb]# 

```
