#middleware/fastdfs

FastDFS是一个开源的轻量级分布式文件系统，它对文件进行管理，功能包括：文件存储、文件同步、文件访问（文件上传、文件下载）等，解决了大容量存储和负载均衡的问题。

[fastdfs 单机部署](fastdfs%20单机部署.md "fastdfs单机部署")

[fastdfs 集群部署](fastdfs%20集群部署.md "fastdfs集群")

FastDFS 系统有三个角色：跟踪服务器(Tracker Server)、存储服务器(Storage Server)和客户端(Client)。

> **Tracker Server**：跟踪服务器，主要做调度工作，起到均衡的作用；负责管理所有的 storage server和 group，每个 storage 在启动后会连接 Tracker，告知自己所属 group 等信息，并保持周期性心跳。

> **Storage Server**：存储服务器，主要提供容量和备份服务；以 group 为单位，每个 group 内可以有多台 storage server，数据互为备份。

> **Client**：客户端，上传下载数据的服务器，也就是我们自己的项目所部署在的服务器。

![](assets/fastdfs%20概述/image-20221127213345441.png)

![](assets/fastdfs%20概述/image-20221127213351374.png)


1.定时向tracker上传状态信息

2.client上传连接请求

3.tracker查询可用storage

4.tracker返回storage的ip和port

5.client上传文件

6.storage生成file\_id ，并将上传内容写入到磁盘

7.返回file\_id给client

8.client存储file\_id到本地
