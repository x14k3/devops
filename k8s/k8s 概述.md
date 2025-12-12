
- Pod
    - Pod是K8S里能够被运行的最小的逻辑单元（原子单元）
    - 1个Pod里面可以运行多个容器，它们共享UTS+NET+IPC名称空间
    - 可以把Pod理解成豌豆荚，而同一Pod内的每个容器是一颗颗豌豆
    - 一个Pod里运行多个容器，又叫边车（SideCar）模式
- Pod控制器（关于更多[初识Pod](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E5%9F%BA%E6%9C%AC%E6%A6%82%E5%BF%B5.md#%E5%88%9D%E8%AF%86pod)）
    - Pod控制器是Pod启动的一种模板，用来保证在K8S里启动的Pod始终按照人们的预期运行（副本数、生命周期、健康状态检查...）
    - Pod内提供了众多的Pod控制器，常用的有以下几种：
        - Deployment
        - DaemonSet
        - ReplicaSet
        - StatefulSet
        - Job
        - Cronjob
- Name
    - 由于K8S内部，使用“资源”来定义每一种逻辑概念（功能），故每种“资源”，都应该有自己的“名称”
    - “资源”有api版本（apiVersion）类别（kind）、元数据（metadata）、定义清单（spec）、状态（status）等配置信息
    - “名称”通常定义在“资源”的“元数据”信息里
- [namespace](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Docker%E5%9F%BA%E7%A1%80.md#%E5%85%B3%E4%BA%8Enamespace)
    - 随着项目增多、人员增加、集群规模的扩大，需要一种能够隔离K8S内各种“资源”的方法，这就是名称空间
    - 名称空间可以理解为K8S内部的虚拟集群组
    - 不同名称空间内的“资源”名称可以相同，相同名称空间内的同种“资源”、“名称”不能相同
    - 合理的使用K8S名称空间，使得集群管理员能够更好的对交付到K8S里的服务进行分类管理和浏览
    - K8S内默认存在的名称空间有：default、kube-system、kube-public
    - 查询K8S里特定“资源”要带上相应的名称空间
- Label
    - 标签是K8S特色的管理方式，便于分类管理资源对象
    - 一个标签可以对应多个资源，一个资源也可以有多个标签，它们是多对多的关系
    - 一个资源拥有多个标签，可以实现不同维度的管理
    - 标签的组成：key=value
    - 与标签类似的，还有一种“注解”（annotations）
- Label选择器
    - 给资源打上标签后，可以使用标签选择器过滤指定的标签
    - 标签选择器目前有两个：基于等值关系（等于、不等于）和基于集合关系（属于、不属于、存在）
    - 许多资源支持内嵌标签选择器字段
        - matchLabels
        - matchExpressions
- Service
    - 在K8S的世界里，虽然每个Pod都会被分配一个单独的IP地址，但这个IP地址会随着Pod的销毁而消失
    - Service（服务）就是用来解决这个问题的核心概念
    - 一个Service可以看作一组提供相同服务的Pod的对外访问接口
    - Service作用与哪些Pod是通过标签选择器来定义的
- Ingress
    - Ingress是K8S集群里工作在OSI网络参考模型下，第7层的应用，对外暴露的接口
    - Service只能进行L4流量调度，表现形式是ip+port
    - Ingress则可以调度不同业务域、不同URL访问路径的业务流量

简单理解：Pod可运行的原子，name定义名字，namespace名称空间（放一堆名字），label标签（另外的名字），service提供服务，ingress通信

### K8S架构图

![[assets/1582188308711.png]]


- API Server：对核心对象（例如：Pod，Service，RC）的增删改查操作，同时也是集群内模块之间数据交换的枢纽

- Etcd：用于存储 Kubernetes 的所有集群数据，如节点信息、Pod 状态、Secrets、ConfigMaps 等。

- Controller Manager ：负责维护集群的状态，比如故障检测、自动扩展、滚动更新等

- Scheduler：监听 API Server 新创建的、尚未分配节点的 Pod，并根据调度策略（如资源请求、亲和性/反亲和性、数据位置等）为其选择一个最合适的 Worker Node。它只做调度决策，不实际执行 Pod 的创建。

- kube-proxy：通过 `iptables` 或 `ipvs` 模式，将发往 Service VIP（虚拟 IP）的流量转发到后端正确的 Pod 上。实现服务发现和负载均衡。

- Kubelet：- 与 API Server 通信，接收 Pod 定义。管理本节点上 Pod 的生命周期（创建、启动、停止、重启容器）。

- kubectl：Kubernetes集群的命令行接口

- Node（容器运行时）：下载容器镜像、创建容器命名空间、隔离资源、运行应用等。
