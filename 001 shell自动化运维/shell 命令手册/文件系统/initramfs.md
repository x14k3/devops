# initramfs

　　Linux kernel在自身初始化完成之后，需要能够找到并运行第一个用户程序（这个程序通常叫做“init”程序）。用户程序存在于文件系统之中，因此，内核必须找到并挂载一个文件系统才可以成功完成系统的引导过程。

　　在grub中提供了一个选项“root=”用来指定第一个文件系统，但随着硬件的发展，很多情况下这个文件系统也许是存放在USB设备，SCSI设备等等多种多样的设备之上，如果需要正确引导，USB或者SCSI驱动模块首先需要运行起来，可是不巧的是，这些驱动程序也是存放在文件系统里，因此会形成一个悖论。

　　为解决此问题，Linux kernel提出了一个RAM disk的解决方案，把一些启动所必须的用户程序和驱动模块放在RAM  disk中，这个RAM disk看上去和普通的disk一样，有文件系统，有cache，内核启动时，首先把RAM  disk挂载起来，等到init程序和一些必要模块运行起来之后，再切到真正的文件系统之中。

　　上面提到的RAM disk的方案实际上就是initrd。 如果仔细考虑一下，initrd虽然解决了问题但并不完美。  比如，disk有cache机制，对于RAM  disk来说，这个cache机制就显得很多余且浪费空间；disk需要文件系统，那文件系统（如ext2等）必须被编译进kernel而不能作为模块来使用。

　　Linux 2.6 kernel提出了一种新的实现机制，即initramfs。顾名思义，initramfs只是一种RAM  filesystem而不是disk。initramfs实际是一个cpio归档，启动所需的用户程序和驱动模块被归档成一个文件。因此，不需要cache，也不需要文件系统。

## 制作initramfs/initrd镜像

### initramfs

　　下面是一些使用initramfs的简单帮助

* 查看initramfs的内容

  ```bash
  mkdir initrdtmp && cd initrdtmp \
  && zcat /boot/initrd.img-2.6.24-16 initrd.img-2.6.24-16.gz|cpio -i --make-directories
  ```
* 创建initramfs

  命令：mkinitramfs, update-initramfs

  mkinitramfs

  ```bash
  mkinitramfs -o /boot/initrd.img 2.6.24-16
  ```

  Note: 2.6.24-16是需要创建initramfs的kernel版本号，如果是给当前kernel制作initramfs，可以用uname -r查看当前的版本号。提供kernel版本号的主要目的是为了在initramfs中添加指定kernel的驱动模块。mkinitramfs会把/lib/modules/${kernel\_version}/ 目录下的一些启动会用到的模块添加到initramfs中。

  update-initramfs

  ```bash
  # 更新当前kernel的initramfs
  update-initramfs -u
  ```

  在添加模块时，initramfs tools只会添加一些必要模块，用户可以通过在/etc/initramfs-tools/modules文件中加入模块名称来指定必须添加的模块。

　　‍

### initrd

　　目前还是有不少Linux发行版采用initrd（即RAM disk的方式）来实现引导，所以了解一下mkinitrd这个命令也很有必要。

　　mkinitrd类似于mkinitramfs，是用于生成initrd的一个工具。最基本的用法参考下面：

```bash
mkinitrd /boot/initrd.img $(uname -r)
```

　　如果需要指定哪些module在启动时必须load，需要加上--preload=module或者 --with=module这样的选项。这两者的区别在于--preload指定的module会在/etc/modprobe.d/\* 里声明的任何SCSI模块之前被加载，--with指定的module会在/etc/modprobe.d/\* 里声明的任何SCSI模块之后被加载。

　　另外还有一个选项需要被注意，即--builtin=module。在manual里这个选项的解释是：Act as if module is built into the kernel being used. mkinitrd will not look for this module, and will not emit an error if it does not exist. This option may be used multiple times.

　　根据上面的解释，可以看出builtin选项另外还有一个取巧的用处。以我所用的平台Acer Aspire One为例， 我在用mkinitrd制作RAM disk镜像是出现一个错误“No module ohci-hcd found ...”，遇到这个情况，builtin选项就起作用了，用--builtin=ohci-hcd， mkinitrd就可以忽略ohci-hcd不存在这个事实了。

　　initrd有两种格式，initrd-image和initrd-cpio。

* 办法一:通过ramdisk来制作的方法比较简单(以ext2文件系统为例)：

  ```bash
  mkfs.ext2 /dev/ram0
  mount /dev/ram0 /mnt/rd
  cp _what_you_like_ /mnt/rd      # 把需要的文件复制过去
  dd if=/dev/ram0 of=/tmp/initrd
  gzip -9 /tmp/initrd
  ```

  这个过程也最能够解释initrd的本质，对于Linux来说，Ramdisk的一个块设备，而initrd是这个块设备上所有内容的“克隆”(由命令dd来完成)而生成的文件。核心中加载initrd相关的代码则用于完成将相反的过程，即将这一个文件恢复到Ramdisk中去。

* 办法二:通过loop设备来制作initrd的过程(losetup,mkfs.ext2)：

  ```bash
  dd if=/dev/zero of=/tmp/initrd bs=1024 count=4096 # 制作一个4M的空白文件
  losetup /dev/loop0 /tmp/initrd                    # 映射到loop设备上；
  mkfs.ext2 /dev/loop0                              # 创建文件系统；
  mount /dev/loop0 /mnt/rd
  cp _what_you_like_ /mnt/rd                        # 复制需要的文件；
  umount /mnt/rd
  losetup -d /dev/loop0
  gzip -9 /tmp/initrd
  ```
* 办法三:mount -o loop

  ```bash
  dd if=/dev/zero of=../initrd.img bs=512k count=5
  mkfs.ext2 -F -m0 ../initrd.img
  mount -t ext2 -o loop ../initrd.img   /mnt
  cp -r * /mnt
  umount /mnt
  gzip -9 ../initrd.img
  ```
* 办法四（新式INITRD:cpio-initrd的制作)

  ```bash
  find . | cpio -c -o > ../initrd.img
  gzip ../initrd.img
  ```
* cpio-initrd

  ```bash
  # 假设当前目录位于准备好的initrd文件系统的根目录下
  find . | cpio -c -o > ../initrd.img
  gzip ../initrd.img
   
  # gen_init_cpio是编译内核时得到的，在内核源代码的 usr 目录下，我们可以通过以下步骤获取它，进入内核源代码 执行：
  make menuconfig
  make usr/
   
  # gen_initramfs_list.sh 在内核源代码的 script 目录下，将这两个文件copy 到/tmp 目录下，
  # /tmp/initrd为解压好的initrd目录，执行以下命令制作initrd ：
  gen_initramfs_list.sh initrd/ > filelist
  gen_init_cpio filelist >initrd.img
  gzip initrd.img
  mv initrd.img initrd-`uname –r`.img
   
  # 只有用这个方式压缩的initrd ，在Linux系统重启的时候才能一正确的文件格式 boot 起来，也可以用
  # 这种方式修改安装光盘的initrd文件 然后进行系统安装。
  ```
