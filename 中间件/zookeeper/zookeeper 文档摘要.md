

分布式共识一直以来是被广泛讨论的话题，每一个分布式系统都会涉及到“共识问题”——对某一个值或者状态达成共识。有些中间件（例如redis）自己写了分布式共识的实现方式，有些（例如kafka）则直接利用zookeeper或者etcd解决共识问题。在java的生态环境中，zookeeper是分布式共识的实际标准，这边博文就来了解下zookeeper相关的知识。

zookeeper的自我定位：协调分布式应用的组件。他把分布式应用必做一个动物园，而自己则是动物园的keeper。zookeeper提供了一套简单的指令，分布式系统可以基于此实现更高等级的功能，例如：同步，分布式配置，分组，命名服务。分布式共识比较难实现，而zookeeper的目的就是让大家不需要自己造分布式共识的轮子。

## 设计目标

- simple 类似文件系统的层级关系。基于内存——高吞吐、低延迟
- replicated 数据有多副本——高可用。node保存状态、transaction log、快照
- orderd 用ID标记每一次变更（transaction），这种顺序可以用来实现更高的抽象，例如同步原语。
- fast 适合读多写少的应用，例如读写比10:1，读写比越高性能越好。10:1以下不建议使用

## 数据模型和层级的命名空间

zookeeper的命名空间很像文件系统，一个znode的路径是以“/”分割的name组成的。与文件系统不同的是，一个znode既是“文件”又是“文件夹”，既可以包含数据，又可以有子节点。因为zookeeper是涉及来保存协作信息的，所以节点下的信息通常比较小，例如状态、配置、location这些，大约都在nb-nkb范围内。
znode的数据结构包含版本号（标识数据变更、ACL变更、时间戳），以此实现缓存验证和协作更新（达成共识）。每次数据变更，这个版本号会增加。获取数据时，会同时获取版本号。
读写单个znode的数据是原子的，要么读写所有数据，要么全部失败。每个znode都有一个ACL（Access Controll list）控制哪些客户端能做什么。
zookeeper也有临时节点，临时节点的生命周期在与客户端session断开的时候结束，并被删除

## watch机制

支持watch机制，当数据变更时，zookeeper可以向client发送变更通知，然后删除这个watch。如果client和zookeeper断开，client会收到一个通知。

3.6版本后：

- watch可以是永久的：发送变更，并且不删除这个watch
- watch可以是递归的：监听该znode及其任何子节点的变化

## 承诺

- 顺序一致性：client发来的变更会顺序地生效
- 原子的： updates要么全部成功，要么全部失败
- 单一系统镜像： 一个client如果连接断开，连上新的zookeeper，看到的东西也是一样的
- 可靠的： 一旦update被采纳，不会丢失直到有新的update
- 及时性：update被采纳的延时不会很长，保证client能及时地看到最新的数据

## 简单的api

- create : creates a node at a location in the tree
- delete : deletes a node
- exists : tests if a node exists at a location
- get data : reads the data from a node
- set data : writes data to a node
- get children : retrieves a list of children of a node
- sync : waits for data to be propagated

## 开发者指南

[zookeeperProgrammers.html](https://zookeeper.apache.org/doc/r3.6.2/zookeeperProgrammers.html)

## PAXOS两阶段提交

```bash
# 正常流程
prepare(N)  # N>任何n
promise(N,n,v)

propose(N,?) # 如果上面的v！=null，取上面的v；如果v==null，可以自定义
accept(N,?)
```
