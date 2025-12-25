
Kubernetes v1.35版本发布，本文梳理十大重点确定性更新，涉及退役功能，以及新增GA的功能。并且，v1.31版本结束支持也已经在 2025-11-11 停止维护。


2025 年 12 月 17 日，主题为 Timbernetes 的 Kubernetes v1.35 正式发布。Timbernetes（世界树）寓意像任何一棵伟大的树一样，Kubernetes 一圈一圈地生长，一版一版地发展，由全球社区的关爱塑造。

本次发布包含 60 项改进，其中 17 项为稳定功能，19 项 Beta 功能，22 项 Alpha 功能。

## Kubernetes版本支持周期[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#kubernetes%e7%89%88%e6%9c%ac%e6%94%af%e6%8c%81%e5%91%a8%e6%9c%9f)

2025年12月状态：

- 当前版本： **Kubernetes v1.35**
- 近期停止维护版本: **Kubernetes v1.31**

| 版本 | 进入维护模式 | 停止维护 | 当前状态 |
| --- | --- | --- | --- |
| v1.35 | 2026-12-28 | 2027-02-28 | 支持中 |
| v1.34 | 2026-08-27 | 2026-10-27 | 支持中 |
| v1.33 | 2026-04-28 | 2026-06-28 | 支持中 |
| v1.32 | 2025-12-28 | 2026-02-28 | 支持中 |
| v1.31 | 2024-09-11 | 2025-11-11 | 停止维护 |
| v1.30 | 2024-05-15 | 2025-07-15 | 停止维护 |
| v1.29 | 2023-12-28 | 2025-02-28 | 停止维护 |

[版本支持周期详情](https://kubernetes.io/zh-cn/releases/patch-releases/#support-period)

## V1.35 十大重点确定性更新[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#v135-%e5%8d%81%e5%a4%a7%e9%87%8d%e7%82%b9%e7%a1%ae%e5%ae%9a%e6%80%a7%e6%9b%b4%e6%96%b0)

完整全量更新的内容，请参考 Kuberentes Github 代码仓库中的[CHANGELOG-1.35.md](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.35.md)说明文件。
完整的发布说明，请查看官方博客[Kubernetes v1.35: Timbernetes](https://kubernetes.io/blog/2025/12/17/kubernetes-v1-35-release/)。

### Ingress-Nginx 退役[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#ingress-nginx-%e9%80%80%e5%bd%b9)

Kubernetes 项目宣布 Ingress NGINX 项目将在2026年3月退役，请选用其他的流量入口网关。
注意⚠️：这不是 Kuberentes 1.35 的功能变化，但是对 Kuberentes 1.35 版本会有重大的影响。

### CgroupV2正式取代CgroupV1[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#cgroupv2%e6%ad%a3%e5%bc%8f%e5%8f%96%e4%bb%a3cgroupv1)

该版本正式移除`cgroup v1`支持，Kubernetes 全面迈入`cgroup v2`版本.
注意⚠️：如果集群中节点存在`cgroup v1`节点，在将 Kubernetes 升级到`v1.35`之前请先将`cgroup v1`节点启用或升级到`cgroup v2`。否则，将无法启动 kubelet。

因此：centos7环境不再建议部署k8s

### 废弃 kube-proxy IPVS 模式[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#%e5%ba%9f%e5%bc%83-kube-proxy-ipvs-%e6%a8%a1%e5%bc%8f)

ipvs 模式已被标记为废弃（Deprecated），推荐迁移至 nftables 模式。
原因是维护难度大，技术债务重。

### 最后支持 containerd v1.X 的版本[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#%e6%9c%80%e5%90%8e%e6%94%af%e6%8c%81-containerd-v1x-%e7%9a%84%e7%89%88%e6%9c%ac)

v1.35是支持`containerd v1.X`系列的最后一个版本，在升级到下一个Kubernetes版本之前，必须切换到`containerd 2.0`或更高版本。

### POD垂直扩缩容不需重启[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#pod%e5%9e%82%e7%9b%b4%e6%89%a9%e7%bc%a9%e5%ae%b9%e4%b8%8d%e9%9c%80%e9%87%8d%e5%90%af)

[KEP 1287](https://kep.k8s.io/1287)在 v1.35 中，Pod 资源原地更新（In-Place Update）正式成为稳定特性（GA）。
之前的版本在进行容器资源配置（如CPU/内存配置）更改时，Kubernetes 集群会自动将容器重新启动， 但是这在有状态的服务 StatefulSet 中或者一些需要持续运行的业务中可能会导致较大的不利影响。
在 v1.35 中，用户可以在不重启 Pod 的前提下动态调整资源请求与限制。

### kubelet 重启时 Pod 稳定性改善[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#kubelet-%e9%87%8d%e5%90%af%e6%97%b6-pod-%e7%a8%b3%e5%ae%9a%e6%80%a7%e6%94%b9%e5%96%84)

[KEP 4781](https://kep.k8s.io/4781)之前 kubelet 重启时，会重置容器状态，导致健康 Pod 被标记为 NotReady 并从负载均衡移除，影响流量。
v1.35 修复此问题，kubelet 启动时正确恢复容器状态，保证工作负载持续 Ready，流量不中断。
### 支持节点级的镜像并行拉取数量配置[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#%e6%94%af%e6%8c%81%e8%8a%82%e7%82%b9%e7%ba%a7%e7%9a%84%e9%95%9c%e5%83%8f%e5%b9%b6%e8%a1%8c%e6%8b%89%e5%8f%96%e6%95%b0%e9%87%8f%e9%85%8d%e7%bd%ae)

[KEP 3673](https://kep.k8s.io/3673)为 kubelet 下载镜像添加节点级限制，以限制并行镜像拉取的数量。超出限制的镜像拉取请求将被阻止，直到一个镜像拉取完成。
这主要是解决节点由于网络或磁盘资源不足时，并行拉取镜像数量太多影响整个节点运行性能和稳定性问题。

### 支持基于时间的镜像清理策略[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#%e6%94%af%e6%8c%81%e5%9f%ba%e4%ba%8e%e6%97%b6%e9%97%b4%e7%9a%84%e9%95%9c%e5%83%8f%e6%b8%85%e7%90%86%e7%ad%96%e7%95%a5)

[KEP 4210](https://kep.k8s.io/4210)支持通过 kubelet 添加一个选项 ImageMaximumGCAge 配置，它允许管理员指定一个时间后，未使用的镜像将被 kubelete 垃圾回收，不管磁盘使用情况如何。
之前的镜像回收主要是通过磁盘的使用率进行判断的，比如设置阈值为80%时开始清理未被使用的镜像。现在支持了基于时间的清理规则。

### kubelet 配置目录的支持[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#kubelet-%e9%85%8d%e7%bd%ae%e7%9b%ae%e5%bd%95%e7%9a%84%e6%94%af%e6%8c%81)

[KEP 3983](https://kep.k8s.io/3983)kubelet 支持通过`--config-dir`的方式配置 kubelet 配置文件，目录将覆盖位于的 kubelet 的配置`/etc/kubernetes/kubelet.conf`

### 本地节点优先路由[](https://cncfstack.com/b/docs/2025/336-k8sv1.25-release/#%e6%9c%ac%e5%9c%b0%e8%8a%82%e7%82%b9%e4%bc%98%e5%85%88%e8%b7%af%e7%94%b1)

[KEP 3015](https://kep.k8s.io/3015)添加一种方法来向 kube-proxy 发出信号，表明它应该尽可能将流量传输到本地端点，以提高效率。