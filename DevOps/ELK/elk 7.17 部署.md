#devops/elk 

ELK访问信息

```bash
客户端: http://192.168.10.142:5601
服务器: 192.168.10.142
```

## 环境准备

```bash
Centos：7.8
ELK   ：7.17.0
Redis ：5.0.10

```

*   关闭防火墙和selinux

    ```bash
    systemctl stop firewalld;setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

    ```

*   下载并安装软件包

    [https://www.elastic.co/cn/downloads/](https://www.elastic.co/cn/downloads/ "https://www.elastic.co/cn/downloads/") &#x20;

*   新建普通用户elk：elasticsearch只能用普通用户启动

    `useradd elk;echo Ninestar123|passwd --stdin elk`

*   elk用户拥有的可创建文件描述符数量

    `vim /etc/security/limits.conf` &#x20;

    ```bash
    elk hard nofile 65536
    elk soft nofile 65536
    ```

*   限制一个进程可以拥有的VMA(虚拟内存区域)的数量

    `vim /etc/sysctl.conf    # 在最后面追加下面内容`

    ```bash
    vm.max_map_count=655360                            
    ```

    `执行: sysctl -p`

*   解压到/data目录,授权给elk用户

    ```bash
    mkdir -p /data/{logs,script}
    tar -zxf elasticsearch-7.17.0-linux-x86_64.tar.gz -C /data/
    tar -zxf kibana-7.17.0-linux-x86_64.tar.gz -C /data/
    tar -zxf logstash-7.17.0-linux-x86_64.tar.gz -C /data/
    cd /data
    mv elasticsearch-7.17.0-linux-x86_6 elasticsearch
    mv kibana-7.17.0-linux-x86_64 kibana
    mv logstash-7.17.0-linux-x86_64 logstash
    chown -R elk:elk /data/*
    ```

## 安装redis

```bash
tar -zxf redis-5.0.10.tar.gz -C /data/
cd /data/redis
make && make install
cp redis.conf{,.bak}
sed -i "s/^bind 127.0.0.1/bind 0.0.0.0/g" redis.conf
sed -i "s/^# requirepass foobared/ requirepass Ninestar123/g" redis.conf

# 启动redis
nohup redis-server /data/redis/redis.conf >> /data/logs/redis.log 2>&1 &
```

## 配置elasticsearch

`cd /data/elasticsearch/`

`vim config/elasticsearch.yml`

```bash
# 本地单机模式，基本不用修改任何配置

# 配置es的集群名称(单机模式，不要开启注释)
cluster.name: my-application
# 设置node名字(单机模式，不要开启注释)
node.name: node-1
# 索引数据存储位置(保持默认,不要开启注释)
path.logs: /data/logs/elasticsearch
# 日志路径（保持默认,不要开启注释）
path.data: /path/to/data
# 是否锁住内存，避免（交换）带来的性能损失，默认值是：false
bootstrap.memory_lock: false
# 当前es节点绑定的ip地址
network.host: 192.168.10.142
# 启动的es对外访问的http端口，默认9200
http.port: 9200
# 此设置通常应包含群集中所有节点的地址(保持默认,不要开启注释)
discovery.seed_hosts: ["192.168.10.142"]
# 集群初始主节点(保持默认,不要开启注释)
cluster.initial_master_nodes: ["192.168.10.142"]
# 禁止使用通配符或_all删除索引，必须使用名称或别名才能删除该索引。
action.destructive_requires_name: true
```

启动

```bash
/data/elasticsearch/bin/elasticearch -d
```

## 配置kibana

`cd /data/kibana/`

` vim config/kibana.yml`

```
# 修改服务端口
server.port: 5601
# 网卡
server.host: "192.168.10.142"
# 指定 Kibana 可供最终用户使用的公共 URL。
server.publicBaseUrl: "http://192.168.10.142:5601"
# Kibana 服务器的名称。 这用于显示目的。
server.name: "elk-srv"
# 用于所有查询的 Elasticsearch 实例的 URL。
elasticsearch.hosts: ["http://192.168.10.142:9200"]

```

启动kibana

```
nohup /data/kibana/bin/kibana >> /data/logs/kibana.log 2>&1 & ; 

```

## 配置logstash

![](assets/elk%207.17%20部署/image-20221127214009311.png)

Logstash管道有两个必需的元素，**输入**和**输出**，以及一个**可选元素过滤器**。输入插件从数据源那里消费数据，过滤器插件根据你的期望修改数据，输出插件将数据写入目的地。

创建logstash管道配置文件

`vim /data/logstash/config/logstash.conf`

    input {
      redis {
        host => "192.168.10.142"
        port => "6379"
        password => "Ninestar123"
        db => "0"
        key => "xylc"  # 很关键，要与filebeat中配置的key一样
        data_type => "list"
        type => "xylc[192.168.10.135]"   # 用于区分多个logstash-input-redis
      }
    }

    # 数据处理
    # filter {
    #     grok {
    #         match => ["message",  "%{COMBINEDAPACHELOG}"]
    #     }
    # }


    # 1.将采集数据标准输出到控制台
    #output {
    #    stdout {
    #        codec => rubydebug
    #    }
    #}
    # 2.将采集数据保存到file文件中
    #output {
    #    file {
    #        path => "/data/logs/client/%{+YYYY-MM-dd}-%{host}.txt"
    #        codec => line {
    #            format => "%{message}"
    #        }
    #        gzip => true
    #    }
    #}

    # 3.将采集数据保存到elasticsearch
    output {
      if [type] == "xylc[192.168.10.135]" {
        if "client" in [tags] {
          elasticsearch {
            hosts => ["https://192.168.10.142:9200"]
            index => "%{[type]}-%{[tags]}-%{+YYYY-MM-dd}"
            manage_template => false
          }
        }
        if "bank" in [tags] {
          elasticsearch {
            hosts => ["https://192.168.10.142:9200"]
            index => "%{[type]}-%{[tags]}-%{+YYYY-MM-dd}"
            manage_template => false
          }
        }
        if "bps" in [tags] {
          elasticsearch {
            hosts => ["https://192.168.10.142:9200"]
            index => "%{[type]}-%{[tags]}-%{+YYYY-MM-dd}"
            manage_template => false
          }
        }
      }
    }

启动logstash

```bash
nohup /data/logstash/bin/logstash -f /data/logstash/config/logstash.conf >> /data/logs/logstash/logstash.log 2>&1 &
```

## 客户端上配置filebeat

`cd /data/filebeat; vim filebeat.yml`

```
filebeat.inputs:
- type:         # 可随意写，用于在output下使用if判断 
  enabled:      # 是否启用
  paths:        # 文件路径
    - 
  tags:         # 标签可随意写，方便在logstash中使用if判断

====================================================
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /data/microService/data/logs/client/client.*.out
  tags: ["client"]

- type: log
  enabled: true
  paths:
    - /data/microService/data/logs/gateway/gateway.*.out
  tags: ["gateway"]

- type: log
  enabled: true
  paths:
    - /data/bps/tomcat/logs/catalina.*.out
  tags: ["bps"]
  
output.redis:
  hosts: ["192.168.10.142:6379"]
  password: "Ninestar123"
  key: "xylc"
  db: 0
  timeout: 20
  
  
```

启动filebeat

    nohup /data/filebeat/filebeat -e -c /data/filebeat/filebeat.yml >> /data/filebeat/filebeat.log 2>&1 &
