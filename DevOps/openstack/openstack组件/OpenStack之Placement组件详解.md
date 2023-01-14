#devops/openstack

# 一、作用

Placement服务跟踪资源（比如计算节点，存储资源池，网络资源池等）的使用情况，提供自定义资源的能力，为分配资源提供服务。

Placement服务是从 S 版本，从nova服务中拆分出来的组件，作用是收集各个node节点的可用资源，把node节点的资源统计写入到mysql,Placement服务会被nova scheduler服务进行调用 Placement服务的监听端口是8778

# 二、基本概念

**Resource Provider**：资源提供者，实际提供资源的实体，例如：Compute Node、Storage Pool、IP Pool 等。

**Resource Class**：资源种类，即资源的类型，Placement 为 Compute Node 缺省了下列几种类型，同时支持 Custom Resource Classes。

**Inventory**：资源清单，资源提供者所拥有的资源清单，例如：Compute Node 拥有的 vCPU、Disk、RAM 等 inventories。

**Provider Aggregate**：资源聚合，类似 HostAggregate 的概念，是一种聚合类型。

**Traits**：资源特征，不同资源提供者可能会具有不同的资源特征。Traits 作为资源提供者特征的描述，它不能够被消费，但在某些 Workflow 或者会非常有用。例如：标识可用的 Disk 具有 SSD 特征，有助于 Scheduler 灵活匹配 Launch Instance 的请求。

**Resource Allocations**：资源分配状况，包含了 Resource Class、Resource Provider 以及 Consumer 的映射关系。记录消费者使用了该类型资源的数量。

# 三、数据模型解析 

**Data Models**：

*   `ResourceProvider`：资源提供者

*   `Inventory`：资源提供者的资源清单

*   `ResourceClass`：资源种类

*   `ResourceProviderAggregate`：资源聚合，实际上是资源提供者和主机聚合的映射关系

*   `Trait`：资源特征描述类型

*   `ResourceProviderTrait`：资源提供者和特征描述的对应关系

*   `Allocation`：分配给消费者的资源状况

*   `Consumer`：消费者，本质是一串 UUID

*   `User`：Keystone User
