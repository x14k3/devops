#kvm

`qemu-img` 命令，它是 QEMU 磁盘镜像管理工具，用于创建、转换、修改和查看虚拟机磁盘镜像。

## 基本命令结构

```bash
qemu-img [命令] [选项] <文件名> [参数]
```

## 核心命令详解

### 1. **`create`- 创建新磁盘镜像**

```bash
qemu-img create [-f fmt] [-o options] <文件名> <大小>
```

```bash
# 创建10G的qcow2格式镜像
qemu-img create -f qcow2 disk.qcow2 10G

# 创建厚置备镜像
qemu-img create -f qcow2 -o preallocation=full thick-disk.qcow2 20G
```


### 2. **`convert`- 镜像格式转换**

```bash
qemu-img convert [-f src_fmt] [-O dst_fmt] [-o options] <源文件> <目标文件>
```

```bash
# 将raw格式转为qcow2
qemu-img convert -f raw -O qcow2 disk.raw disk.qcow2

# 压缩转换
qemu-img convert -O qcow2 -c -o compression_type=zstd src.img dst.qcow2
```


### 3. **`resize`- 调整镜像大小**

```bash
qemu-img resize [-f fmt] <文件名> [+|-]<新大小>
```

```bash
# 增加5G空间
qemu-img resize vm-disk.qcow2 +5G

# 缩减到15G (需确保文件系统支持)
qemu-img resize vm-disk.qcow2 15G
```

### 4. **`info`- 查看镜像信息**

```bash
qemu-img info [-f fmt] <文件名>
```


### 5. **`check`- 检查镜像完整性**

```bash
qemu-img check [-f fmt] <文件名>
```

```bash
qemu-img check -r all damaged.qcow2  # -r 尝试修复
```


### 6. **`snapshot`- 快照管理**

```bash
qemu-img snapshot [-l | -a <快照> | -c <快照> | -d <快照>] <文件名>
```


## 高级操作与选项

### 1. 镜像格式选项 (`-f`/`-O`)

| 格式        | 描述             | 适用场景      |
| --------- | -------------- | --------- |
| **raw**   | 原始磁盘格式         | 高性能需求     |
| **qcow2** | QEMU原生格式 (推荐)  | 通用虚拟化     |
| **vhdx**  | Hyper-V兼容格式    | Windows环境 |
| **vmdk**  | VMware兼容格式     | VMware迁移  |
| **qcow**  | 旧版QEMU格式 (不推荐) | 兼容旧系统     |


### 2. 创建选项 (`-o`)

```bash
# 创建加密磁盘
qemu-img create -f qcow2 \
  -o encryption=luks,key-secret=sec0 \
  --object secret,id=sec0,data=mysecret \
  encrypted.qcow2 10G

# 设置集群大小
qemu-img create -f qcow2 -o cluster_size=128k disk.qcow2 20G

# 创建增量镜像
qemu-img create -f qcow2 -b base.qcow2 -F qcow2 delta.qcow2
```


### 3. 转换选项 (`-o`)

```bash
# 减少磁盘占用
qemu-img convert -O qcow2 -o cluster_size=128k,preallocation=metadata src.img dst.qcow2

# 加密转换
qemu-img convert -O qcow2 \
  -o encryption=luks,key-secret=sec0 \
  --object secret,id=sec0,file=passphrase.txt \
  src.img dst.qcow2
```

### 4. 镜像修改

```bash
# 提交快照到基础镜像
qemu-img commit snapshot.qcow2

# 修改后端镜像
qemu-img rebase -b new_base.qcow2 delta.qcow2
```


## 实用案例集锦

### 1. 磁盘扩容工作流

```bash
# 1. 查看当前大小
qemu-img info vm-disk.qcow2

# 2. 扩展镜像
qemu-img resize vm-disk.qcow2 +10G

# 3. 在虚拟机内扩展分区
# Linux: growpart /dev/vda 1 && resize2fs /dev/vda1
# Windows: 使用磁盘管理扩展卷
```

### 2. 磁盘瘦身

```bash
# 1. 虚拟机内清空未用空间
# Linux: dd if=/dev/zero of=/zero.file bs=1M; rm /zero.file
# Windows: sdelete -z C:

# 2. 转换压缩
qemu-img convert -O qcow2 -c -o cluster_size=128k src.qcow2 compact.qcow2
```

### 3. 物理机到虚拟机转换

```bash
# 1. 创建原始磁盘镜像
qemu-img create -f raw disk.raw 100G

# 2. 复制物理磁盘
dd if=/dev/sda of=disk.raw bs=4M status=progress

# 3. 转换为qcow2
qemu-img convert -O qcow2 disk.raw vm-disk.qcow2
```

### 4. 创建Windows安装镜像

```bash
# 1. 创建基础镜像
qemu-img create -f qcow2 win11.qcow2 64G

# 2. 使用virtio驱动
qemu-img create -f qcow2 -o cluster_size=128k,preallocation=falloc virtio-drivers.qcow2 100M
```


## 性能优化技巧

### 1. 集群大小选择

| 应用场景 | 推荐值 | 说明 |
| ---|---|--- |
| 数据库 | 64k-128k | 小I/O优化 |
| 大文件存储 | 1M | 减少元数据开销 |
| 通用系统 | 256k | 平衡性能 |

### 2. 预分配模式对比

| 模式 | 创建速度 | I/O性能 | 空间效率 | 适用场景 |
| ---|---|---|---|--- |
| **off** | ★★★★★ | ★★☆☆☆ | ★★★★★ | 开发/测试 |
| **metadata** | ★★★★☆ | ★★★☆☆ | ★★★★☆ | 一般生产环境 |
| **falloc** | ★★★☆☆ | ★★★★☆ | ★★★☆☆ | 性能敏感型应用 |
| **full** | ★☆☆☆☆ | ★★★★★ | ★★☆☆☆ | 数据库/高IO负载 |

### 3. 缓存模式建议

```bash
# 在虚拟机XML中设置:
<driver name='qemu' type='qcow2' cache='directsync'/>
```

| 缓存模式 | 数据安全 | 性能 | 说明 |
| ---|---|---|--- |
| **none** | ★★★☆☆ | ★★★★★ | 最高性能 |
| **writethrough** | ★★★★★ | ★★☆☆☆ | 写直达 (安全但慢) |
| **writeback** | ★★☆☆☆ | ★★★★☆ | 写回 (高性能但有风险) |
| **directsync** | ★★★★★ | ★★★☆☆ | O_DIRECT (推荐数据库) |
