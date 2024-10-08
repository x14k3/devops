# kubernetes组件

# 控制节点

　　控制平面组件会为集群做出全局决策，比如资源的调度。 以及检测和响应集群事件，例如当不满足部署的 `replicas` 字段时， 要启动新的 pod

　　控制平面组件可以在集群中的任何节点上运行。 然而，为了简单起见，设置脚本通常会在同一个计算机上启动所有控制平面组件， 并且不会在此计算机上运行用户容器。

　　**Pod** 是 Kubernetes 中可部署的最小、最基本对象。一个 Pod 代表集群中正在运行的单个进程实例。

　　Pod 包含一个或多个容器，例如 Docker 容器。当 Pod 运行多个容器时，这些容器将作为一个实体进行管理并共用 Pod 的资源。通常，在单个 Pod 中运行多个容器是一种高级使用场景。

## 1.kube-apiserver

　　API 服务是 Kubernetes 控制平面的组件， 该组件负责公开了 Kubernetes API，是 Kubernetes 控制平面的前端，负责处理接受请求的工作。

　　Kubernetes API 服务器的主要实现是 kube-apiserver。 `kube-apiserver` 设计上考虑了水平扩缩，也就是说，它可通过部署多个实例来进行扩缩。 你可以运行 `kube-apiserver` 的多个实例，并在这些实例之间平衡流量。

## 2.etcd

　　`etcd` 是兼顾一致性与高可用性的键值数据库，可以作为保存 Kubernetes 所有集群数据的后台数据库。

　　你的 Kubernetes 集群的 `etcd` 数据库通常需要有个备份计划。

　　如果想要更深入的了解 `etcd`，请参考 [[../中间件/etcd]]

## 3.kube-scheduler

　　`kube-scheduler` 是控制平面的组件， 负责监视新创建的、未指定运行节点（node）的 Pods， 并选择节点来让 Pod 在上面运行。

　　调度决策考虑的因素包括单个 Pod 及 Pods 集合的资源需求、软硬件及策略约束、 亲和性及反亲和性规范、数据位置、工作负载间的干扰及最后时限。

## 4.kube-controller-manager

　　kube-controller-manager是控制平面的组件， 负责运行控制器进程。

　　从逻辑上讲， 每个控制器都是一个单独的进程， 但是为了降低复杂性，它们都被编译到同一个可执行文件，并在同一个进程中运行。

　　这些控制器包括：

* 节点控制器（Node Controller）：负责在节点出现故障时进行通知和响应
* 任务控制器（Job Controller）：监测代表一次性任务的 Job 对象，然后创建 Pods 来运行这些任务直至完成
* 端点控制器（Endpoints Controller）：填充端点（Endpoints）对象（即加入 Service 与 Pod）
* 服务帐户和令牌控制器（Service Account & Token Controllers）：为新的命名空间创建默认帐户和 API 访问令牌

# Node 组件

　　节点组件会在每个节点上运行，负责维护运行的 Pod 并提供 Kubernetes 运行环境。

## 1.kubelet

　　`kubelet` 会在集群中每个节点（node）上运行。 它保证容器（containers）都运行在 Pod中。

　　kubelet 接收一组通过各类机制提供给它的 PodSpecs， 确保这些 PodSpecs 中描述的容器处于运行状态且健康。 kubelet 不会管理不是由 Kubernetes 创建的容器。

## 2.kube-proxy

　　kube-proxy是集群中每个节点（node）)所上运行的网络代理， 实现 Kubernetes 服务（Service） 概念的一部分。

　　kube-proxy 维护节点上的一些网络规则， 这些网络规则会允许从集群内部或外部的网络会话与 Pod 进行网络通信。

　　如果操作系统提供了可用的数据包过滤层，则 kube-proxy 会通过它来实现网络规则。 否则，kube-proxy 仅做流量转发。

## 3. cni

　　CNI是Container Network Interface的是一个标准的，通用的接口。现在容器平台：docker，kubernetes，mesos，容器网络解决方案：flannel，calico，weave。只要提供一个标准的接口，就能为同样满足该协议的所有容器平台提供网络功能，而CNI正是这样的一个标准接口协议。

### 1.Flannel网络插件

### 2.calico网络插件

# 其他插件（Addons）

## 2.Web 界面（仪表盘）

　　Dashboard是 Kubernetes 集群的通用的、基于 Web 的用户界面。 它使用户可以管理集群中运行的应用程序以及集群本身， 并进行故障排除

## 3.容器资源监控

　　容器资源监控将关于容器的一些常见的时间序列度量值保存到一个集中的数据库中， 并提供浏览这些数据的界面。

## 4.集群层面日志

　　集群层面日志机制负责将容器的日志数据保存到一个集中的日志存储中， 这种集中日志存储提供搜索和浏览接口。
