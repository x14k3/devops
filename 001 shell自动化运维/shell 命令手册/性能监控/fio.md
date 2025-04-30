# fio

fio命令来自于英文词组”Flexible IO Tester“的缩写， 其功能是用于对磁盘进行压力测试。硬盘I/O吞吐率是性能的重要指标之一，运维人员可以使用fio命令对其进行测试，测试又可以细分为顺序读写和随机读写两大类。

**语法格式：** fio \[参数\]

**常用参数：**

```bash
filename=/dev/sdb1       # 测试文件名称，通常选择需要测试的盘的data目录。
direct=1                 # 是否使用directIO，测试过程绕过OS自带的buffer，使测试磁盘的结果更真实。Linux读写的时候，内核维护了缓存，数据先写到缓存，后面再后台写到SSD。读的时候也优先读缓存里的数据。这样速度可以加快，但是一旦掉电缓存里的数据就没了。所以有一种模式叫做DirectIO，跳过缓存，直接读写SSD。 
rw=randrw                # 测试随机写和读的I/O  write/read/randwrite/randread/randrw
bs=16k                   # 单次io的块文件大小为16k
bsrange=512-2048         # 同上，提定数据块的大小范围
size=5G                  # 每个线程读写的数据量是5GB。
numjobs=1                # 每个job（任务）开1个线程，这里用了几，后面每个用-name指定的任务就开几个线程测试。所以最终线程数=任务数（几个name=jobx）* numjobs。 
name=job1                # 一个任务的名字，重复了也没关系。如果fio -name=job1 -name=job2，建立了两个任务，共享-name=job1之前的参数。-name之后的就是job2任务独有的参数。 
thread                   # 使用pthread_create创建线程，另一种是fork创建进程。进程的开销比线程要大，一般都采用thread测试。 
runtime=1000             # 测试时间为1000秒，如果不写则一直将5g文件分4k每次写完为止。
ioengine=libaio          # ioengine: I/O 引擎，现在 fio 支持 19 种 ioengine。默认值是 sync 同步阻塞 I/O，libaio 是 Linux 的 native 异步 I/O。关于同步异步，阻塞和非阻塞模型可以参考文章“使用异步 I/O 大大提高应用程序的性能”。
iodepth=16               # 队列的深度为16.在异步模式下，CPU不能一直无限的发命令到SSD。比如SSD执行读写如果发生了卡顿，那有可能系统会一直不停的发命令，几千个，甚至几万个，这样一方面SSD扛不住，另一方面这么多命令会很占内存，系统也要挂掉了。这样，就带来一个参数叫做队列深度。
Block                    # Devices（RBD），无需使用内核RBD驱动程序（rbd.ko）。该参数包含很多ioengine，如：libhdfs/rdma等
rwmixwrite=30            # 在混合读写的模式下，写占30%
group_reporting          # 关于显示结果的，汇总每个进程的信息。
此外
lockmem=1g               # 只使用1g内存进行测试。
zero_buffers             # 用0初始化系统buffer。
nrfiles=8                # 每个进程生成文件的数量。

#磁盘读写常用测试点：
## 1. Read=100% Ramdon=100% rw=randread    (100%随机读)
## 2. Read=100% Sequence=100% rw=read     （100%顺序读）
## 3. Write=100% Sequence=100% rw=write   （100%顺序写）
## 4. Write=100% Ramdon=100% rw=randwrite （100%随机写）
## 5. Read=70% Sequence=100% rw=rw, rwmixread=70, rwmixwrite=30  （70%顺序读，30%顺序写）
## 6. Read=70% Ramdon=100% rw=randrw, rwmixread=70, rwmixwrite=30 (70%随机读，30%随机写)
```

**参考实例**

随机读取测试：

```bash
fio -filename=/var/test.file -direct=1 -iodepth 1 -thread -rw=read      -ioengine=psync -bs=16k -size=200G -numjobs=10 -runtime=300 -group_reporting -name=mytest
```

随机写入测试：

```bash
fio -filename=/var/test.file -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=200G -numjobs=10 -runtime=300 -group_reporting -name=mytest
```

顺序写测试：

```bash
fio -filename=/var/test.file -direct=1 -iodepth 1 -thread -rw=write     -ioengine=psync -bs=16k -size=200G -numjobs=10 -runtime=300 -group_reporting -name=mytest
```

顺序读测试：

```
fio -filename=/var/test.file -direct=1 -iodepth 1 -thread -rw=read      -ioengine=psync -bs=16k -size=200G -numjobs=10 -runtime=300 -group_reporting -name=mytest
```

混合随机读写：

```
fio -filename=/var/test.file -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=16k -size=200G -numjobs=10 -runtime=300 -group_reporting -name=mytest -ioscheduler=noop
```
