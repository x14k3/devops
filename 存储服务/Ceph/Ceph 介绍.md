

Ceph 是一个开源的分布式存储系统，提供了对象存储、块存储和文件系统三种存储接口。Ceph 将数据存储在逻辑存储池中，使用 CRUSH 分布式算法决定如何将数据分散存储在集群的各个节点上，以实现高可用性和数据冗余。本文介绍如何使用 Ceph 的对象存储功能。

搭建 Ceph 集群至少要包括一个 MON（Monitor） 节点、一个 MGR（Manager） 节点和多个 OSD（Object Storage Daemon）节点，OSD 节点数量由你要保存的数据副本数量决定，比如你要将数据集存储三份，就需要部署至少三个 OSD 节点。

- OSD（Object Storage Daemon）：负责管理磁盘上的数据块（数据存储、数据复制和数据恢复等），执行数据的读写操作。**确保集群的高可用性，通常至少要部署三个节点。**
- MON（Monitor）：负责维护 Ceph 集群的状态信息、配置信息和映射信息，确保集群元数据的一致性，协调集群节点间数据的分布和恢复。**确保集群的高可用性，通常至少要部署三个节点。**
- MGR（Manager）：负责收集 Ceph 集群的状态信息（OSD、MON、MDS 的性能指标、健康状况等），并提供了可视化的仪表板（Ceph Dashboard）方便用户查看。**确保集群的高可用性，通常至少要部署两个节点。**
- MDS（Metadata Server）：负责管理文件系统的目录结构、文件和目录的元数据信息，为 CephFS（Ceph 的分布式文件系统）提供元数据服务。**块存储和对象存储不需要部署 MDS**。
- RGW（Rados Gateway）：提供了 RESTful API，允许用户发送 HTTP/HTTPS 请求访问和管理存储在 Ceph 集群中的数据，支持 Amazon S3 API 和 OpenStack Swift API。