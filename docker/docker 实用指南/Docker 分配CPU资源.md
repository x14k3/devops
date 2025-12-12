
## **什么是[cgroup](https://zhida.zhihu.com/search?content_id=180901522&content_type=Article&match_order=1&q=cgroup&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NjU3MTE1MzcsInEiOiJjZ3JvdXAiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxODA5MDE1MjIsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.HVEWyuYsR5Sv3tb3kEviIf_3vNdBS3wO-FDwMuWcgtg&zhida_source=entity)？**

**cgroups** 其名称源自 **控制组群** （control groups）的简写，是Linux内核的一个功能，用来限制、控制与分离一个进程组（如CPU、内存、磁盘输入输出等）。

## **什么是Docker资源限制？**

默认情况下，Docker容器是没有资源限制的，它会尽可能地使用宿主机能够分配给它的资源。如果不对容器资源进行限制，容器之间就会相互影响，一些占用硬件资源较高的容器会吞噬掉所有的硬件资源，从而导致其它容器无硬件资源可用，发生停服状态。 Docker提供了限制内存，CPU或磁盘IO的方法， 可以对容器所占用的硬件资源大小以及多少进行限制，我们在使用docker create创建一个容器或者docker run运行一个容器的时候就可以来对此容器的硬件资源做限制。

Docker 通过 cgroup 来控制容器使用的资源配额，包括 CPU、内存、磁盘三大方面，基本覆盖了常见的资源配额和使用量控制。

## **限制Docker使用CPU**

默认设置下，所有容器可以平等地使用宿主机的CPU资源并且没有限制。

**设置CPU资源的选项如下**


- **-c 或 --cpu-shares：** 在有多个容器竞争 CPU 时我们可以设置每个容器能使用的 CPU 时间比例。这个比例叫作共享权值。共享式CPU资源，是按比例切分CPU资源；Docker 默认每个容器的权值为 1024。如果不指定或将其设置为0，都将使用默认值。 比如，当前系统上一共运行了两个容器，第一个容器上权重是1024，第二个容器权重是512， 第二个容器启动之后没有运行任何进程，自己身上的512都没有用完，而第一台容器的进程有很多，这个时候它完全可以占用容器二的CPU空闲资源，这就是共享式CPU资源；如果容器二也跑了进程，那么就会把自己的512给要回来，按照正常权重1024:512划分，为自己的进程提供CPU资源。如果容器二不用CPU资源，那容器一就能够把容器二的CPU资源所占用，如果容器二也需要CPU资源，那么就按照比例划分。那么第一个容器会从原来使用整个宿主机的CPU变为使用整个宿主机的CPU的2/3；这就是CPU共享式，也证明了CPU为可压缩性资源。
- **--cpus：** 限制容器运行的核数；从docker1.13版本之后，docker提供了--cpus参数可以限定容器能使用的CPU核数。这个功能可以让我们更精确地设置容器CPU使用量，是一种更容易理解也常用的手段。
- **--cpuset-cpus：** 限制容器运行在指定的CPU核心； 运行容器运行在哪个CPU核心上，例如主机有4个CPU核心，CPU核心标识为0-3，我启动一台容器，只想让这台容器运行在标识0和3的两个CPU核心上，可以使用cpuset来指定。



> 与内存限额不同，通过-c设置的cpu share 并不是CPU资源的绝对数量，而是一个相对的权重值。某个容器最终能分配到的CPU资源取决于它的cpu share占所有容器cpu share总和的比例。 **换句话说，通过cpu share可以设置容器使用CPU的优先级。**


```text
# containerA的cpu share 1024， 是containerB 的两倍。
# 当两个容器都需要CPU资源时，containerA可以得到的CPU是containerB 的两倍。
# 需要特别注意的是，这种按权重分配CPU只会发生在CPU资源紧张的情况下。
# 如果containerA处于空闲状态，这时，为了充分利用CPU资源，containerB 也可以分配到全部可用的CPU。
docker run --name "cont_A" -c 1024 ubuntu docker run --name "cont_B" -c 512 ubuntu

# 容器最多可以使用主机上两个CPU ，除此之外，还可以指定如 1.5 之类的小数。
docker run -it --rm --cpus=2 centos /bin/bash

# 表示容器中的进程可以在 CPU-1 和 CPU-3 上执行。
docker run -it --cpuset-cpus="1,3" ubuntu:14.04 /bin/bash

# 表示容器中的进程可以在 CPU-0、CPU-1 及 CPU-2 上执行。
docker run -it --cpuset-cpus="0-2" ubuntu:14.04 /bin/bash
```

通过`-c 或 --cpu-shares`是对CPU的资源进行相对限制。同样，我们可以进行CPU资源的绝对限制。

**大家如果想深度全方位学习Docker，推荐深蓝学院Docker图解教程，内容简单易懂，了解使用Docker的各种情境，从头到尾带你领会Docker的好用之处，感兴趣的朋友可以看看** ：
[深蓝学院Docker图解教程，多种情境模拟，全方位学习www.shenlanxueyuan.com/channel/hm1StBEKze/detail](https://link.zhihu.com/?target=https%3A//www.shenlanxueyuan.com/channel/hm1StBEKze/detail)
### **CPU 资源的绝对限制**

Linux 通过[CFS](https://zhida.zhihu.com/search?content_id=180901522&content_type=Article&match_order=1&q=CFS&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NjU3MTE1MzcsInEiOiJDRlMiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxODA5MDE1MjIsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.-SBrFpihznZIFpzbfphgovWD3-C-Er0vc4YJGdUuCxI&zhida_source=entity)（Completely Fair Scheduler，完全公平调度器）来调度各个进程对 CPU 的使用。CFS 默认的调度周期是 100ms。

我们可以设置每个容器进程的调度周期，以及在这个周期内各个容器最多能使用多少 CPU 时间。


- --cpu-period 设置每个容器进程的调度周期
- --cpu-quota 设置在每个周期内容器能使用的 CPU 时间



例如：

`docker run -it --cpu-period=50000 --cpu-quota=25000 Centos centos /bin/bash`

表示将 CFS 调度的周期设为 50000，将容器在每个周期内的 CPU 配额设置为 25000，表示该容器每 50ms 可以得到 50% 的 CPU 运行时间。

`docker run -it --cpu-period=10000 --cpu-quota=20000 Centos centos /bin/bash`表示将容器的 CPU 配额设置为 CFS 周期的两倍，CPU 使用时间怎么会比周期大呢？其实很好解释，给容器分配两个 CPU 就可以了。该配置表示容器可以在每个周期内使用两个 CPU 的 100% 时间。

CFS 周期的有效范围是`1ms~1s`，对应的--cpu-period的数值范围是`1000~1000000`。

而容器的 CPU 配额必须不小于 1ms，即--cpu-quota的值必须 >= 1000。可以看出这两个选项的单位都是 us。

### **如何正确的理解 "绝对"？**

`--cpu-quota`设置容器在一个调度周期内能使用的 CPU 时间时实际上设置的是一个上限。 并不是说容器一定会使用这么长的 CPU 时间。

启动一个容器，将其绑定到 cpu 1 上执行，给其`--cpu-quota`和`--cpu-period`都设置为 50000。表示每个容器进程的调度周期为 50000，容器在每个周期内最多能使用 50000 CPU 时间。

```text
docker run -d --name mongo1 --cpuset-cpus 1 --cpu-quota=50000 --cpu-period=50000 docker.io/mongo
```

再`docker stats mongo-1 mongo-2`可以观察到这两个容器，每个容器对 cpu 的使用率在 50% 左右。说明容器并没有在每个周期内使用 50000 的 cpu 时间。

使用`docker stop mongo2`命令结束第二个容器，再加一个参数-c 2048 启动它：

```text
docker run -d --name mongo2 --cpuset-cpus 1 --cpu-quota=50000 --cpu-period=50000 -c 2048 docker.io/mongo
```

再用`docker stats mongo-1 mongo-2`命令可以观察到第一个容器的 CPU 使用率在 33% 左右，第二个容器的 CPU 使用率在 66% 左右。因为第二个容器的共享值是 2048，第一个容器的默认共享值是 1024，所以第二个容器在每个周期内能使用的 CPU 时间是第一个容器的两倍。

### **总结**


- CPU份额控制：-c或--cpu-shares
- CPU核控制：--cpuset-cpus、--cpus
- CPU周期控制：--cpu-period、--cpu-quota



## **限制Docker使用内存**

与操作系统类似，容器可以使用的内存包括两部分：物理内存和Swap。

Docker通过下面两组参数来控制容器内存的使用量。


- -m 或 --memory：设置内存的使用限额，例如：100MB，2GB。
- --memory-swap：设置 **内存+swap** 的使用限额。



默认情况下，上面两组参数为-1，即对容器内存和swap的使用没有限制。如果在启动容器时，只指定-m而不指定--memory-swap， 那么--memory-swap默认为-m的两倍。

```text
# 允许该容器最多使用200MB的内存和100MB 的swap。
docker run -m 200M --memory-swap=300M ubuntu


# 容器最多使用200M的内存和200M的Swap
docker run -it -m 200M ubuntu
```

## **Docker容器中对磁盘IO进行限制**

[Block IO](https://zhida.zhihu.com/search?content_id=180901522&content_type=Article&match_order=1&q=Block+IO&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NjU3MTE1MzcsInEiOiJCbG9jayBJTyIsInpoaWRhX3NvdXJjZSI6ImVudGl0eSIsImNvbnRlbnRfaWQiOjE4MDkwMTUyMiwiY29udGVudF90eXBlIjoiQXJ0aWNsZSIsIm1hdGNoX29yZGVyIjoxLCJ6ZF90b2tlbiI6bnVsbH0.t6cJg2bQSaX5zRO1fuRJjvPSN2Z6ctSRLcyDeMl4m_8&zhida_source=entity)是另一种可以限制容器使用的资源。Block IO 指的是磁盘的读写，docker 可通过设置权重、限制 bps 和 iops 的方式控制容器读写磁盘的带宽

注：目前 Block IO 限额只对 direct IO（不使用文件缓存）有效。

### **如何进行Block IO的限制？**

默认情况下，所有容器能平等地读写磁盘，可以通过设置`--blkio-weight`参数来改变容器 block IO 的优先级。`--blkio-weight`与`--cpu-shares`类似，设置的是相对权重值，默认为 500。在下面的例子中，container_A 读写磁盘的带宽是 container_B 的两倍。

```text
docker run -it --name container_A --blkio-weight 600 ubuntu
docker run -it --name container_B --blkio-weight 300 ubuntu
```

### **如何对bps和iops进行限制？**

bps 是 byte per second，表示每秒读写的数据量。

iops 是 io per second，表示每秒的输入输出量(或读写次数)。

可通过以下参数控制容器的 bps 和 iops：


- --device-read-bps，限制读某个设备的 bps。
- --device-write-bps，限制写某个设备的 bps。
- --device-read-iops，限制读某个设备的 iops。
- --device-write-iops，限制写某个设备的 iops。



### **对写bps进行限制的测试**

限制容器写`/dev/sda`的速率为 30 MB/s。

```text
docker run -it --device-write-bps /dev/sda:30MB centos:latest
```

通过 dd 测试在容器中写磁盘的速度。因为容器的文件系统是在宿主机的 /dev/sda 上的，在容器中写文件相当于对宿主机 /dev/sda 进行写操作。另外，`oflag=direct`指定用 direct IO 方式写文件，这样`--device-write-bps`才能生效。

```text
time dd if=/dev/zero of=test.out bs=1M count800 oflag=direct
```

参数说明如下：


- if=file：输入文件名，缺省为标准输入
- of=file：输出文件名，缺省为标准输出
- ibs=bytes：一次读入 bytes 个字节（即一个块大小为 bytes 个字节）
- obs=bytes：一次写 bytes 个字节（即一个块大小为 bytes 个字节）
- bs=bytes：同时设置读写块的大小为 bytes ，可代替 ibs 和 obs
- count=`blocks`：仅拷贝`blocks`个块，每个块大小等于 ibs 指定的字节数



## **在Docker中使用GPU**

Docker中针对GPU资源与CPU、内存和磁盘IO资源不同。如果Docker要使用GPU，需要docker支持GPU，在docker19以前都需要单独下载[nvidia-docker](https://zhida.zhihu.com/search?content_id=180901522&content_type=Article&match_order=1&q=nvidia-docker&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NjU3MTE1MzcsInEiOiJudmlkaWEtZG9ja2VyIiwiemhpZGFfc291cmNlIjoiZW50aXR5IiwiY29udGVudF9pZCI6MTgwOTAxNTIyLCJjb250ZW50X3R5cGUiOiJBcnRpY2xlIiwibWF0Y2hfb3JkZXIiOjEsInpkX3Rva2VuIjpudWxsfQ.EISBTpAgfVb2VXgc44A1ZP_qvvQ_5XGQeHm5QT5FytY&zhida_source=entity)1或nvidia-docker2来启动容器，但是docker19中后需要GPU的Docker只需要加个参数-–gpus即可(`-–gpus all`表示使用所有的gpu；要使用2个gpu：`–-gpus 2`即可；也可直接指定使用哪几个卡：`--gpus '"device=1,2"'`)，Docker里面想读取nvidia显卡再也不需要额外的安装nvidia-docker了。

### **查看是否具备`--gpus`参数**

```text
docker run --help | grep -i gpus
```

### **查看nvidia界面是否能够启动**

运行nvidia官网提供的镜像，并输入nvidia-smi命令，查看nvidia界面是否能够启动。

```text
docker run --gpus all nvidia/cuda:9.0-base nvidia-smi
```

### **在Docker容器中使用GPU**

```text
# 使用所有GPU
docker run --gpus all nvidia/cuda:9.0-base nvidia-smi

# 使用两个GPU
docker run --gpus 2 nvidia/cuda:9.0-base nvidia-smi

# 指定GPU运行
docker run --gpus '"device=2"' nvidia/cuda:9.0-base nvidia-smi
docker run --gpus '"device=1,2"' nvidia/cuda:9.0-base nvidia-smi
docker run --gpus '"device=UUID-ABCDEF,1"' nvidia/cuda:9.0-base nvidia-smi
```

## **总结**

本文探索了Docker的资源限制相关知识，在日常开发中应该给容器设置一个合理的资源限制值，以防出现硬件资源不足的情况，从而导致Linux错杀进程。同时，也讲述了如何给Docker分配GPU。