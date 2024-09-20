# ip neighbour

　　ip neighbour–neighbour/arp表管理命令  
缩写 neighbour、neighbor、neigh、n

　　命令 add、change、replace、delete、fulsh、show(或者list)

## ip neighbour add

　　添加一个新的邻接条目

```bash
ip neighbour change        # 修改一个现有的条目
ip neighbour replace       # 替换一个已有的条目

# 示例1: 在设备eth0上，为地址10.0.0.3添加一个permanent ARP条目：
ip neigh add 10.0.0.3 lladdr 0:0:0:0:0:1 dev eth0 nud perm

# 示例2:把状态改为reachable
ip neigh chg 10.0.0.3 dev eth0 nud reachable
```

　　‍

## ip neighbour delete

　　删除一个邻接条目

```bash
# 示例1:删除设备eth0上的一个ARP条目10.0.0.3
ip neigh del 10.0.0.3 dev eth0
```

## ip neighbour show

　　显示网络邻居的信息.　

```bash
ip -s n ls 193.233.7.254

193.233.7.254. dev eth0 lladdr 00:00:0c:76:3f:85 ref 5 used 12/13/20 nud reachable
```

　　‍

## ip neighbour flush

　　清除邻接条目.

```bash
ip -s -s n f 193.233.7.254
```

　　‍
