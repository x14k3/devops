# kubernetes架构

# 1. Kubernetes的总架构图

![](assets/image-20230315180737689-20230610173809-749ff5n.png)​

# 2. Kubernetes各个组件介绍

## 2.1 kube-master[控制节点]

**master的工作流程图**

![](assets/image-20230315180904500-20230610173809-t2pqh2c.png)

1. Kubecfg将特定的请求，比如创建Pod，发送给Kubernetes Client。
2. Kubernetes Client将请求发送给API server。
3. API Server根据请求的类型，比如创建Pod时storage类型是pods，然后依此选择何种REST Storage API对请求作出处理。
4. REST Storage API对的请求作相应的处理。
5. 将处理的结果存入高可用键值存储系统Etcd中。
6. 在API Server响应Kubecfg的请求后，Scheduler会根据Kubernetes Client获取集群中运行Pod及Minion/Node信息。
7. 依据从Kubernetes Client获取的信息，Scheduler将未分发的Pod分发到可用的Minion/Node节点上。

### 2.1.1 API Server[资源操作入口]

1. 提供了资源对象的唯一操作入口，其他所有组件都必须通过它提供的API来操作资源数据，只有API Server与存储通信，其他模块通过API Server访问集群状态。

   第一，是为了保证集群状态访问的安全。

   第二，是为了隔离集群状态访问的方式和后端存储实现的方式：API Server是状态访问的方式，不会因为后端存储技术etcd的改变而改变。
2. 作为kubernetes系统的入口，封装了核心对象的增删改查操作，以RESTFul接口方式提供给外部客户和内部组件调用。对相关的资源数据“全量查询”+“变化监听”，实时完成相关的业务功能。

### 2.1.2 Controller Manager[内部管理控制中心]

1. 实现集群故障检测和恢复的自动化工作，负责执行各种控制器，主要有：
   - endpoint-controller：定期关联service和pod(关联信息由endpoint对象维护)，保证service到pod的映射总是最新的。
   - replication-controller：定期关联replicationController和pod，保证replicationController定义的复制数量与实际运行pod的数量总是一致的。

### 2.1.3 Scheduler[集群分发调度器]

1. Scheduler收集和分析当前Kubernetes集群中所有Minion/Node节点的资源(内存、CPU)负载情况，然后依此分发新建的Pod到Kubernetes集群中可用的节点。
2. 实时监测Kubernetes集群中未分发和已分发的所有运行的Pod。
3. Scheduler也监测Minion/Node节点信息，由于会频繁查找Minion/Node节点，Scheduler会缓存一份最新的信息在本地。
4. 最后，Scheduler在分发Pod到指定的Minion/Node节点后，会把Pod相关的信息Binding写回API Server。

### 2.1.4 etcd

`etcd` 是兼顾一致性与高可用性的键值数据库，可以作为保存 Kubernetes 所有集群数据的后台数据库。

你的 Kubernetes 集群的 `etcd` 数据库通常需要有个备份计划。

如果想要更深入的了解 `etcd`，请参考 [etcd](../中间件/etcd.md)

## 2.2 kube-node[服务节点]

**kubelet结构图**

![](assets/image-20230315184215045-20230610173809-voujb6l.png)

### 2.2.1 Kubelet[节点上的Pod管家]

1. 负责Node节点上pod的创建、修改、监控、删除等全生命周期的管理
2. 定时上报本Node的状态信息给API Server。
3. kubelet是Master API Server和Minion/Node之间的桥梁，接收Master API Server分配给它的commands和work，通过kube-apiserver间接与Etcd集群交互，读取配置信息。
4. 具体的工作如下：
   1) 设置容器的环境变量、给容器绑定Volume、给容器绑定Port、根据指定的Pod运行一个单一容器、给指定的Pod创建network 容器。
   2) 同步Pod的状态、同步Pod的状态、从cAdvisor获取container info、 pod info、 root info、 machine info。
   3) 在容器中运行命令、杀死容器、删除Pod的所有容器。

### 2.2.2 Proxy[负载均衡、路由转发]

1. Proxy是为了解决外部网络能够访问跨机器集群中容器提供的应用服务而设计的，运行在每个Minion/Node上。Proxy提供TCP/UDP sockets的proxy，每创建一种Service，Proxy主要从etcd获取Services和Endpoints的配置信息（也可以从file获取），然后根据配置信息在Minion/Node上启动一个Proxy的进程并监听相应的服务端口，当外部请求发生时，Proxy会根据Load Balancer将请求分发到后端正确的容器处理。
2. Proxy不但解决了同一主宿机相同服务端口冲突的问题，还提供了Service转发服务端口对外提供服务的能力，Proxy后端使用了随机、轮循负载均衡算法。

### 2.2.3 kubectl[集群管理命令行工具集]

1. 通过客户端的kubectl命令集操作，API Server响应对应的命令结果，从而达到对kubernetes集群的管理。

# 3. kubernetes常用对象说明

## 3.1. Master

集群的控制节点，负责整个集群的管理和控制，kubernetes的所有的命令基本都是发给Master，由它来负责具体的执行过程。

### 3.1.1 Master的组件

- kube-apiserver：资源增删改查的入口
- kube-controller-manager：资源对象的大总管
- kube-scheduler：负责资源调度（Pod调度）
- etcd Server:kubernetes的所有的资源对象的数据保存在etcd中。

## 3.2 Node

Node是集群的工作负载节点，默认情况kubelet会向Master注册自己，一旦Node被纳入集群管理范围，kubelet会定时向Master汇报自身的情报，包括操作系统，Docker版本，机器资源情况等。

如果Node超过指定时间不上报信息，会被Master判断为“失联”，标记为Not Ready，随后Master会触发Pod转移。

### 3.2.1 Node的组件

- kubelet:Pod的管家，与Master通信
- kube-proxy：实现kubernetes Service的通信与负载均衡机制的重要组件
- Docker：容器的创建和管理

### 3.2.2 Node相关命令

```bash
kubectl get nodes
kuebctl describe node {node_name}
```

## 3.3 Pod

Pod是Kubernetes中操作的基本单元。每个Pod中有个根容器(Pause容器)，Pause容器的状态代表整个容器组的状态，其他业务容器共享Pause的IP，即Pod IP，共享Pause挂载的Volume，这样简化了同个Pod中不同容器之间的网络问题和文件共享问题。

![](assets/image-20230315185158182-20230610173809-ovixzx4.png)

1. Kubernetes集群中，同宿主机的或不同宿主机的Pod之间要求能够TCP/IP直接通信，因此采用虚拟二层网络技术来实现，例如Flannel，Openvswitch(OVS)等，这样在同个集群中，不同的宿主机的Pod IP为不同IP段的IP，集群中的所有Pod IP都是唯一的，不同Pod之间可以直接通信。
2. Pod有两种类型：普通Pod和静态Pod。静态Pod即不通过K8S调度和创建，直接在某个具体的Node机器上通过具体的文件来启动。普通Pod则是由K8S创建、调度，同时数据存放在ETCD中。
3. Pod IP和具体的容器端口（ContainnerPort）组成一个具体的通信地址，即Endpoint。一个Pod中可以存在多个容器，可以有多个端口，Pod IP一样，即有多个Endpoint。
4. Pod Volume是定义在Pod之上，被各个容器挂载到自己的文件系统中，可以用分布式文件系统实现后端存储功能。
5. Pod中的Event事件可以用来排查问题，可以通过kubectl describe pod xxx 来查看对应的事件。
6. 每个Pod可以对其能使用的服务器上的计算资源设置限额，一般为CPU和Memory。K8S中一般将千分之一个的CPU配置作为最小单位，用m表示，是一个绝对值，即100m对于一个Core的机器还是48个Core的机器都是一样的大小。Memory配额也是个绝对值，单位为内存字节数。
7. 资源配额的两个参数
8. Requests:该资源的最小申请量，系统必须满足要求。
9. Limits:该资源最大允许使用量，当超过该量，K8S会kill并重启Pod。

![](assets/image-20230315185224182-20230610173809-zsdt879.png)

## 3.4 Label

1. Label是一个键值对，可以附加在任何对象上，比如Node,Pod,Service,RC等。Label和资源对象是多对多的关系，即一个Label可以被添加到多个对象上，一个对象也可以定义多个Label。
2. Label的作用主要用来实现精细的、多维度的资源分组管理，以便进行资源分配，调度，配置，部署等工作。
3. Label通俗理解就是“标签”，通过标签来过滤筛选指定的对象，进行具体的操作。k8s通过Label Selector(标签选择器)来筛选指定Label的资源对象，类似SQL语句中的条件查询（WHERE语句）。
4. Label Selector有基于等式和基于集合的两种表达方式，可以多个条件进行组合使用。
5. 基于等式：name=redis-slave（匹配name=redis-slave的资源对象）;env!=product(匹配所有不具有标签env=product的资源对象)
6. 基于集合：name in (redis-slave,redis-master);name not in (php-frontend)（匹配所有不具有标签name=php-frontend的资源对象）

**使用场景**

1. kube-controller进程通过资源对象RC上定义的Label Selector来筛选要监控的Pod副本数，从而实现副本数始终保持预期数目。
2. kube-proxy进程通过Service的Label Selector来选择对应Pod，自动建立每个Service到对应Pod的请求转发路由表，从而实现Service的智能负载均衡机制。
3. kube-scheduler实现Pod定向调度：对Node定义特定的Label，并且在Pod定义文件中使用NodeSelector标签调度策略。

## 3.5 Replication Controller(RC)

RC是k8s系统中的核心概念，定义了一个期望的场景。

主要包括：

- Pod期望的副本数（replicas）
- 用于筛选目标Pod的Label Selector
- 用于创建Pod的模板（template）

RC特性说明：

1. Pod的缩放可以通过以下命令实现：kubectl scale rc redis-slave --replicas=3
2. 删除RC并不会删除该RC创建的Pod，可以将副本数设置为0，即可删除对应Pod。或者通过kubectl stop /delete命令来一次性删除RC和其创建的Pod。
3. 改变RC中Pod模板的镜像版本可以实现滚动升级（Rolling Update）。具体操作见[https://kubernetes.io/docs/tasks/run-application/rolling-update-replication-controller/](https://kubernetes.io/docs/tasks/run-application/rolling-update-replication-controller/)
4. Kubernetes1.2以上版本将RC升级为Replica Set，它与当前RC的唯一区别在于Replica Set支持基于集合的Label Selector(Set-based selector)，而旧版本RC只支持基于等式的Label Selector(equality-based selector)。
5. Kubernetes1.2以上版本通过Deployment来维护Replica Set而不是单独使用Replica Set。即控制流为：Delpoyment→Replica Set→Pod。即新版本的Deployment+Replica Set替代了RC的作用。

## 3.6 Deployment

Deployment是kubernetes 1.2引入的概念，用来解决Pod的编排问题。Deployment可以理解为RC的升级版（RC+Reolicat Set）。特点在于可以随时知道Pod的部署进度，即对Pod的创建、调度、绑定节点、启动容器完整过程的进度展示。

**使用场景**

1. 创建一个Deployment对象来生成对应的Replica Set并完成Pod副本的创建过程。
2. 检查Deployment的状态来确认部署动作是否完成（Pod副本的数量是否达到预期值）。
3. 更新Deployment以创建新的Pod(例如镜像升级的场景)。
4. 如果当前Deployment不稳定，回退到上一个Deployment版本。
5. 挂起或恢复一个Deployment。

可以通过kubectl describe deployment来查看Deployment控制的Pod的水平拓展过程。

## 3.7 Horizontal Pod Autoscaler(HPA)

Horizontal Pod Autoscaler(HPA)即Pod横向自动扩容，与RC一样也属于k8s的资源对象。

HPA原理：通过追踪分析RC控制的所有目标Pod的负载变化情况，来确定是否针对性调整Pod的副本数。

Pod负载度量指标：

- CPUUtilizationPercentage：Pod所有副本自身的CPU利用率的平均值。即当前Pod的CPU使用量除以Pod Request的值。
- 应用自定义的度量指标，比如服务每秒内响应的请求数（TPS/QPS）。

## 3.8 Service(服务)

![](assets/image-20230315185401314-20230610173809-0uas2eu.png)

Service定义了一个服务的访问入口地址，前端应用通过这个入口地址访问其背后的一组由Pod副本组成的集群实例，Service与其后端的Pod副本集群之间是通过Label Selector来实现“无缝对接”。RC保证Service的Pod副本实例数目保持预期水平。

### 3.8.1 kubernetes的服务发现机制

主要通过kube-dns这个组件来进行DNS方式的服务发现。

### 3.8.2 外部系统访问Service的问题

|IP 类型|说明|
| ----------| ----------------|
|Node IP|Node节点的IP地址|
|Pod IP|Pod的IP地址|
|Cluster IP|Service的IP地址|

***Node IP***
NodeIP是集群中每个节点的物理网卡IP地址，是真实存在的物理网络，kubernetes集群之外的节点访问kubernetes内的某个节点或TCP/IP服务的时候，需要通过NodeIP进行通信。

_**Pod IP** _
Pod IP是每个Pod的IP地址，是Docker Engine根据docker0网桥的IP段地址进行分配的，是一个虚拟二层网络，集群中一个Pod的容器访问另一个Pod中的容器，是通过Pod IP进行通信的，而真实的TCP/IP流量是通过Node IP所在的网卡流出的。

***Cluster IP***

1. Service的Cluster IP是一个虚拟IP，只作用于Service这个对象，由kubernetes管理和分配IP地址（来源于Cluster IP地址池）。
2. Cluster IP无法被ping通，因为没有一个实体网络对象来响应。
3. Cluster IP结合Service Port组成的具体通信端口才具备TCP/IP通信基础，属于kubernetes集群内，集群外访问该IP和端口需要额外处理。
4. k8s集群内Node IP 、Pod IP、Cluster IP之间的通信采取k8s自己的特殊的路由规则，与传统IP路由不同。

### 3.8.3 外部访问Kubernetes集群

通过宿主机与容器端口映射的方式进行访问，例如：Service定位文件如下：

可以通过任意Node的IP 加端口访问该服务。也可以通过Nginx或HAProxy来设置负载均衡。

## 3.9 Volume(存储卷)

### 3.9.1 Volume的功能

1. Volume是Pod中能够被多个容器访问的共享目录，可以让容器的数据写到宿主机上或者写文件到网络存储中
2. 可以实现容器配置文件集中化定义与管理，通过ConfigMap资源对象来实现。

### 3.9.2 Volume的特点

k8s中的Volume与Docker的Volume相似，但不完全相同。

1. k8s上Volume定义在Pod上，然后被一个Pod中的多个容器挂载到具体的文件目录下。
2. k8s的Volume与Pod生命周期相关而不是容器是生命周期，即容器挂掉，数据不会丢失但是Pod挂掉，数据则会丢失。
3. k8s中的Volume支持多种类型的Volume：Ceph、GlusterFS等分布式系统。

### 3.9.3 Volume的使用方式

先在Pod上声明一个Volume，然后容器引用该Volume并Mount到容器的某个目录。

### 3.9.4 Volume类型

#### emptyDir

emptyDir Volume是在Pod分配到Node时创建的，初始内容为空，无须指定宿主机上对应的目录文件，由K8S自动分配一个目录，当Pod被删除时，对应的emptyDir数据也会永久删除。

**作用**：

1. 临时空间，例如程序的临时文件，无须永久保留
2. 长时间任务的中间过程CheckPoint的临时保存目录
3. 一个容器需要从另一个容器中获取数据的目录（即多容器共享目录）

**说明**：

目前用户无法设置emptyVolume的使用介质，如果kubelet的配置使用硬盘则emptyDir将创建在该硬盘上。

#### hostPath

hostPath是在Pod上挂载宿主机上的文件或目录。

**作用**：

1. 容器应用日志需要持久化时，可以使用宿主机的高速文件系统进行存储
2. 需要访问宿主机上Docker引擎内部数据结构的容器应用时，可以通过定义hostPath为宿主机/var/lib/docker目录，使容器内部应用可以直接访问Docker的文件系统。

**注意点：**

1. 在不同的Node上具有相同配置的Pod可能会因为宿主机上的目录或文件不同导致对Volume上目录或文件的访问结果不一致。
2. 如果使用了资源配额管理，则kubernetes无法将hostPath在宿主机上使用的资源纳入管理。

#### gcePersistentDisk

表示使用谷歌公有云提供的永久磁盘（Persistent Disk ,PD）存放Volume的数据，它与EmptyDir不同，PD上的内容会被永久保存。当Pod被删除时，PD只是被卸载时，但不会被删除。需要先创建一个永久磁盘，才能使用gcePersistentDisk。

使用gcePersistentDisk的限制条件：

- Node(运行kubelet的节点)需要是GCE虚拟机。
- 虚拟机需要与PD存在于相同的GCE项目中和Zone中。

## 3.10 Persistent Volume

Volume定义在Pod上，属于“计算资源”的一部分，而Persistent Volume和Persistent Volume Claim是网络存储，简称PV和PVC，可以理解为k8s集群中某个网络存储中对应的一块存储。

- PV是网络存储，不属于任何Node，但可以在每个Node上访问。
- PV不是定义在Pod上，而是独立于Pod之外定义。
- PV常见类型：GCE Persistent Disks、NFS、RBD等。

PV是有状态的对象，状态类型如下：

- Available:空闲状态
- Bound:已经绑定到某个PVC上
- Released:对应的PVC已经删除，但资源还没有回收
- Failed:PV自动回收失败

## 3.11 Namespace

Namespace即命名空间，主要用于多租户的资源隔离，通过将资源对象分配到不同的Namespace上，便于不同的分组在共享资源的同时可以被分别管理。

k8s集群启动后会默认创建一个“default”的Namespace。可以通过kubectl get namespaecs查看。

可以通过kubectl config use-context `namespace`配置当前k8s客户端的环境，通过kubectl get pods获取当前namespace的Pod。或者通过kubectl get pods --namespace=`NAMESPACE`来获取指定namespace的Pod。

## 3.12 Annotation(注解)

Annotation与Label类似，也使用key/value的形式进行定义，Label定义元数据（Metadata）,Annotation定义“附加”信息。

通常Annotation记录信息如下：

- build信息，release信息，Docker镜像信息等。
- 日志库、监控库等。
