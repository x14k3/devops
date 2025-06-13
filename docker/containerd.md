

# Containerd 部署

## 安装依赖

```bash
# 卸载原来的libseccomp, yum源中的版本太低，需要手动去下载rpm包
# https://developer.aliyun.com/packageSearch?word=libseccomp
rpm -qa | grep libseccomp
rpm -e libseccomp-2.3.1-4.el7.x86_64 --nodeps
rpm -ivh libseccomp-2.5.2-1.el8.x86_64.rpm 
```

## 下载并解压 Containerd 程序

Containerd 提供了两个压缩包，一个叫 `containerd-${VERSION}.${OS}-${ARCH}.tar.gz`，另一个叫 `cri-containerd-${VERSION}.${OS}-${ARCH}.tar.gz`。其中 `cri-containerd-${VERSION}.${OS}-${ARCH}.tar.gz` 包含了所有 Kubernetes 需要的二进制文件。如果你只是本地测试，可以选择前一个压缩包；如果是作为 Kubernetes 的容器运行时，需要选择后一个压缩包。

Containerd 是需要调用 `runc` 的，而第一个压缩包是不包含 `runc` 二进制文件的，如果你选择第一个压缩包，还需要提前安装 runc。所以我建议直接使用 `cri-containerd` 压缩包。

- containerd二进制包
  github下载地址：https://github.com/containerd/containerd/releases
- containerd带cni插件的二进制包
  `wget https://github.com/containerd/containerd/releases/download/v1.6.8/cri-containerd-cni-1.6.8-linux-amd64.tar.gz`

```bash
tar -tf cri-containerd-cni-1.4.3-linux-amd64.tar.gz
etc/
etc/cni/
etc/cni/net.d/
etc/cni/net.d/10-containerd-net.conflist
etc/crictl.yaml
etc/systemd/
etc/systemd/system/
etc/systemd/system/containerd.service
usr/
usr/local/
usr/local/bin/
usr/local/bin/containerd-shim-runc-v2
usr/local/bin/ctr
usr/local/bin/containerd-shim
usr/local/bin/containerd-shim-runc-v1
usr/local/bin/crictl
usr/local/bin/critest
usr/local/bin/containerd
usr/local/sbin/
usr/local/sbin/runc
opt/
opt/cni/
opt/cni/bin/
opt/cni/bin/vlan
opt/cni/bin/host-local
opt/cni/bin/flannel
opt/cni/bin/bridge
opt/cni/bin/host-device
opt/cni/bin/tuning
opt/cni/bin/firewall
opt/cni/bin/bandwidth
opt/cni/bin/ipvlan
opt/cni/bin/sbr
opt/cni/bin/dhcp
opt/cni/bin/portmap
opt/cni/bin/ptp
opt/cni/bin/static
opt/cni/bin/macvlan
opt/cni/bin/loopback
opt/containerd/
opt/containerd/cluster/
opt/containerd/cluster/version
opt/containerd/cluster/gce/
opt/containerd/cluster/gce/cni.template
opt/containerd/cluster/gce/configure.sh
opt/containerd/cluster/gce/cloud-init/
opt/containerd/cluster/gce/cloud-init/master.yaml
opt/containerd/cluster/gce/cloud-init/node.yaml
opt/containerd/cluster/gce/env

tar -C / -xzf cri-containerd-cni-1.6.8-linux-amd64.tar.gz

# 查看版本：

ctr version
Client:
  Version:  v1.4.3
  Revision: 269548fa27e0089a8b8278fc4fc781d7f65a939b
  Go version: go1.15.5

Server:
  Version:  v1.4.3
  Revision: 269548fa27e0089a8b8278fc4fc781d7f65a939b
  UUID: d1724999-91b3-4338-9288-9a54c9d52f70
```

## 生成配置文件

Containerd 的默认配置文件为 `/etc/containerd/config.toml`，我们可以通过命令来生成一个默认的配置：

```bash
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
```

## 镜像加速

由于某些不可描述的因素，在国内拉取公共镜像仓库的速度是极慢的，为了节约拉取时间，需要为 Containerd 配置镜像仓库的 `mirror`。Containerd 的镜像仓库 mirror 与 Docker 相比有两个区别：

- Containerd 只支持通过 `CRI` 拉取镜像的 mirror，也就是说，只有通过 `crictl` 或者 Kubernetes 调用时 mirror 才会生效，通过 `ctr` 拉取是不会生效的。
- `Docker` 只支持为 `Docker Hub` 配置 mirror，而 `Containerd` 支持为任意镜像仓库配置 mirror。

配置镜像加速之前，先来看下 Containerd 的配置结构，乍一看可能会觉得很复杂，复杂就复杂在 plugin 的配置部分：

```bash
disabled_plugins = []
imports = []
oom_score = 0
plugin_dir = ""
required_plugins = []
root = "/var/lib/containerd"
state = "/run/containerd"
temp = ""
version = 2

[cgroup]
  path = ""

[debug]
  address = ""
  format = ""
  gid = 0
  level = ""
  uid = 0

[grpc]
  address = "/run/containerd/containerd.sock"
  gid = 0
  max_recv_message_size = 16777216
  max_send_message_size = 16777216
  tcp_address = ""
  tcp_tls_ca = ""
  tcp_tls_cert = ""
  tcp_tls_key = ""
  uid = 0

[metrics]
  address = ""
  grpc_histogram = false

[plugins]

  [plugins."io.containerd.gc.v1.scheduler"]
    deletion_threshold = 0
    mutation_threshold = 100
    pause_threshold = 0.02
    schedule_delay = "0s"
    startup_delay = "100ms"

  [plugins."io.containerd.grpc.v1.cri"]
    device_ownership_from_security_context = false
    disable_apparmor = false
    disable_cgroup = false
    disable_hugetlb_controller = true
    disable_proc_mount = false
    disable_tcp_service = true
    enable_selinux = false
    enable_tls_streaming = false
    enable_unprivileged_icmp = false
    enable_unprivileged_ports = false
    ignore_image_defined_volumes = false
    max_concurrent_downloads = 3
    max_container_log_line_size = 16384
    netns_mounts_under_state_dir = false
    restrict_oom_score_adj = false
    sandbox_image = "k8s.gcr.io/pause:3.6"
    selinux_category_range = 1024
    stats_collect_period = 10
    stream_idle_timeout = "4h0m0s"
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    systemd_cgroup = false
    tolerate_missing_hugetlb_controller = true
    unset_seccomp_profile = ""

    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/cni/bin"
      conf_dir = "/etc/cni/net.d"
      conf_template = ""
      ip_pref = ""
      max_conf_num = 1

    [plugins."io.containerd.grpc.v1.cri".containerd]
      default_runtime_name = "runc"
      disable_snapshot_annotations = true
      discard_unpacked_layers = false
      ignore_rdt_not_enabled_errors = false
      no_pivot = false
      snapshotter = "overlayfs"

      [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
        base_runtime_spec = ""
        cni_conf_dir = ""
        cni_max_conf_num = 0
        container_annotations = []
        pod_annotations = []
        privileged_without_host_devices = false
        runtime_engine = ""
        runtime_path = ""
        runtime_root = ""
        runtime_type = ""

        [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime.options]

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          base_runtime_spec = ""
          cni_conf_dir = ""
          cni_max_conf_num = 0
          container_annotations = []
          pod_annotations = []
          privileged_without_host_devices = false
          runtime_engine = ""
          runtime_path = ""
          runtime_root = ""
          runtime_type = "io.containerd.runc.v2"

          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            BinaryName = ""
            CriuImagePath = ""
            CriuPath = ""
            CriuWorkPath = ""
            IoGid = 0
            IoUid = 0
            NoNewKeyring = false
            NoPivotRoot = false
            Root = ""
            ShimCgroup = ""
            SystemdCgroup = false

      [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime]
        base_runtime_spec = ""
        cni_conf_dir = ""
        cni_max_conf_num = 0
        container_annotations = []
        pod_annotations = []
        privileged_without_host_devices = false
        runtime_engine = ""
        runtime_path = ""
        runtime_root = ""
        runtime_type = ""

        [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime.options]

    [plugins."io.containerd.grpc.v1.cri".image_decryption]
      key_model = "node"

    [plugins."io.containerd.grpc.v1.cri".registry]
      config_path = ""

      [plugins."io.containerd.grpc.v1.cri".registry.auths]

      [plugins."io.containerd.grpc.v1.cri".registry.configs]

      [plugins."io.containerd.grpc.v1.cri".registry.headers]

      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]

    [plugins."io.containerd.grpc.v1.cri".x509_key_pair_streaming]
      tls_cert_file = ""
      tls_key_file = ""

  [plugins."io.containerd.internal.v1.opt"]
    path = "/opt/containerd"

  [plugins."io.containerd.internal.v1.restart"]
    interval = "10s"

  [plugins."io.containerd.internal.v1.tracing"]
    sampling_ratio = 1.0
    service_name = "containerd"

  [plugins."io.containerd.metadata.v1.bolt"]
    content_sharing_policy = "shared"

  [plugins."io.containerd.monitor.v1.cgroups"]
    no_prometheus = false

  [plugins."io.containerd.runtime.v1.linux"]
    no_shim = false
    runtime = "runc"
    runtime_root = ""
    shim = "containerd-shim"
    shim_debug = false

  [plugins."io.containerd.runtime.v2.task"]
    platforms = ["linux/amd64"]
    sched_core = false

  [plugins."io.containerd.service.v1.diff-service"]
    default = ["walking"]

  [plugins."io.containerd.service.v1.tasks-service"]
    rdt_config_file = ""

  [plugins."io.containerd.snapshotter.v1.aufs"]
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.btrfs"]
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.devmapper"]
    async_remove = false
    base_image_size = ""
    discard_blocks = false
    fs_options = ""
    fs_type = ""
    pool_name = ""
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.native"]
    root_path = ""

  [plugins."io.containerd.snapshotter.v1.overlayfs"]
    root_path = ""
    upperdir_label = false

  [plugins."io.containerd.snapshotter.v1.zfs"]
    root_path = ""

  [plugins."io.containerd.tracing.processor.v1.otlp"]
    endpoint = ""
    insecure = false
    protocol = ""

[proxy_plugins]

[stream_processors]

  [stream_processors."io.containerd.ocicrypt.decoder.v1.tar"]
    accepts = ["application/vnd.oci.image.layer.v1.tar+encrypted"]
    args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
    env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]
    path = "ctd-decoder"
    returns = "application/vnd.oci.image.layer.v1.tar"

  [stream_processors."io.containerd.ocicrypt.decoder.v1.tar.gzip"]
    accepts = ["application/vnd.oci.image.layer.v1.tar+gzip+encrypted"]
    args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
    env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]
    path = "ctd-decoder"
    returns = "application/vnd.oci.image.layer.v1.tar+gzip"

[timeouts]
  "io.containerd.timeout.bolt.open" = "0s"
  "io.containerd.timeout.shim.cleanup" = "5s"
  "io.containerd.timeout.shim.load" = "5s"
  "io.containerd.timeout.shim.shutdown" = "3s"
  "io.containerd.timeout.task.state" = "2s"

[ttrpc]
  address = ""
  gid = 0
  uid = 0

```

每一个顶级配置块的命名都是 `plugins."io.containerd.xxx.vx.xxx"` 这种形式，其实每一个顶级配置块都代表一个插件，其中 `io.containerd.xxx.vx` 表示插件的类型，vx 后面的 xxx 表示插件的 `ID`。可以通过 `ctr` 一览无余：

```bash

[root@k8s-node01 kubernetes]# ctr plugin ls
TYPE                                  ID                       PLATFORMS      STATUS    
io.containerd.content.v1              content                  -              ok        
io.containerd.snapshotter.v1          aufs                     linux/amd64    skip      
io.containerd.snapshotter.v1          btrfs                    linux/amd64    skip      
io.containerd.snapshotter.v1          devmapper                linux/amd64    error     
io.containerd.snapshotter.v1          native                   linux/amd64    ok        
io.containerd.snapshotter.v1          overlayfs                linux/amd64    ok        
io.containerd.snapshotter.v1          zfs                      linux/amd64    skip      
io.containerd.metadata.v1             bolt                     -              ok        
io.containerd.differ.v1               walking                  linux/amd64    ok        
io.containerd.event.v1                exchange                 -              ok        
io.containerd.gc.v1                   scheduler                -              ok        
io.containerd.service.v1              introspection-service    -              ok        
io.containerd.service.v1              containers-service       -              ok        
io.containerd.service.v1              content-service          -              ok        
io.containerd.service.v1              diff-service             -              ok        
io.containerd.service.v1              images-service           -              ok        
io.containerd.service.v1              leases-service           -              ok        
io.containerd.service.v1              namespaces-service       -              ok        
io.containerd.service.v1              snapshots-service        -              ok        
io.containerd.runtime.v1              linux                    linux/amd64    ok        
io.containerd.runtime.v2              task                     linux/amd64    ok        
io.containerd.monitor.v1              cgroups                  linux/amd64    ok        
io.containerd.service.v1              tasks-service            -              ok        
io.containerd.grpc.v1                 introspection            -              ok        
io.containerd.internal.v1             restart                  -              ok        
io.containerd.grpc.v1                 containers               -              ok        
io.containerd.grpc.v1                 content                  -              ok        
io.containerd.grpc.v1                 diff                     -              ok        
io.containerd.grpc.v1                 events                   -              ok        
io.containerd.grpc.v1                 healthcheck              -              ok        
io.containerd.grpc.v1                 images                   -              ok        
io.containerd.grpc.v1                 leases                   -              ok        
io.containerd.grpc.v1                 namespaces               -              ok        
io.containerd.internal.v1             opt                      -              ok        
io.containerd.grpc.v1                 snapshots                -              ok        
io.containerd.grpc.v1                 tasks                    -              ok        
io.containerd.grpc.v1                 version                  -              ok        
io.containerd.tracing.processor.v1    otlp                     -              skip      
io.containerd.internal.v1             tracing                  -              ok        
io.containerd.grpc.v1                 cri                      linux/amd64    ok      
```

顶级配置块下面的子配置块表示该插件的各种配置，比如 cri 插件下面就分为 `containerd`、`cni` 和 `registry` 的配置，而 containerd 下面又可以配置各种 runtime，还可以配置默认的 runtime。

镜像加速的配置就在 cri 插件配置块下面的 registry 配置块，所以需要修改的部分如下：

```bash
    [plugins."io.containerd.grpc.v1.cri".registry]
      config_path = ""

      [plugins."io.containerd.grpc.v1.cri".registry.auths]

      [plugins."io.containerd.grpc.v1.cri".registry.configs]

      [plugins."io.containerd.grpc.v1.cri".registry.headers]

      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]

#--------------修改后-------------------------------------
    [plugins."io.containerd.grpc.v1.cri".registry]
      config_path = ""

      [plugins."io.containerd.grpc.v1.cri".registry.auths]

      [plugins."io.containerd.grpc.v1.cri".registry.configs]

      [plugins."io.containerd.grpc.v1.cri".registry.headers]

      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://dockerhub.mirrors.nwafu.edu.cn"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
          endpoint = ["https://registry.aliyuncs.com/k8sxio"]

# 配置docker-harbor私有仓库
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
	[plugins."io.containerd.grpc.v1.cri".registry.mirrors."192.168.0.100:8081"]
          endpoint = ["http://192.168.0.100:8081"]
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.config.""]
      [plugins."io.containerd.grpc.v1.cri".registry.auths]
        [plugins."io.containerd.grpc.v1.cri".registry.auth."192.168.0.100:8081".auth]
            username = "admin"
            password = "Harbor12345

```

- **registry.mirrors.“xxx”**  : 表示需要配置 mirror 的镜像仓库。例如，`registry.mirrors."docker.io"` 表示配置 docker.io 的 mirror。
- **endpoint** : 表示提供 mirror 的镜像加速服务。例如，这里推荐使用西北农林科技大学提供的镜像加速服务作为 `docker.io` 的 mirror。

## 存储配置

Containerd 有两个不同的存储路径，一个用来保存持久化数据，一个用来保存运行时状态。

```toml
root = "/var/lib/containerd"
state = "/run/containerd"
```

`root`用来保存持久化数据，包括 `Snapshots`, `Content`, `Metadata` 以及各种插件的数据。每一个插件都有自己单独的目录，Containerd 本身不存储任何数据，它的所有功能都来自于已加载的插件，真是太机智了。

`state` 用来保存临时数据，包括 sockets、pid、挂载点、运行时状态以及不需要持久化保存的插件数据。

## OOM

还有一项配置需要留意：

```toml
oom_score = 0
```

Containerd 是容器的守护者，一旦发生内存不足的情况，理想的情况应该是先杀死容器，而不是杀死 Containerd。所以需要调整 Containerd 的 `OOM` 权重，减少其被 **OOM Kill** 的几率。最好是将 `oom_score` 的值调整为比其他守护进程略低的值。这里的 oom_socre 其实对应的是 `/proc/<pid>/oom_socre_adj`，在早期的 Linux 内核版本里使用 `oom_adj` 来调整权重, 后来改用 `oom_socre_adj` 了。该文件描述如下：

> The value of `/proc/<pid>/oom_score_adj` is added to the badness score before it
> is used to determine which task to kill. Acceptable values range from -1000
> (OOM_SCORE_ADJ_MIN) to +1000 (OOM_SCORE_ADJ_MAX). This allows userspace to
> polarize the preference for oom killing either by always preferring a certain
> task or completely disabling it. The lowest possible value, -1000, is
> equivalent to disabling oom killing entirely for that task since it will always
> report a badness score of 0.

在计算最终的 `badness score` 时，会在计算结果是中加上 `oom_score_adj` ,这样用户就可以通过该在值来保护某个进程不被杀死或者每次都杀某个进程。其取值范围为 `-1000` 到 `1000`。

如果将该值设置为 `-1000`，则进程永远不会被杀死，因为此时 `badness score` 永远返回0。

建议 Containerd 将该值设置为 `-999` 到 `0` 之间。如果作为 Kubernetes 的 Worker 节点，可以考虑设置为 `-999`。

## Systemd 配置

建议通过 systemd 配置 Containerd 作为守护进程运行，配置文件在上文已经被解压出来了：

```bash
cat /etc/systemd/system/containerd.service
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
```

这里有两个重要的参数：

- **Delegate** : 这个选项允许 Containerd 以及运行时自己管理自己创建的容器的 `cgroups`。如果不设置这个选项，systemd 就会将进程移到自己的 `cgroups` 中，从而导致 Containerd 无法正确获取容器的资源使用情况。
- **KillMode** : 这个选项用来处理 Containerd 进程被杀死的方式。默认情况下，systemd 会在进程的 cgroup 中查找并杀死 Containerd 的所有子进程，这肯定不是我们想要的。`KillMode`字段可以设置的值如下。

  - **control-group**（默认值）：当前控制组里面的所有子进程，都会被杀掉
  - **process**：只杀主进程
  - **mixed**：主进程将收到 SIGTERM 信号，子进程收到 SIGKILL 信号
  - **none**：没有进程会被杀掉，只是执行服务的 stop 命令。

  我们需要将 KillMode 的值设置为 `process`，这样可以确保升级或重启 Containerd 时不杀死现有的容器。

现在到了最关键的一步：启动 Containerd。执行一条命令就完事：

```bash
systemctl enable containerd --now
```

# ctr 命令

- ctr是containerd的一个客户端工具;
- crictl是遵循CRI接口规范的一个命令行工具，通常用它来检查和管理kubelet节点上的容器运行时和镜像;

ctr 目前很多功能做的还没有 docker 那么完善，但基本功能已经具备了。下面将围绕**镜像**和**容器**这两个方面来介绍其使用方法。
containerd 相比于docker , 多了namespace概念, 每个image和container 都会在各自的namespace下可见, 目前k8s会使用k8s.io 作为命名空间~~

```bash
#### 查看ctr image可用操作
ctr image list, ctr i list , ctr i ls
#### 镜像标记tag
ctr -n k8s.io i tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
#注意: 若新镜像reference 已存在, 需要先删除新reference, 或者如下方式强制替换
ctr -n k8s.io i tag --force registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2

#### 删除镜像
ctr -n k8s.io i rm k8s.gcr.io/pause:3.2

#### 拉取镜像
ctr -n k8s.io i pull -k k8s.gcr.io/pause:3.2

#### 推送镜像
ctr -n k8s.io i push -k k8s.gcr.io/pause:3.2

#### 导出镜像
ctr -n k8s.io i export pause.tar k8s.gcr.io/pause:3.2

#### 导入镜像
# 不支持 build,commit 镜像 
ctr -n k8s.io i import pause.tar

#### 查看容器相关操作
ctr c

# 运行容器
ctr -n k8s.io run --null-io --net-host -d \
–env PASSWORD="123456"
–mount type=bind,src=/etc,dst=/host-etc,options=rbind:rw
#–null-io: 将容器内标准输出重定向到/dev/null
#–net-host: 主机网络
#-d: 当task执行后就进行下一步shell命令,如没有选项,则会等待用户输入,并定向到容器内
#–mount 挂载本地目录或文件到容器
#–env 环境变量


#### 容器日志
ctr -n k8s.io run --log-uri file:///var/log/xx.log

```

|ctr命令|Docker命令|描述|
| ------------------------------| -------------------------------------| ------------------|
|ctr task ls|docker ps|查看运行容器|
|ctr image ls|docker images|获取image信息|
|ctr image pull pause|docker pull pause|pull 应该pause镜像|
|ctr image push pause-test|docker push pause-test|改名|
|ctr image import pause.tar|docker load 镜像|导入本地镜像|
|ctr run -d pause-test pause|docker run -d --name=pause pause-test|运行容器|
|ctr image tag pause pause-test|docker tag pause pause-test|tag应该pause镜像|

# crictl 命令

- ctr是containerd的一个客户端工具;
- crictl是遵循CRI接口规范的一个命令行工具，通常用它来检查和管理kubelet节点上的容器运行时和镜像;

|crictl命令|Docker命令|描述|
| --------------------------| -------------------------| ------------------|
|crictl images|docker images|显示本地镜像列表|
|crictl pull|docker pull|下载镜像|
|---|docker push|上传镜像|
|crictl rmi|docker rmi|删除本地镜像|
|crictl inspecti IMAGE-ID|docker inspect IMAGE-ID|查看镜像详情|
|crictl ps|docker ps|显示容器列表|
|crictl create|docker create|创建容器|
|crictl start|docker start|启动容器|
|crictl stop|docker stop|停止容器|
|crictl rm|docker rm|删除容器|
|crictl inspect|docker inspect|查看容器详情|
|crictl attach|docker attach||
|crictl exec|docker exec||
|crictl logs|docker logs||
|crictl stats|docker stats||

# Containerd 的前世今生

很久以前，Docker 强势崛起，以“镜像”这个大招席卷全球，对其他容器技术进行致命的降维打击，使其毫无招架之力，就连 Google 也不例外。Google 为了不被拍死在沙滩上，被迫拉下脸面（当然，跪舔是不可能的），希望 Docker 公司和自己联合推进一个开源的容器运行时作为 Docker 的核心依赖，不然就走着瞧。Docker 公司觉得自己的智商被侮辱了，走着瞧就走着瞧，谁怕谁啊！

很明显，Docker 公司的这个决策断送了自己的大好前程，造成了今天的悲剧。

紧接着，Google 联合 Red Hat、IBM 等几位巨佬连哄带骗忽悠 Docker 公司将 `libcontainer` 捐给中立的社区（OCI，Open Container Intiative），并改名为 `runc`，不留一点 Docker 公司的痕迹~~

这还不够，为了彻底扭转 Docker 一家独大的局面，几位大佬又合伙成立了一个基金会叫 `CNCF`（Cloud Native Computing Fundation），这个名字想必大家都很熟了，我就不详细介绍了。CNCF 的目标很明确，既然在当前的维度上干不过 Docker，干脆往上爬，升级到大规模容器编排的维度，以此来击败 Docker。

Docker 公司当然不甘示弱，搬出了 Swarm 和 Kubernetes 进行 PK，最后的结局大家都知道了，Swarm 战败。然后 Docker 公司耍了个小聪明，将自己的核心依赖 `Containerd` 捐给了 CNCF，以此来标榜 Docker 是一个 PaaS 平台。

很明显，这个小聪明又大大加速了自己的灭亡。

![](net-img-20201215014746-20230815141748-uzw2m81.jpeg)

巨佬们心想，想当初想和你合作搞个中立的核心运行时，你死要面子活受罪，就是不同意，好家伙，现在自己搞了一个，还捐出来了，这是什么操作？也罢，这倒省事了，我就直接拿 `Containerd` 来做文章吧。

首先呢，为了表示 Kubernetes 的中立性，当然要搞个标准化的容器运行时接口，只要适配了这个接口的容器运行时，都可以和我一起玩耍哦，第一个支持这个接口的当然就是 `Containerd` 啦。至于这个接口的名字，大家应该都知道了，它叫 CRI（Container Runntime Interface）。

这样还不行，为了蛊惑 Docker 公司，Kubernetes 暂时先委屈自己，专门在自己的组件中集成了一个 `shim`（你可以理解为垫片），用来将 CRI 的调用翻译成 Docker 的 API（dockershim），让 Docker 也能和自己愉快地玩耍，温水煮青蛙，养肥了再杀。。。

就这样，Kubernetes 一边假装和 Docker 愉快玩耍，一边背地里不断优化 Containerd 的健壮性以及和 CRI 对接的丝滑性。现在 Containerd 的翅膀已经完全硬了，是时候卸下我的伪装，和 Docker say bye bye 了。后面的事情大家也都知道了~~

Docker 这门技术成功了，Docker 这个公司却失败了。

## docker

Docker 可以轻松地构建容器镜像，从 Docker Hub 中拉取镜像，创建、启动和管理容器。实际上，当你用 Docker 运行一个容器时实际上是通过 Docker Daemon、containerd 和 runc 来运行它。

而 Docker 将容器操作都迁移到 `containerd` 中去是因为当前做 Swarm，想要进军 PaaS 市场，做了这个架构切分，让 Docker Daemon 专门去负责上层的封装编排，当然后面的结果我们知道 Swarm 在 Kubernetes 面前是惨败，然后 Docker 公司就把 `containerd` 项目捐献给了 CNCF 基金会，这个也是现在的 Docker 架构。

## containerd

当我们要创建一个容器的时候，现在 Docker Daemon 并不能直接帮我们创建了，而是请求 `containerd`​ 来创建一个容器，containerd 收到请求后，也并不会直接去操作容器，而是创建一个叫做 `containerd-shim`​ 的进程，让这个进程去操作容器，我们指定容器进程是需要一个父进程来做状态收集、维持 stdin 等 fd 打开等工作的，假如这个父进程就是 containerd，那如果 containerd 挂掉的话，整个宿主机上所有的容器都得退出了，而引入 `containerd-shim`​ 这个垫片就可以来规避这个问题了。  
​![](image-20230220095314932-20230610173810-nsm1mhk.png)​

## OCI（runc）

然后创建容器需要做一些 namespaces 和 cgroups 的配置，以及挂载 root 文件系统等操作，这些操作其实已经有了标准的规范，那就是 OCI（开放容器标准），`runc` 就是它的一个参考实现（Docker 被逼无耐将 `libcontainer` 捐献出来改名为 `runc` 的），这个标准其实就是一个文档，主要规定了容器镜像的结构、以及容器需要接收哪些操作指令，比如 create、start、stop、delete 等这些命令。`runc` 就可以按照这个 OCI 文档来创建一个符合规范的容器，既然是标准肯定就有其他 OCI 实现，比如 Kata、gVisor 这些容器运行时都是符合 OCI 标准的。

所以**真正启动容器是通过 **​**​`containerd-shim`​**​ ** 去调用 **​**​`runc`​**​ ** 来启动容器的**，`runc` 启动完容器后本身会直接退出，`containerd-shim` 则会成为容器进程的父进程, 负责收集容器进程的状态, 上报给 containerd, 并在容器中 pid 为 1 的进程退出后接管容器中的子进程进行清理, 确保不会出现僵尸进程。

## CRI

​`CRI`​（Container Runtime Interface 容器运行时接口）是 Kubernetes 用来控制创建和管理容器的不同运行时的 API，它使 Kubernetes 更容易使用不同的容器运行时。它一个插件接口，这意味着任何符合该标准实现的容器运行时都可以被 Kubernetes 所使用。  
不过 Kubernetes 推出 CRI 这套标准的时候还没有现在的统治地位，所以有一些容器运行时可能不会自身就去实现 CRI 接口，于是就有了 `shim（垫片）`​， 一个 shim 的职责就是作为适配器将各种容器运行时本身的接口适配到 Kubernetes 的 CRI 接口上，其中 `dockershim`​ 就是 Kubernetes 对接 Docker 到 CRI 接口上的一个垫片实现。  
​![](image-20230220095927068-20230610173810-fzply2p.png)​

而k8s原生就支持containerd，不需要shim作为对接CRI的垫片了。
