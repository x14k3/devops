

## 使用【服务端】

### 单机模式 （linux部署）

ps：初始用户名密码：minioadmin

1、下载linux minio

```bash
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2025-03-12T18-04-18Z
```

2、linux部署

```bash
#修改用户名密码：
export MINIO_ROOT_USER=username
export MINIO_ROOT_PASSWORD=password

#启动：
./minio server --console-address ":9090" /mnt/data

#后台启动，指定日志路径：
nohup ./minio server --console-address :"9090" ./miniodata/data >./miniodata/minio.log 2>&1 &

#ps：接口默认地址：9000
#指定console端口：9090
#--config-dir 命令自定义配置目录
#--address ":port" 指定服务静态端口
#--console-address ":port" 指定console静态端口
```

3、docker部署

```docker
docker run \
  -p 9000:9000 \
  -p 9001:9001 \
  -e "MINIO_ROOT_USER=AKIAIOSFODNN7EXAMPLE" \
  -e "MINIO_ROOT_PASSWORD=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
  quay.io/minio/minio server /data --console-address ":9001"
```

4、docker部署纠删码模式

```docker
docker run -d -p 9000:9000 -p 9090:9090 --name minio \
 -v /mnt/data1:/data1 \
 -v /mnt/data2:/data2 \
 -v /mnt/data3:/data3 \
 -v /mnt/data4:/data4 \
 -v /mnt/data5:/data5 \
 -v /mnt/data6:/data6 \
 -v /mnt/data7:/data7 \
 -v /mnt/data8:/data8 \
minio/minio server /data{1...8} --console-address ":9090"
```

5、注册服务

```bash
#配置启动配置文件
cat <<EOF >> minio.conf 
MINIO_VOLUMES="/data/minio/data"
MINIO_OPTS="--address :9000  --console-address :9001"
MINIO_ROOT_USER="minioadmin"
MINIO_ROOT_PASSWORD="minioadmin"
EOF
#注：
#MINIO_VOLUMES 是数据存储地址
#MINIO_OPTS 开启的端口号  9000 为具体文件访问端口 9001 为控制台页面访问端口
#MINIO_ROOT_USER 和 MINIO_ROOT_PASSWORD 对应账号密码
#
#-------------------------------------------------------
cat << EOF >> /etc/systemd/system/minio.service
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/data/minio/minio

[Service]
WorkingDirectory=/data/minio/
EnvironmentFile=/data/minio/minio.conf
ExecStart=/data/minio/minio server $MINIO_OPTS $MINIO_VOLUMES
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
#-------------------------------------------------------

#加入开机自启动
systemctl enable minio.service

#启动服务
systemctl start minio.service

#查看服务状态
systemctl status minio.service
```

### 分布式部署

注意事项：

1、linux部署：启动一个分布式Minio实例，你只需要把硬盘位置作为参数传给minio server命令即可，然后，你需要在所有其他节点运行同样的命令。

2、分布式Minio里所有的节点需要有同样的access秘钥和secret秘钥，这样这些节点才能建立连接。为了实现这个，你需要在执行minioserver命令前，先将access秘钥和secret秘钥expoert成环境变量。新版本使用MINIO\_ROOT\_USER&MINIO\_ROOTPASSWORD。

3、【举例1】8个节点，每个节点1块盘。启动分布式Minio实例，8个节点，每节点1块盘，需要再8个节点上都运行下面的命令：

```bash
export MINIO_ROOT_USER=admin
export MINIO_ROOT_PASSWORD=123456
```

【举例1.1】下面示例的IP仅供示例参考没需要改成你真实的IP地址和文件夹路径。

```
minio server http://192.168.1.11/export1 \
http://192.168.1.12/export2 \
http://192.168.1.13/export3 \
http://192.168.1.14/export4 \
http://192.168.1.15/export5 \
http://192.168.1.16/export6 \
http://192.168.1.17/export7 \
http://192.168.1.18/export8 \
```

‍

【举例2】4个节点，每个节点2块盘。启动分布式Minio实例，4个节点，每节点2块盘，需要再4个节点上都运行下面的命令：

```bash
export MINIO_ROOT_USER=admin
export MINIO_ROOT_PASSWORD=123456
```

【举例2.1】下面示例的IP仅供示例参考没需要改成你真实的IP地址和文件夹路径。

```bash
http://192.168.1.11/export1 \
http://192.168.1.11/export2 \
http://192.168.1.12/export1 \
http://192.168.1.12/export2 \
http://192.168.1.13/export1 \
http://192.168.1.13/export2 \
http://192.168.1.14/export1 \
http://192.168.1.14/export2 \
```

‍

 5、统一入口：使用Nginx 统一入口，可以做ip hash策略分散服务器压力。

【例如 ：】

```
upstream minio {
    server 192.168.1.11:9001;
    server 192.168.1.12:9001;
    server 192.168.1.13:9001;
    server 192.168.1.14:9001;
}

upstream console {
    ip_hash;
    server 192.168.1.11:5001;
    server 192.168.1.12:5002;
    server 192.168.1.13:5003;
    server 192.168.1.14:5004;
}

server {
    listen      9000;
    listen [::] 9000;
    server_name localhost;
  
    localhost / {
  
        proxy_pass http://minio;
    }
}
server {
    listen      5000;
    listen [::] 5000;
    server_name localhost;
  
    localhost / {
  
    proxy_pass http://console;
    }
}
```

‍

## 使用【客户端】

介绍：MinIO Clinet(mc) 为ls,cat，cp，mirror，diff,find 等UNIX命令提供一种替代方案。它支持文件系统和兼容Amazon S3的云存储服务（AWS Signature v2和v4）。

### linux 部署mc

ps:注意9001 是接口端口，不是console端口。

1、下载

```
wget https://dl.min.io/client/mc/release/linux-amd64/mc 
```

2、赋予权限

```
chmod +x mc
./mc --help
```

3、查询mc host配置

```bash
mc config host ls
```

4、 添加minio服务

```
mc config host add minio-server http://81.70.144.153:9001/
minioadmin minioadmin
```

5、 mc命令【管理文件】

```bash
# 加入配置文件：
mc config host add minio01 http://81.70.144.153:9000 minioadmin minioadmin

# 连接查看minio文件内容：
mc ls tuling minio01

# 下载文件
mc cp minio01/yeb/数据结构算法面试题.txt D:\

# 上传文件
mc cp D:\测试.txt minio01/yeb

# 删除文件
mc rm minio01/yeb/测试.txt
```

6、mc命令【管理桶（Bucket）】

```bash
# 创建bucket
mc mb minio01/yeb1

# 删除bucket(有数据删除失败)
mc rb minio01/yeb1

# bucket不为空，强制删除，慎用
mc rb --force minio01/yeb1

# 查看bucket磁盘使用情况
mc du minio01/yeb
```

7、mc命令【admin使用】

```bash
Minio Client 提供了‘admin’子命令来对minio部署执行管理任务

service  服务器停止并且重启所有Minio服务器
udpate   更新所有MInio服务器
info     显示minio服务器信息
user     管理用户
group    管理小组
policy   minio服务器中定义策略管理
cofnig   配置管理minio服务器
heal     修复minio服务器上的磁盘、桶、对象
profile  生成概要文件数据进行调试
top      顶部提供minio统计信息
trace    跟踪显示minio服务器的http跟踪
console  控制台显示minio服务器的控制台日志
prometheus prometheys配置
kms      kms管理操作
```

‍

‍

### console控制台

打开 [http://127.0.0.1:9090](http://127.0.0.1:9090) ，输入 root 用户命和密码 (均为 `minioadmin`​) 可以看到 MinIO Console 菜单向分为了三类：

- User: 对象浏览、Access Token。
- Administrator: bucket 管理、用户和权限管理等。
- Subscription: 付费订阅的企业级能力，本文不做介绍。

#### bucket 管理

##### 创建桶

菜单路径：**​`Buckets-->Create Bucket`​**​

桶是用来存储文件的，创建桶要填写桶的名称、是否开启（同名多版本、锁定对象不允许删除、控制用户使用容量、删除后文件保存周期）

![11b60ef9615b3a0788b82aab306412c652307b2b.png@1256w_642h_!web-article-pic](assets/11b60ef9615b3a0788b82aab306412c652307b2b.png@1256w_642h_web-article-pic-20240717181910-bwkeijo.avif)

##### 管理桶

菜单路径：**​`Buckets-->每个桶右上角的Manage`​**​

管理桶，可以看到桶的概要信息、桶产生的事件信息；以及可以对桶配置复制规则、生命周期管理、访问规则管理、访问审计管理。

![eb037164fa3dcd95155a0118e9d9bd763ff45a7d.png@1256w_646h_!web-article-pic](assets/eb037164fa3dcd95155a0118e9d9bd763ff45a7d.png@1256w_646h_web-article-pic-20240717181927-sjha2bl.avif)

#### 用户和权限管理

MinIO 采用 PBAC （Policy-Based Access Control , 基于策略的访问控制），有如下概念：

- 策略，定义对那些资源拥有哪些行为。
- 用户，鉴权主体，默认使用用户名密码认证，可以关联多个策略。
- 组，一组策略的集合，用户可以选择加入多个组，组下的用户继承该组关联所有策略。
- 服务账号 (Service Accounts, Access  Keys)，用户可以创建多服务账号，服务账号默认会继承该用户的所有策略（也可以配置用户策略的一个子集），这个服务账号包含 Access Key 和 Secret Key，服务账号用于给开发者编写的程序与对象存储系统进行认证鉴权的方式。

上一步我们创建一个名为 `bucket-test`​ 的 bucket。这里基于如上机制，创建一个用户和服务账号，且约束其只能操作 `bucket-test`​这个 bucket，步骤如下：

1. 打开 [Policies 页面](http://127.0.0.1:9090/policies)，点击新建，Policy Name 填写 `bucket-test-rw`​，Write Policy 内容如下：

    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:*"
                ],
                "Resource": [
                    "arn:aws:s3:::bucket-test/*"
                ]
            }
        ]
    }
    ```

    - Version 为版本号。
    - Statement 为策略表达式数组，其中值包含一个对象。

      - ​`"Effect": "Allow"`​ 表示允许对 `Resource`​ 做 `Action`​。
      - ​`Action`​ 表示允许执行的动作，`"s3:*"`​ 表示所有 AWS S3 API 可以执行所有操作都允许执行。
      - ​`Resource`​ 表示允许操作的资源， `"arn:aws:s3:::bucket-test/*"`​ 表示只允许操作 bucket 名为 `bucket-test`​ 的 bucket
    - 更多关于策略 JSON 的编写，参见：[官方文档](https://min.io/docs/minio/kubernetes/upstream/administration/identity-access-management/policy-based-access-control.html#policy-document-structure)。
2. 打开 [Identity - Users 页面](http://127.0.0.1:9090/identity/users)，点击创建用户，填写用户名 `bucket-test-user`​ 密码 `12345678`​ （仅测试）， Assign Policies 选择 `bucket-test-rw`​，点击保存。
3. 退出登录 root 用户，使用上述创建账号登录，这个用户能看到 Administrator 菜单项只有 Buckets，只能管理 `bucket-test`​ 这个 bucket 了。
4. 打开 [Access Keys](http://127.0.0.1:9090/access-keys)，点击 Create Access Key 即可创建一个服务账号，可以获取到 Access Key 和 Secret Key （如 Access Key: `1qJ4sGlF6HzTWIHsakYK`​，Secret Key: `UwkpCLEMX2ODx5Cg9FfsxGGokIWXRofFwO8Chiq0`​）。需要注意的是，创建服务的 Secret Key 只有首次创建的时候才能获取，后续将服务从后台拿到，需谨慎保管。

至此，就可以通过上面创建的服务账号通过 AWS S3 API 操作这个 `bucket-test`​ 这个 bucket 了。

## MinIO 架构简述

上面我们部署的是一个单节点的 MinIO，这种部署方式只能用作学习和测试使用，不能在生产场景使用。本小结将简要介绍的 MinIO 在生产场景的架构特点。

和常规的分布式存储相比， MinIO 是去中心化的，也就是说:

- MinIO 没有 Master 节点。
- 所有 MinIO 节点都是对等的。
- 所有 MinIO 节点配置都相同。
- 所有 MinIO 节点都有集群的完整全貌。
- 任意一个 MinIO 节点都可以对外提供 HTTP 服务。

因此：

- 在部署之前需要规划好每个节点的磁盘数和配置，一旦确定后期将无法在线更改。
- MinIO 集群需要外部负载均衡器（如 Nginx）将流量均衡的打到 MinIO 节点。

值得特别说明的是：由于 MinIO server 是 Go 编写的，因此安装配置 MinIO 非常容易，只需要下载一个二进制文件，通过启动参数或环境变量给出整个集群的全貌配置以及磁盘配置即可。如：

```bash
minio server https://minio{1...4}.example.net/mnt/disk{1...4} https://minio{5...8}.example.net/mnt/disk{1...4}
```

‍
