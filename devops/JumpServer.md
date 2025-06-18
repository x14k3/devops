
## 环境要求

| OS/Arch | Architecture | Linux Kernel | Soft Requirement | Minimize Hardware |
| ---|---|---|---|--- |
| linux/amd64 | x86_64 | >= 4.0 | wget curl tar gettext iptables python | 2Core/8GB RAM/60G HDD |
| linux/arm64 | aarch64 | >= 4.0 | wget curl tar gettext iptables python | 2Core/8GB RAM/60G HDD |
| linux/loong64 | loongarch64 | == 4.19 | wget curl tar gettext iptables python | 2Core/8GB RAM/60G HDD |

Debian / UbuntuRedHat / CentOS

```
apt-get update
apt-get install -y wget curl tar gettext iptables
```

```
yum update
yum install -y wget curl tar gettext iptables
```

JumpServer 需要使用 MySQL 或 MariaDB 存储数据，使用 Redis 缓存数据，如果希望使用自建数据库或云数据库请参考此处的要求
支持[数据库 SSL 连接](https://docs.jumpserver.org/zh/master/install/install_security/#ssl)和[Redis SSL 连接](https://docs.jumpserver.org/zh/master/install/install_security/#redis-ssl)

| Name | Version | Default Charset | Default collation | TLS/SSL |
| ---|---|---|---|--- |
| MySQL | >= 5.7 | utf8 | utf8_general_ci |  |
| MariaDB | >= 10.2 | utf8mb3 | utf8mb3_general_ci |  |

| Name | Version | Sentinel | Cluster | TLS/SSL |
| ---|---|---|---|--- |
| Redis | >= 5.0 |  |  |  |

MySQLMariaDB

```
create database jumpserver default charset 'utf8';
```

```
mysql> show create database jumpserver;
+------------+---------------------------------------------------------------------+
| Database   | Create Database                                                     |
+------------+---------------------------------------------------------------------+
| jumpserver | CREATE DATABASE `jumpserver` /*!40100 DEFAULT CHARACTER SET utf8 */ |
+------------+---------------------------------------------------------------------+
1 row in set (0.00 sec)
```


```
create database jumpserver default charset 'utf8';
```


```
MariaDB> show create database jumpserver;
+------------+-----------------------------------------------------------------------+
| Database   | Create Database                                                       |
+------------+-----------------------------------------------------------------------+
| jumpserver | CREATE DATABASE `jumpserver` /*!40100 DEFAULT CHARACTER SET utf8mb3*/ |
+------------+-----------------------------------------------------------------------+
1 row in set (0.001 sec)
```


## 标准部署

国内可以使用由[华为云](https://www.huaweicloud.com/)提供的容器镜像服务

| 区域 | 镜像仓库地址 | 配置文件 /opt/jumpserver/config/config.txt | Kubernetes values.yaml | OS/ARCH |
| ---|---|---|---|--- |
| 华北-北京一 | swr.cn-north-1.myhuaweicloud.com | DOCKER_IMAGE_PREFIX=swr.cn-north-1.myhuaweicloud.com | repository: swr.cn-north-1.myhuaweicloud.com | linux/amd64 |
| 华南-广州 | swr.cn-south-1.myhuaweicloud.com | DOCKER_IMAGE_PREFIX=swr.cn-south-1.myhuaweicloud.com | repository: swr.cn-south-1.myhuaweicloud.com | linux/amd64 |
| 华北-北京四 | swr.cn-north-4.myhuaweicloud.com | DOCKER_IMAGE_PREFIX=swr.cn-north-4.myhuaweicloud.com | repository: swr.cn-north-4.myhuaweicloud.com | linux/arm64 |
| 华东-上海一 | swr.cn-east-3.myhuaweicloud.com | DOCKER_IMAGE_PREFIX=swr.cn-east-3.myhuaweicloud.com | repository: swr.cn-east-3.myhuaweicloud.com | linux/arm64 |
| 西南-贵阳一 | swr.cn-southwest-2.myhuaweicloud.com | DOCKER_IMAGE_PREFIX=swr.ap-southeast-1.myhuaweicloud.com | repository: swr.ap-southeast-1.myhuaweicloud.com | linux/loong64 |



InstallerHelm[Source](https://docs.jumpserver.org/zh/master/dev/build/)[Allinone](https://github.com/jumpserver/Dockerfile/tree/master/allinone)

```
cd /opt
wget https://github.com/jumpserver/installer/releases/download/v2.28.8/jumpserver-installer-v2.28.8.tar.gz
tar -xf jumpserver-installer-v2.28.8.tar.gz
cd jumpserver-installer-v2.28.8
```

```
# 根据需要修改配置文件模板, 如果不清楚用途可以跳过修改
cat config-example.txt
```



```
# 以下设置如果为空系统会自动生成随机字符串填入
## 迁移请修改 SECRET_KEY 和 BOOTSTRAP_TOKEN 为原来的设置
## 完整参数文档 https://docs.jumpserver.org/zh/master/admin-guide/env/

## Docker 镜像配置
# DOCKER_IMAGE_MIRROR=1

## 安装配置
VOLUME_DIR=/opt/jumpserver
SECRET_KEY=
BOOTSTRAP_TOKEN=
LOG_LEVEL=ERROR

##  MySQL 配置, 如果使用外置数据库, 请输入正确的 MySQL 信息
DB_HOST=mysql
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=jumpserver

##  Redis 配置, 如果使用外置数据库, 请输入正确的 Redis 信息
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=

# JumpServer 容器使用的网段, 请勿与现有的网络冲突, 根据实际情况自行修改
DOCKER_SUBNET=192.168.250.0/24

## IPV6 设置, 容器是否开启 ipv6 nat, USE_IPV6=1 表示开启, 为 0 的情况下 DOCKER_SUBNET_IPV6 定义不生效
USE_IPV6=0
DOCKER_SUBNET_IPV6=fc00:1010:1111:200::/64

## 访问配置
HTTP_PORT=80
SSH_PORT=2222
RDP_PORT=3389
MAGNUS_PORTS=30000-30100

## HTTPS 配置, 参考 https://docs.jumpserver.org/zh/master/admin-guide/proxy/ 配置
# HTTPS_PORT=443
# SERVER_NAME=your_domain_name
# SSL_CERTIFICATE=your_cert
# SSL_CERTIFICATE_KEY=your_cert_key

## Nginx 文件上传大小
CLIENT_MAX_BODY_SIZE=4096m

## Task 配置, 是否启动 jms_celery 容器, 单节点必须开启
USE_TASK=1

# Core 配置, Session 定义, SESSION_COOKIE_AGE 表示闲置多少秒后 session 过期, SESSION_EXPIRE_AT_BROWSER_CLOSE=True 表示关闭浏览器即 session 过期
# SESSION_COOKIE_AGE=86400
SESSION_EXPIRE_AT_BROWSER_CLOSE=True

# Koko Lion XRDP 组件配置
CORE_HOST=http://core:8080
JUMPSERVER_ENABLE_FONT_SMOOTHING=True

## 终端使用宿主 HOSTNAME 标识
SERVER_HOSTNAME=${HOSTNAME}

# 额外的配置
CURRENT_VERSION=
```

```
# 安装
./jmsctl.sh install

# 启动
./jmsctl.sh start
```

安装完成后配置文件 /opt/jumpserver/config/config.txt

```
cd /opt/jumpserver-installer-v2.28.8

# 启动
./jmsctl.sh start

# 停止
./jmsctl.sh down

# 卸载
./jmsctl.sh uninstall

# 帮助
./jmsctl.sh -h
```


```
helm repo add jumpserver https://jumpserver.github.io/helm-charts
helm repo list
vi values.yaml
```


```
# 模板 https://github.com/jumpserver/helm-charts/blob/main/charts/jumpserver/values.yaml
# Default values for jumpserver.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

nameOverride: ""
fullnameOverride: ""

## @param global.imageRegistry Global Docker image registry
## @param global.imagePullSecrets Global Docker registry secret names as an array
## @param global.storageClass Global StorageClass for Persistent Volume(s)
## @param global.redis.password Global Redis&trade; password (overrides `auth.password`)
##
global:
  imageRegistry: "docker.io"    # 国内可以使用华为云加速
  imageTag: v2.28.8             # 版本号
  ## E.g.
  #  imagePullSecrets:
  #    - name: harborsecret
  #
  #  storageClass: "jumpserver-data"
  ##
  imagePullSecrets: []
    # - name: yourSecretKey
  storageClass: ""              # (*必填) NFS SC

## Please configure your MySQL server first
## Jumpserver will not start the external MySQL server.
##
externalDatabase:               #  (*必填) 数据库相关设置
  engine: mysql
  host: localhost
  port: 3306
  user: root
  password: ""
  database: jumpserver

## Please configure your Redis server first
## Jumpserver will not start the external Redis server.
##
externalRedis:                  #  (*必填) Redis 设置
  host: localhost
  port: 6379
  password: ""

serviceAccount:
  # Specifies whether a service account should be created
  create: false
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name:

ingress:
  enabled: true                             # 不使用 ingress 可以关闭
  annotations:
    # kubernetes.io/tls-acme: "true"
    compute-full-forwarded-for: "true"
    use-forwarded-headers: "true"
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/configuration-snippet: |
       proxy_set_header Upgrade "websocket";
       proxy_set_header Connection "Upgrade";
  hosts:
    - "test.jumpserver.org"                 # 对外域名
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local

core:
  enabled: true

  labels:
    app.jumpserver.org/name: jms-core

  config:
    # Generate a new random secret key by execute `cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50`
    # secretKey: "B3f2w8P2PfxIAS7s4URrD9YmSbtqX4vXdPUL217kL9XPUOWrmy"
    secretKey: ""                            #  (*必填) 加密敏感信息的 secret_key, 长度推荐大于 50 位
    # Generate a new random bootstrap token by execute `cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`
    # bootstrapToken: "7Q11Vz6R2J6BLAdO"
    bootstrapToken: ""                       #  (*必填) 组件认证使用的 token, 长度推荐大于 24 位
    # Enabled it for debug
    debug: false
    log:
      level: ERROR

  replicaCount: 1

  image:
    registry: docker.io
    repository: jumpserver/core
    tag: v2.28.8
    pullPolicy: IfNotPresent

  command: []

  env:
    # See: https://docs.jumpserver.org/zh/master/admin-guide/env/#core
    SESSION_EXPIRE_AT_BROWSER_CLOSE: true
    # SESSION_COOKIE_AGE: 86400
    # SECURITY_VIEW_AUTH_NEED_MFA: true

  livenessProbe:
    failureThreshold: 30
    httpGet:
      path: /api/health/
      port: web

  readinessProbe:
    failureThreshold: 30
    httpGet:
      path: /api/health/
      port: web

  podSecurityContext: {}
    # fsGroup: 2000

  securityContext: {}
    # capabilities:
    #   drop:
    #   - ALL
    # readOnlyRootFilesystem: true
    # runAsNonRoot: true
    # runAsUser: 1000

  service:
    type: ClusterIP
    web:
      port: 8080
    ws:
      port: 8070

  resources: {}
    # We usually recommend not to specify default resources and to leave this as a conscious
    # choice for the user. This also increases chances charts run on environments with little
    # resources, such as Minikube. If you do want to specify resources, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
    # limits:
    #   cpu: 1000m
    #   memory: 2048Mi
    # requests:
    #   cpu: 500m
    #   memory: 1024Mi

  persistence:
    storageClassName: jumpserver-data
    accessModes:
      - ReadWriteMany
    size: 100Gi
    # annotations: {}
    finalizers:
      - kubernetes.io/pvc-protection
    # subPath: ""
    # existingClaim:

  volumeMounts: []

  volumes: []

  nodeSelector: {}

  tolerations: []

  affinity: {}

koko:
  enabled: true

  labels:
    app.jumpserver.org/name: jms-koko

  config:
    log:
      level: ERROR

  replicaCount: 1

  image:
    registry: docker.io
    repository: jumpserver/koko
    tag: v2.28.8
    pullPolicy: IfNotPresent

  command: []

  env: []
    # See: https://docs.jumpserver.org/zh/master/admin-guide/env/#koko
    # LANGUAGE_CODE: zh
    # REUSE_CONNECTION: true
    # ENABLE_LOCAL_PORT_FORWARD: true
    # ENABLE_VSCODE_SUPPORT: true

  livenessProbe:
    failureThreshold: 30
    httpGet:
      path: /koko/health/
      port: web

  readinessProbe:
    failureThreshold: 30
    httpGet:
      path: /koko/health/
      port: web

  podSecurityContext: {}
    # fsGroup: 2000

  securityContext:
    privileged: true
    # capabilities:
    #   drop:
    #   - ALL
    # readOnlyRootFilesystem: true
    # runAsNonRoot: true
    # runAsUser: 1000

  service:
    type: ClusterIP
    web:
      port: 5000
    ssh:
      port: 2222

  resources: {}
    # We usually recommend not to specify default resources and to leave this as a conscious
    # choice for the user. This also increases chances charts run on environments with little
    # resources, such as Minikube. If you do want to specify resources, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
    # limits:
    #   cpu: 100m
    #   memory: 128Mi
    # requests:
    #   cpu: 100m
    #   memory: 128Mi

  persistence:
    storageClassName: jumpserver-data
    accessModes:
      - ReadWriteMany
    size: 10Gi
    # annotations: {}
    finalizers:
      - kubernetes.io/pvc-protection

  volumeMounts: []

  volumes: []

  nodeSelector: {}

  tolerations: []

  affinity: {}

lion:
  enabled: true

  labels:
    app.jumpserver.org/name: jms-lion

  config:
    log:
      level: ERROR

  replicaCount: 1

  image:
    registry: docker.io
    repository: jumpserver/lion
    tag: v2.28.8
    pullPolicy: IfNotPresent

  command: []

  env:
    # See: https://docs.jumpserver.org/zh/master/admin-guide/env/#lion
    JUMPSERVER_ENABLE_FONT_SMOOTHING: true
    # JUMPSERVER_COLOR_DEPTH: 32
    # JUMPSERVER_ENABLE_WALLPAPER: true
    # JUMPSERVER_ENABLE_THEMING: true
    # JUMPSERVER_ENABLE_FULL_WINDOW_DRAG: true
    # JUMPSERVER_ENABLE_DESKTOP_COMPOSITION: true
    # JUMPSERVER_ENABLE_MENU_ANIMATIONS: true

  livenessProbe:
    failureThreshold: 30
    httpGet:
      path: /lion/health/
      port: web

  readinessProbe:
    failureThreshold: 30
    httpGet:
      path: /lion/health/
      port: web

  podSecurityContext: {}
    # fsGroup: 2000

  securityContext: {}
    # capabilities:
    #   drop:
    #   - ALL
    # readOnlyRootFilesystem: true
    # runAsNonRoot: true
    # runAsUser: 1000

  service:
    type: ClusterIP
    web:
      port: 8081

  resources: {}
    # We usually recommend not to specify default resources and to leave this as a conscious
    # choice for the user. This also increases chances charts run on environments with little
    # resources, such as Minikube. If you do want to specify resources, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
    # limits:
    #   cpu: 100m
    #   memory: 512Mi
    # requests:
    #   cpu: 100m
    #   memory: 512Mi

  persistence:
    storageClassName: jumpserver-data
    accessModes:
      - ReadWriteMany
    size: 50Gi
    # annotations: {}
    finalizers:
      - kubernetes.io/pvc-protection

  volumeMounts: []

  volumes: []

  nodeSelector: {}

  tolerations: []

  affinity: {}

# v2.27.0 版本 magnus 做了大改，需要开放很多端口，等待后续优化
magnus:
  enabled: true

  labels:
    app.jumpserver.org/name: jms-magnus

  config:
    log:
      level: ERROR

  replicaCount: 1

  image:
    registry: docker.io
    repository: jumpserver/magnus
    tag: v2.28.8
    pullPolicy: IfNotPresent

  command: []

  env: []

  livenessProbe:
    failureThreshold: 30
    tcpSocket:
      port: 9090

  readinessProbe:
    failureThreshold: 30
    tcpSocket:
      port: 9090

  podSecurityContext: {}
    # fsGroup: 2000

  securityContext: {}
    # capabilities:
    #   drop:
    #   - ALL
    # readOnlyRootFilesystem: true
    # runAsNonRoot: true
    # runAsUser: 1000

  service:
    type: ClusterIP
      ports: 30000-30100

  resources: {}
    # We usually recommend not to specify default resources and to leave this as a conscious
    # choice for the user. This also increases chances charts run on environments with little
    # resources, such as Minikube. If you do want to specify resources, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
    # limits:
    #   cpu: 100m
    #   memory: 512Mi
    # requests:
    #   cpu: 100m
    #   memory: 512Mi

  persistence:
    storageClassName: jumpserver-data
    accessModes:
      - ReadWriteMany
    size: 10Gi
    # annotations: {}
    finalizers:
      - kubernetes.io/pvc-protection

  volumeMounts: []

  volumes: []

  nodeSelector: {}

  tolerations: []

  affinity: {}

xpack:
  enabled: false      # 企业版本打开此选项

omnidb:
  labels:
    app.jumpserver.org/name: jms-omnidb

  config:
    log:
      level: ERROR

  replicaCount: 1

  image:
    registry: registry.fit2cloud.com
    repository: jumpserver/omnidb
    tag: v2.28.8
    pullPolicy: IfNotPresent

  command: []

  env: []

  livenessProbe:
    failureThreshold: 30
    tcpSocket:
      port: web

  readinessProbe:
    failureThreshold: 30
    tcpSocket:
      port: web

  podSecurityContext: {}
    # fsGroup: 2000

  securityContext: {}
    # capabilities:
    #   drop:
    #   - ALL
    # readOnlyRootFilesystem: true
    # runAsNonRoot: true
    # runAsUser: 1000

  service:
    type: ClusterIP
    web:
      port: 8082

  resources: {}
    # We usually recommend not to specify default resources and to leave this as a conscious
    # choice for the user. This also increases chances charts run on environments with little
    # resources, such as Minikube. If you do want to specify resources, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
    # limits:
    #   cpu: 100m
    #   memory: 128Mi
    # requests:
    #   cpu: 100m
    #   memory: 128Mi

  persistence:
    storageClassName: jumpserver-data
    accessModes:
      - ReadWriteMany
    size: 10Gi
    # annotations: {}
    finalizers:
      - kubernetes.io/pvc-protection

  volumeMounts: []

  volumes: []

  nodeSelector: {}

  tolerations: []

  affinity: {}

razor:
  labels:
    app.jumpserver.org/name: jms-razor

  config:
    log:
      level: ERROR

  replicaCount: 1

  image:
    registry: registry.fit2cloud.com
    repository: jumpserver/razor
    tag: v2.28.8
    pullPolicy: IfNotPresent

  command: []

  env: []

  livenessProbe:
    failureThreshold: 30
    tcpSocket:
      port: rdp

  readinessProbe:
    failureThreshold: 30
    tcpSocket:
      port: rdp

  podSecurityContext: {}
    # fsGroup: 2000

  securityContext: {}
    # capabilities:
    #   drop:
    #   - ALL
    # readOnlyRootFilesystem: true
    # runAsNonRoot: true
    # runAsUser: 1000

  service:
    type: ClusterIP
    rdp:
      port: 3389

  resources: {}
    # We usually recommend not to specify default resources and to leave this as a conscious
    # choice for the user. This also increases chances charts run on environments with little
    # resources, such as Minikube. If you do want to specify resources, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
    # limits:
    #   cpu: 100m
    #   memory: 128Mi
    # requests:
    #   cpu: 100m
    #   memory: 128Mi

  persistence:
    storageClassName: jumpserver-data
    accessModes:
      - ReadWriteMany
    size: 50Gi
    # annotations: {}
    finalizers:
      - kubernetes.io/pvc-protection

  volumeMounts: []

  volumes: []

  nodeSelector: {}

  tolerations: []

  affinity: {}

web:
  enabled: true

  labels:
    app.jumpserver.org/name: jms-web

  replicaCount: 1

  image:
    registry: docker.io
    repository: jumpserver/web
    tag: v2.28.8
    pullPolicy: IfNotPresent

  command: []

  env: []
    # nginx client_max_body_size, default 4G
    # CLIENT_MAX_BODY_SIZE: 4096m

  livenessProbe:
    failureThreshold: 30
    httpGet:
      path: /api/health/
      port: web

  readinessProbe:
    failureThreshold: 30
    httpGet:
      path: /api/health/
      port: web

  podSecurityContext: {}
    # fsGroup: 2000

  securityContext: {}
    # capabilities:
    #   drop:
    #   - ALL
    # readOnlyRootFilesystem: true
    # runAsNonRoot: true
    # runAsUser: 1000

  service:
    type: ClusterIP
    web:
      port: 80

  resources: {}
    # We usually recommend not to specify default resources and to leave this as a conscious
    # choice for the user. This also increases chances charts run on environments with little
    # resources, such as Minikube. If you do want to specify resources, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
    # limits:
    #   cpu: 100m
    #   memory: 128Mi
    # requests:
    #   cpu: 100m
    #   memory: 128Mi

  persistence:
    storageClassName: jumpserver-data
    accessModes:
      - ReadWriteMany
    size: 1Gi
    # annotations: {}
    finalizers:
      - kubernetes.io/pvc-protection

  volumeMounts: []

  volumes: []

  nodeSelector: {}

  tolerations: []

  affinity: {}
```


```
# 安装
helm install jms-k8s jumpserver/jumpserver -n default -f values.yaml

# 卸载
helm uninstall jms-k8s -n default
```


## 离线部署

离线包解压需要 tar 命令, 参考[环境要求](https://docs.jumpserver.org/zh/master/install/setup_by_fast/#_3)手动安装

| OS/Arch | Architecture | Linux Kernel | Offline Name |
| ---|---|---|--- |
| linux/amd64 | x86_64 | >= 4.0 | jumpserver-offline-installer-v2.28.8-amd64-7.tar.gz |
| linux/arm64 | aarch64 | >= 4.0 | jumpserver-offline-installer-v2.28.8-arm64-7.tar.gz |
| linux/loong64 | loongarch64 | == 4.19 | jumpserver-offline-installer-v2.28.8-loong64-7.tar.gz |



linux/amd64linux/arm64linux/loong64

从飞致云社区[下载最新的 linux/amd64 离线包](https://community.fit2cloud.com/#/products/jumpserver/downloads), 并上传到部署服务器的 /opt 目录







```
cd /opt
tar -xf jumpserver-offline-installer-v2.28.8-amd64-7.tar.gz
cd jumpserver-offline-installer-v2.28.8-amd64-7
```





```
# 根据需要修改配置文件模板, 如果不清楚用途可以跳过修改
cat config-example.txt
```





```
# 以下设置如果为空系统会自动生成随机字符串填入
## 迁移请修改 SECRET_KEY 和 BOOTSTRAP_TOKEN 为原来的设置
## 完整参数文档 https://docs.jumpserver.org/zh/master/admin-guide/env/

## Docker 镜像配置
# DOCKER_IMAGE_MIRROR=1

## 安装配置
VOLUME_DIR=/opt/jumpserver
SECRET_KEY=
BOOTSTRAP_TOKEN=
LOG_LEVEL=ERROR

##  MySQL 配置, 如果使用外置数据库, 请输入正确的 MySQL 信息
DB_HOST=mysql
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=jumpserver

##  Redis 配置, 如果使用外置数据库, 请输入正确的 Redis 信息
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=

# JumpServer 容器使用的网段, 请勿与现有的网络冲突, 根据实际情况自行修改
DOCKER_SUBNET=192.168.250.0/24

## IPV6 设置, 容器是否开启 ipv6 nat, USE_IPV6=1 表示开启, 为 0 的情况下 DOCKER_SUBNET_IPV6 定义不生效
USE_IPV6=0
DOCKER_SUBNET_IPV6=fc00:1010:1111:200::/64

## 访问配置
HTTP_PORT=80
SSH_PORT=2222
RDP_PORT=3389
MAGNUS_PORTS=30000-30100

## HTTPS 配置, 参考 https://docs.jumpserver.org/zh/master/admin-guide/proxy/ 配置
# HTTPS_PORT=443
# SERVER_NAME=your_domain_name
# SSL_CERTIFICATE=your_cert
# SSL_CERTIFICATE_KEY=your_cert_key

## Nginx 文件上传大小
CLIENT_MAX_BODY_SIZE=4096m

## Task 配置, 是否启动 jms_celery 容器, 单节点必须开启
USE_TASK=1

# Core 配置, Session 定义, SESSION_COOKIE_AGE 表示闲置多少秒后 session 过期, SESSION_EXPIRE_AT_BROWSER_CLOSE=True 表示关闭浏览器即 session 过期
# SESSION_COOKIE_AGE=86400
SESSION_EXPIRE_AT_BROWSER_CLOSE=True

# Koko Lion XRDP 组件配置
CORE_HOST=http://core:8080
JUMPSERVER_ENABLE_FONT_SMOOTHING=True

## 终端使用宿主 HOSTNAME 标识
SERVER_HOSTNAME=${HOSTNAME}

# 额外的配置
CURRENT_VERSION=
```





```
# 安装
./jmsctl.sh install

# 启动
./jmsctl.sh start
```



安装完成后配置文件 /opt/jumpserver/config/config.txt


```
cd jumpserver-offline-release-v2.28.8-amd64-7

# 启动
./jmsctl.sh start

# 停止
./jmsctl.sh down

# 卸载
./jmsctl.sh uninstall

# 帮助
./jmsctl.sh -h
```


从飞致云社区[下载最新的 linux/arm64 离线包](https://community.fit2cloud.com/#/products/jumpserver/downloads), 并上传到部署服务器的 /opt 目录

```
cd /opt
tar -xf jumpserver-offline-installer-v2.28.8-arm64-7.tar.gz
cd jumpserver-offline-installer-v2.28.8-arm64-7
```


```
# 根据需要修改配置文件模板, 如果不清楚用途可以跳过修改
cat config-example.txt
```


```
# 以下设置如果为空系统会自动生成随机字符串填入
## 迁移请修改 SECRET_KEY 和 BOOTSTRAP_TOKEN 为原来的设置
## 完整参数文档 https://docs.jumpserver.org/zh/master/admin-guide/env/

## Docker 镜像配置
# DOCKER_IMAGE_MIRROR=1

## 安装配置
VOLUME_DIR=/opt/jumpserver
SECRET_KEY=
BOOTSTRAP_TOKEN=
LOG_LEVEL=ERROR

##  MySQL 配置, 如果使用外置数据库, 请输入正确的 MySQL 信息
DB_HOST=mysql
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=jumpserver

##  Redis 配置, 如果使用外置数据库, 请输入正确的 Redis 信息
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=

# JumpServer 容器使用的网段, 请勿与现有的网络冲突, 根据实际情况自行修改
DOCKER_SUBNET=192.168.250.0/24

## IPV6 设置, 容器是否开启 ipv6 nat, USE_IPV6=1 表示开启, 为 0 的情况下 DOCKER_SUBNET_IPV6 定义不生效
USE_IPV6=0
DOCKER_SUBNET_IPV6=fc00:1010:1111:200::/64

## 访问配置
HTTP_PORT=80
SSH_PORT=2222
RDP_PORT=3389
MAGNUS_PORTS=30000-30100

## HTTPS 配置, 参考 https://docs.jumpserver.org/zh/master/admin-guide/proxy/ 配置
# HTTPS_PORT=443
# SERVER_NAME=your_domain_name
# SSL_CERTIFICATE=your_cert
# SSL_CERTIFICATE_KEY=your_cert_key

## Nginx 文件上传大小
CLIENT_MAX_BODY_SIZE=4096m

## Task 配置, 是否启动 jms_celery 容器, 单节点必须开启
USE_TASK=1

# Core 配置, Session 定义, SESSION_COOKIE_AGE 表示闲置多少秒后 session 过期, SESSION_EXPIRE_AT_BROWSER_CLOSE=True 表示关闭浏览器即 session 过期
# SESSION_COOKIE_AGE=86400
SESSION_EXPIRE_AT_BROWSER_CLOSE=True

# Koko Lion XRDP 组件配置
CORE_HOST=http://core:8080
JUMPSERVER_ENABLE_FONT_SMOOTHING=True

## 终端使用宿主 HOSTNAME 标识
SERVER_HOSTNAME=${HOSTNAME}

# 额外的配置
CURRENT_VERSION=
```


```
# 安装
./jmsctl.sh install

# 启动
./jmsctl.sh start
```


安装完成后配置文件 /opt/jumpserver/config/config.txt
```
cd jumpserver-offline-release-v2.28.8-arm64-7

# 启动
./jmsctl.sh start

# 停止
./jmsctl.sh down

# 卸载
./jmsctl.sh uninstall

# 帮助
./jmsctl.sh -h
```


从飞致云社区[下载最新的 linux/loong64 离线包](https://community.fit2cloud.com/#/products/jumpserver/downloads), 并上传到部署服务器的 /opt 目录

```
cd /opt
tar -xf jumpserver-offline-installer-v2.28.8-loong64-7.tar.gz
cd jumpserver-offline-installer-v2.28.8-loong64-7
```


```
# 根据需要修改配置文件模板, 如果不清楚用途可以跳过修改
cat config-example.txt
```

```
# 以下设置如果为空系统会自动生成随机字符串填入
## 迁移请修改 SECRET_KEY 和 BOOTSTRAP_TOKEN 为原来的设置
## 完整参数文档 https://docs.jumpserver.org/zh/master/admin-guide/env/

## Docker 镜像配置
# DOCKER_IMAGE_MIRROR=1

## 安装配置
VOLUME_DIR=/opt/jumpserver
SECRET_KEY=
BOOTSTRAP_TOKEN=
LOG_LEVEL=ERROR

##  MySQL 配置, 如果使用外置数据库, 请输入正确的 MySQL 信息
DB_HOST=mysql
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=jumpserver

##  Redis 配置, 如果使用外置数据库, 请输入正确的 Redis 信息
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=

# JumpServer 容器使用的网段, 请勿与现有的网络冲突, 根据实际情况自行修改
DOCKER_SUBNET=192.168.250.0/24

## IPV6 设置, 容器是否开启 ipv6 nat, USE_IPV6=1 表示开启, 为 0 的情况下 DOCKER_SUBNET_IPV6 定义不生效
USE_IPV6=0
DOCKER_SUBNET_IPV6=fc00:1010:1111:200::/64

## 访问配置
HTTP_PORT=80
SSH_PORT=2222
RDP_PORT=3389
MAGNUS_PORTS=30000-30100

## HTTPS 配置, 参考 https://docs.jumpserver.org/zh/master/admin-guide/proxy/ 配置
# HTTPS_PORT=443
# SERVER_NAME=your_domain_name
# SSL_CERTIFICATE=your_cert
# SSL_CERTIFICATE_KEY=your_cert_key

## Nginx 文件上传大小
CLIENT_MAX_BODY_SIZE=4096m

## Task 配置, 是否启动 jms_celery 容器, 单节点必须开启
USE_TASK=1

# Core 配置, Session 定义, SESSION_COOKIE_AGE 表示闲置多少秒后 session 过期, SESSION_EXPIRE_AT_BROWSER_CLOSE=True 表示关闭浏览器即 session 过期
# SESSION_COOKIE_AGE=86400
SESSION_EXPIRE_AT_BROWSER_CLOSE=True

# Koko Lion XRDP 组件配置
CORE_HOST=http://core:8080
JUMPSERVER_ENABLE_FONT_SMOOTHING=True

## 终端使用宿主 HOSTNAME 标识
SERVER_HOSTNAME=${HOSTNAME}

# 额外的配置
CURRENT_VERSION=
```



```
# 安装
./jmsctl.sh install

# 启动
./jmsctl.sh start
```

安装完成后配置文件 /opt/jumpserver/config/config.txt
```
cd jumpserver-offline-release-v2.28.8-loong64-7

# 启动
./jmsctl.sh start

# 停止
./jmsctl.sh down

# 卸载
./jmsctl.sh uninstall

# 帮助
./jmsctl.sh -h
```


