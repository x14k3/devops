# jdk

|版本|major版本号|
| --------| -------------|
|JDK 17|61|
|JDK 16|60|
|JDK 15|59|
|JDK 14|58|
|JDK 13|57|
|JDK 12|56|
|JDK 11|55|
|JDK 10|54|
|JDK 9|53|
|JDK 8|52|
|JDK 7|51|
|JDK 6|50|
|JDK 5|49|
|JDK 4|48|
|JDK 3|47|
|JDK 2|46|
|JDK 1|45|

　　‍

# jdk 部署

```bash
wget https://mirrors.huaweicloud.com/java/jdk/8u192-b12/jdk-8u192-linux-x64.tar.gz
mkdir -p /usr/local/java
tar -zxf jdk-8u192-linux-x64.tar.gz -C /usr/local/java
#配置环境变量
cat <<EOF>> /etc/profile
export JAVA_HOME=/usr/local/java/jdk1.8.0_192
export JRE_HOME=\${JAVA_HOME}/jre
export CLASSPATH=\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=$PATH:\$JAVA_HOME/bin
EOF

source /etc/profile
#验证JDK
java -version
```

# jdk 调优入门

　　首先以java8 默认的cms为例，机器是2G内存。

　　先看GC日志，设置jvm参数如下，其他堆大小相关参数都没有设置：

```bash
gc_option='-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintHeapAtGC -Xloggc:gc.log'
```

　　这会把gc信息打印到jvm进程工作目录的`gc.log`​中，每次进程重启，都会覆盖之前的gc日志

　　‍

1. 在物理内存小的情况下，一定要设置初始堆大小和最大堆大小，以免初始堆太小。
2. 尽可能地减少对象进入老年代，措施：增加young区大小，增加survivor占比。

### 1.初始堆大小只有32M

　　首先观察到的问题是，应用一起动，就出现`allocation fail`​导致的youngGC，eden分区直接占满。用`jstat -gc pid`​查看gc和heap堆大小发现，eden分区容量很小，只有8MB大小，young区一共10MB，old区21M。

　　查了一下，JVM的默认初始堆大小为物理内存的1/64，算了下确实是32的初始堆大小(并且young:old\=1:2)

　　查看默认堆大小可以用以下命令：(查询默认配置都可以用这个)

```ruby
java -XX:+PrintFlagsFinal -version
java -XX:+PrintFlagsFinal -version | grep HeapSize
```

　　解决方案：设置堆最小值，堆最大值：`-Xms400m -Xmx400m`​

### 2.metaspace达到阈值，导致fullgc

　　上面的变更后，一启动时的`allocation fail`​ younggc没了，但是看到metaSpace的空间增长导致fullgc

　　说明metaspace相关的配置需要增大

　　于是增加`-XX:MetaspaceSize=40M`​(ps:该参数在本机的默认参数为20M)

　　注意MetaspaceSize并不是制定元空间的大小，而是元空间达到该大小时执行一次GC，所以设置完该参数后，`jstat -gc pid`​并没有看到metaspace的空间变大。

### 3.youngGC后survivor区占用率100%，且有对象进入老年代

　　有对象进入老年代，问题不算大，但是可能会让fullgc过早发生

　　在这里可以做两件事，增大新生代的大小，增大survivor的占比。

　　于是有`-Xmn120m -XX:SurvivorRatio=4`​，我们之前看到，默认新老代为1:2，这里手动调整年轻代大小为120m；`SurvivorRatio=4`​意思是认为在youngGC后年轻代有1/4的对象能活下来，也就是每个survivor占比为1/(2+4)的大小

　　我们在这里观察到，youngGC后survivor的占用率为100%，说明默认的`SurvivorRatio=8`​（认为1/8的存活率）在我的场景下太低了，所以调高一点。

### 4. 在3的基础上，发现第二次youngGC时，就有部分对象进入老年代，且eden区占用率不为100%

　　这说明，第二次youngGC时，jvm就认为这部分对象需要到老年代，而不是因为eden不够才把他们放进去。

　　这里需要解释下`MaxTenuringThreshold`​与阈值的动态调整。默认该阈值为15，也就是需要活过15次gc才会放到老年代。

　　但是并不是一定等达到这个阈值才会进行晋升的，jvm有阈值动态调整策略，目的是让survivor的使用率小于一个设定值(默认50%)，因此每次gc时，会把多余的部分放入老年代。

　　survivor默认目标占比可以通过如下参数查看

```ruby
java -XX:+PrintFlagsFinal -version | grep TargetSurvivorRatio
```

　　JVM引入动态年龄计算，主要基于如下两点考虑：[美团技术博客](https://tech.meituan.com/2017/12/29/jvm-optimize.html)

* 如果固定按照MaxTenuringThreshold设定的阈值作为晋升条件：  a）MaxTenuringThreshold设置的过大，原本应该晋升的对象一直停留在Survivor区，直到Survivor区溢出，一旦溢出发生，Eden+Svuvivor中对象将不再依据年龄全部提升到老年代，这样对象老化的机制就失效了。  b）MaxTenuringThreshold设置的过小，“过早晋升”即对象不能在新生代充分被回收，大量短期对象被晋升到老年代，老年代空间迅速增长，引起频繁的Major GC。分代回收失去了意义，严重影响GC性能。
* 相同应用在不同时间的表现不同：特殊任务的执行或者流量成分的变化，都会导致对象的生命周期分布发生波动，那么固定的阈值设定，因为无法动态适应变化，会造成和上面相同的问题

### 5.真的需要那么大的old区吗

　　我们之前看到，young : old默认1:2。有点怀疑真的需要这么大的old区吗。可以适当调小吗？

　　我认为可以。但是需要考虑两件事，old调小了，fullgc会来的更早，一方面是old区满的快了，二是因为“内存分配担保机制”：

　　虚拟机检查老年代最大可用连续空间是否大于新生代所有对象的总和，如果大于，则此次分配担保是安全的。如果不大于且允许担保失败，则检查是否大于历次晋升到老年代对象的平均大小，如果大于，则冒险进行 minor GC，冒险失败则进行full GC。如果不大于或者不允许冒险则直接full GC。

### 6.cms的promotion failure和concurrent mode failure

　　1、promotion failure，是在minor  gc过程中，survivor的剩余空间不足以容纳eden及当前在用survivor区间存活对象，只能将容纳不下的对象移到年老代(promotion)，而此时年老代满了无法容纳更多对象，通常伴随full gc，因而导致的promotion failure。这种情况通常需要增加年轻代大小，尽量让新生对象在年轻代的时候尽量清理掉。

　　2、concurrent mode failure，主要是由于cms的无法处理浮动垃圾（Floating  Garbage）引起的。这个跟cms的机制有关。cms的并发清理阶段，用户线程还在运行，因此不断有新的垃圾产生，而这些垃圾不在这次清理标记的范畴里头，cms无法再本次gc清除掉，这些就是浮动垃圾。由于这种机制，cms年老代回收的阈值不能太高，否则就容易预留的内存空间很可能不够(因为本次gc同时还有浮动垃圾产生)，从而导致concurrent mode failure发生。可以通过-XX:CMSInitiatingOccupancyFraction的值来调优。

### 7.内存泄漏检查

1. dump内存后使用MAT查看
2. 使用`jmap -histo:live pid`​查看

### 8.systemd的java服务设置jvm参数

　　service：

```ini
[Unit]
Description=forwardproxy-Http代理
After=network-online.target
Wants=network-online.target

[Service]
WorkingDirectory=/opt/proxy
EnvironmentFile=/opt/proxy/jvm_option
ExecStart=/usr/bin/java $gc_option $heap_option -jar /opt/proxy/forwardproxy-1.0-jar-with-dependencies.jar -c /opt/proxy/proxy.properties
LimitNOFILE=100000
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
```

　　作用是从`EnvironmentFile`​读取`gc_option`​和`heap_option`​。注意`EnvironmentFile`​不可以不存在。经过上面的实战，我配置的参数如下：

　　/opt/proxy/jvm\_option

```ini
gc_option='-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintHeapAtGC -Xloggc:gc.log'
# 分别为最小堆，最大堆，新生代大小，触发gc的元空间大小（一般是fullgc）两个survivor与eden区比值（=6，则2:6，默认为8即每个survivor为1/10的年轻代大小）
heap_option='-Xms400m -Xmx400m -Xmn150m -XX:MetaspaceSize=40M -XX:SurvivorRatio=4'
```

　　另外，为了方便，可以设置以下alias：

```bash
alias sta='jps -l |grep forward|awk '\''{print $1}'\'' | xargs -I {} jstat -gc {}'
alias num='jps -l |grep forward|awk '\''{print $1}'\'' | xargs -I {} jmap -histo:live {}'
```

　　‍

　　‍

　　‍
