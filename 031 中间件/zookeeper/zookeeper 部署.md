# zookeeper 部署

## 1. 环境说明

```
centos7.9
zookeeper-3.9.2
jdk1.8.0_333
```

## 2. 配置主机名称

　　三台机器均需要配置

```
[root@dn1 /root]# vi /etc/hosts
192.168.0.10 zk1
192.168.0.20 zk2
192.168.0.30 zk3
```

## 3. 配置jdk环境

　　3台服务器都安装jdk 参考jdk 部署

## 4. 安装zookeeper

　　下载对应版本 Zookeeper,官方下载地址：[https://archive.apache.org/dist/zookeeper/](https://archive.apache.org/dist/zookeeper/)

　　配置zookeeper的环境变量，三台机器均需要配置

```bash
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.9.2/apache-zookeeper-3.9.2-bin.tar.gz
tar xf apache-zookeeper-3.9.2-bin.tar.gz
mkdir -p /data
mv apache-zookeeper-3.9.2-bin /data/zookeeper

cat <<EOF >> /etc/profile
export ZK_HOME=/data/zookeeper
export PATH=\${PATH}:\${ZK_HOME}/bin
EOF


source /etc/profile
```

### 4.1 修改zoo.cfg配置文件

　　首先需要创建zoo.cfg，创建zookeeper数据目录zkdatas，再对zoo.cfg文件进行修改，三台机器均要配置

```bash
cd $ZK_HOME/conf
cp zoo_sample.cfg zoo.cfg

vim zoo.cfg
---------------------------------------------------------
# zookeeper客户端与服务器之间的心跳时间就是一个tickTime单位。默认值为2000毫秒，即2秒
tickTime=2000
# Follower连接到Leader并同步数据的最大时间，如果zookeeper数据比较大，可以考虑调大这个值来避免报错
initLimit=10
# Follower同步Leader的最大时间
syncLimit=5
dataDir=/data/zookeeper/data #zk数据保存目录
dataLogDir=/data/zookeeper/logdata #zk日志保存目录，当不配置时与dataDir一致
clientPort=2181 #客户端访问zk的端口

# zookeeper server启动的时候，会根据dataDirxia的myid文件确定当前节点的id。
# 指名集群间通讯端口和选举端口
server.1=192.168.0.10:2888:3888
server.2=192.168.0.20:2888:3888
server.3=192.168.0.30:2888:3888

#其他配置
#这个参数指定了清理频率，单位是小时
#autopurge.purgeInterval=5
#这个参数指定了需要保留的文件数目。默认是保留3个。
#autopurge.snapRetainCount=5
#adminServer 端口
#admin.serverPort=8180
------------------------------------------------------


#创建数据目录
mkdir -p /data/zookeeper/data

```

### 4.2 添加myid配置文件

　　在$ZK\_HOME/data路径下创建myid文件，第一台机器内容为1，第二台为2，第三台为3

```bash
# 第一台
echo "1" > /data/zookeeper/data/myid
# 第二台
echo "2" > /data/zookeeper/data/myid
# 第三台
echo "3" > /data/zookeeper/data/myid
```

### 4.3 启动zookeeper

```bash
# 三台机器启动zookeeper服务
/data/zookeeper/bin/zkServer.sh start
/data/zookeeper/bin/zkServer.sh status
# 查看启动的Java进程
jcmd
```

　　‍

　　‍
