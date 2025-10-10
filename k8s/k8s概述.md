
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

kubectl：Kubernetes集群的命令行接口
API Server：的核心功能是对核心对象（例如：Pod，Service，RC）的增删改查操作，同时也是集群内模块之间数据交换的枢纽
Etcd：包含在 APIServer 中，用来存储资源信息
Controller Manager ：负责维护集群的状态，比如故障检测、自动扩展、滚动更新等
Scheduler**：负责资源的调度，按照预定的调度策略将Pod调度到相应的机器上。可以通过这些有更深的了解：
- [Kubernetes调度机制](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E8%B0%83%E5%BA%A6%E6%9C%BA%E5%88%B6.md)
- [Kubernetes的资源模型与资源管理](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E8%B0%83%E5%BA%A6%E6%9C%BA%E5%88%B6.md#kubernetes%E7%9A%84%E8%B5%84%E6%BA%90%E6%A8%A1%E5%9E%8B%E4%B8%8E%E8%B5%84%E6%BA%90%E7%AE%A1%E7%90%86)
- [Kubernetes默认的调度策略](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E8%B0%83%E5%BA%A6%E6%9C%BA%E5%88%B6.md#kubernetes%E9%BB%98%E8%AE%A4%E7%9A%84%E8%B0%83%E5%BA%A6%E7%AD%96%E7%95%A5)
- [调度器的优先级与强制机制](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E8%B0%83%E5%BA%A6%E6%9C%BA%E5%88%B6.md#%E8%B0%83%E5%BA%A6%E5%99%A8%E7%9A%84%E4%BC%98%E5%85%88%E7%BA%A7%E4%B8%8E%E5%BC%BA%E5%88%B6%E6%9C%BA%E5%88%B6)

**kube-proxy**：负责为Service提供cluster内部的服务发现和负载均衡
**Kubelet**：在Kubernetes中，应用容器彼此是隔离的，并且与运行其的主机也是隔离的，这是对应用进行独立解耦管理的关键点。[Kubelet工作原理解析](https://github.com/ben1234560/k8s_PaaS/blob/master/%E5%8E%9F%E7%90%86%E5%8F%8A%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90/Kubernetes%E8%B0%83%E5%BA%A6%E6%9C%BA%E5%88%B6.md#kubelet)
**Node**：运行容器应用，由Master管理
