
## **获取MinIO Client（mc）**

#### **docker版**

```shell
docker pull minio/mc
docker run minio/mc ls play
```

#### **Homebrew (macOS)**

使用[Homebrew](http://brew.sh/)安装mc。

```shell
brew install minio/stable/mc
mc --help
```

#### 下载二进制文件(GNU/Linux)

```shell
wget http://dl.minio.org.cn/client/mc/release/linux-amd64/mc
chmod +x mc 
./mc --help
```

#### **下载二进制文件(Microsoft Windows)**

[http://dl.minio.org.cn/client/mc/release/windows-amd64/mc.exe](http://dl.minio.org.cn/client/mc/release/windows-amd64/mc.exe)

#### **通过源码安装**

通过源码安装仅适用于开发人员和高级用户。`mc update`命令不支持基于源码安装的更新通知。请从[minio-client](https://min.io/download/#minio-client)下载官方版本。
深入探索Miniolinux我的世界GNU/Linuxmc安装clientminiowindowsHomebrew
需要有Golang环境

```shell
go get -d github.com/minio/mc
cd ${GOPATH}/src/github.com/minio/mc
make
```



## mc常用命令

```shell
ls       列出文件和文件夹。
mb       创建一个存储桶或一个文件夹。
cat      显示文件和对象内容。
pipe     将一个STDIN重定向到一个对象或者文件或者STDOUT。
share    生成用于共享的URL。
cp       拷贝文件和对象。
mirror   给存储桶和文件夹做镜像。
find     基于参数查找文件。
diff     对两个文件夹或者存储桶比较差异。
rm       删除文件和对象。
events   管理对象通知。
watch    监视文件和对象的事件。
policy   管理访问策略。
config   管理mc配置文件。
update   检查软件更新。
version  输出版本信息。
```

## 迁移数据

#### 概述

老版本minio的api地址是 172.20.10.2:9000
新版本minio的api地址是 172.20.10.2:9002
深入探索MinioMinIOls安装软件ClientGNU/Linuxwindowslinux我的世界


#### **通过mc命令连接两个minio服务**

```shell
mc alias set old http://172.20.10.2:9000 adminminio adminminio
mc alias set new http://172.20.10.2:9002 adminminio adminminio
```

> mc alise set 名称 服务地址 用户名 密码
> 这里一个叫old  一个叫new

#### **迁移数据**

- 全量迁移,重名文件不覆盖,bucket不存在会自动创建
```shell
mc mirror old new
```

- 只是迁移某个bucket,以test为例,目标的bucket需要提前建好（此处假如桶为test）
```shell
mc mirror old/test new/test
```

- 覆盖重名文件,加--overwrite
```shell
mc mirror --overwrite old/test new/test
```

根据实际需求选择以上任意方式迁移即可



