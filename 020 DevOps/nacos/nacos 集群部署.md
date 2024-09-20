# nacos 集群部署

　　[官网：https://nacos.io/](https://links.jianshu.com/go?to=https://nacos.io/ "官网：https://nacos.io/")
[下载地址：https://github.com/alibaba/nacos/releases](https://links.jianshu.com/go?to=https://github.com/alibaba/nacos/releases "下载地址：https://github.com/alibaba/nacos/releases")

### 1. 解压安装

```bash
 tar -xvf nacos-server-1.3.0.tar.gz
```

### 2. 配置集群配置文件

　　在nacos的解压目录nacos/的conf目录下，有配置文件cluster.conf，请每行配置成ip:port。（请配置3个或3个以上节点）

```bash
cp cluster.conf.example  cluster.conf
vim cluster.conf
----------------------------------------
192.168.10.150
192.168.10.151
192.168.10.152
```

### 3. 确定数据源

#### 使用内置数据源

　　无需进行任何配置

#### 使用外置数据源

　　生产使用建议至少主备模式，或者采用高可用数据库。

1. 创建数据库和用户

```sql
create database nacos character set utf8mb4;
CREATE USER 'nacos'@'%' IDENTIFIED BY 'Ninestar123'; 
grant all privileges on nacos.* to nacos@'%';

```

2. 初始化 MySQL 数据库

```bash
mysql -unacos -p nacos < /data/nacos/conf/nacos-mysql.sql
```

3. application.properties 配置

```properties
### 是否使用 MySQL 作为数据源： 
spring.datasource.platform=mysql 
### 数据库计数： 
db.num=1 
### 数据库的连接网址：
db.url.0=jdbc:mysql://127.0.0.1:3306/nacos？characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC 
db.user.0=nacos 
db.password.0=nacos
```

## 4. 启动服务器

```bash
# 集群启动-使用内置数据库
sh startup.sh -p embedded

# 集群启动-使用外置数据库
sh startup.sh
```
