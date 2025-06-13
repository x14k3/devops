

计算机启动分为内核加载前、加载时和加载后3个大阶段，这3个大阶段又可以分为很多小阶段，本文将非常细化分析每一个重要的小阶段。

内核加载前的阶段和操作系统无关，Linux或Windows在这部分的顺序是一样的。由于使用anaconda安装Linux时，默认的图形界面是不支持GPT分区的，即使是目前最新的CentOS 7.3也仍然不支持，所以在本文中主要介绍传统BIOS平台(MBR方式)的启动方式(其实是本人愚笨，看不懂uefi启动方式)。

在内核加载时和加载后阶段，由于CentOS 7采用的是systemd，和CentOS 5或CentOS 6的sysV风格的init大不相同，所以本文也只介绍sysV风格的init。

## 按下电源和bios阶段

按下电源，计算机开始通电，最重要的是要接通cpu的电路，然后通过cpu的针脚让cpu运行起来，只有cpu运行起来才能执行相关代码跳到bios。

bios是按下开机键后第一个运行的程序，它会读取CMOS中的信息，以了解**部分硬件**的信息，比如硬件自检(post)、硬件上的时间、硬盘大小和型号等。其实，手动进入bios界面看到的信息，都是在这一阶段获取到的，如下图。对本文来说，最重要的还是获取到了启动设备以及它们的启动顺序(顺序从上到下)信息。

![1594033205756](net-img-1594033205756-20240424163601-muol070.png)

当硬件检测和信息获取完毕，开始初始化硬件，最后从排在第一位的启动设备中读取MBR，如果第一个启动设备中没有找到合理的MBR，则继续从第二个启动设备中查找，直到找到正确的MBR。

## MBR和各种bootloader阶段

这小节将介绍各种BR(boot record)和各种boot loader，但只是简单介绍其基本作用。

MBR是主引导记录，位于磁盘的第一个扇区，和分区无关，和操作系统无关，Bios一定会读取MBR中的记录。

在MBR中存储了bootloader/分区表/BRID。bootloader占用446个字节，用于引导加载；分区表占用64个字节，每个主分区或扩展分区占用16个字节，如果16个字节中的第一个字节为0x80，**则表示该分区为激活的分区(活动分区)，且只允许有一个激活的分区**；最后2个字节是BRID(boot record ID)，它固定为0x55AA，用于标识该存储设备的MBR是否是合理有效的MBR，如果bios读取MBR发现最后两个字节不是0x55AA，就会读取下一个启动设备。

### boot loader

MBR中的bootloader只占用446字节，所以可存储的代码有限，能加载引导的东西也有限，所以在磁盘的不同位置上设计了多种boot loader。下面将说明各种情况。

在创建文件系统时，是否还记得有些分区的第一个block是boot sector？这个启动扇区中也放了boot loader，大小也很有限。如果是主分区上的boot sector，则该段boot loader所在扇区称为VBR(volumn boot record)，如果是逻辑分区上的boot sector，则该段boot loader所在扇区称为EBR(Extended boot sector)。但很不幸，这两种方式的boot loader都很少被使用上了，因为它们很不方便，加上后面出现了启动管理器(LILO和GRUB)，它们就被遗忘了。但即使如此，在分区中还是存在boot sector。

### 分区表

硬盘分区的好处之一就是可以在不同的分区中安装不同的操作系统，但boot loader必须要知道每个操作系统具体是在哪个分区。

分区表的长度只有64个字节，里面又分成四项，每项16个字节。所以，一个硬盘最多只能分四个主分区。

每个主分区表项的16个字节，都由6个部分组成：

- (1).第1个字节：只能为0或者0x80。0x80表示该主分区是激活分区，0表示非激活分区。单磁盘只能有一个主分区是激活的。
- (2).第2-4个字节：主分区第一个扇区的物理位置（柱面、磁头、扇区号等等）。
- (3).第5个字节：主分区类型。
- (4).第6-8个字节：主分区最后一个扇区的物理位置。
- (5).第9-12字节：该主分区第一个扇区的逻辑地址。
- (6).第13-16字节：主分区的扇区总数。

最后的四个字节『主分区的扇区总数』，决定了这个主分区的长度。也就是说，一个主分区的扇区总数最多不超过2的32次方。如果每个扇区为512个字节，就意味着单个分区最大不超过2TB。

### 采用VBR/EBR方式引导操作系统

暂且先不讨论grub如何管理启动操作系统的，以VBR和EBR引导操作系统为例。

当bios读取到MBR中的boot loader后，**会继续读取分区表**。分两种情况：

1. 如果查找分区表时发现某个主分区表的第一个字节是0x80，也就是激活的分区，那么说明操作系统装在了该主分区，然后执行已载入的MBR中的boot loader代码，加载该激活主分区的VBR中的boot loader，至此，控制权就交给了VBR的boot loader了；
2. 如果操作系统不是装在主分区，那么肯定是装在逻辑分区中，所以查找完主分区表后会继续查找扩展分区表，直到找到EBR所在的分区，然后MBR中的boot loader将控制权交给该EBR的boot loader。

也就是说，如果一块硬盘上装了多个操作系统，那么boot loader会分布在多个地方，可能是VBR，也可能是EBR，但MBR是一定有的，这是被bios给『绑定』了的。在装LINUX操作系统时，其中有一个步骤就是询问你MBR装在哪里的，但这个MBR并非一定真的是MBR，可能是MBR，也可能是VBR，还可能是EBR，并且想要单磁盘多系统共存，则MBR一定不能被覆盖(此处不考虑grub)。

如下图，是我测试单磁盘装3个操作系统时的分区结构。其中/dev/sda{1,2,3}是第一个CentOS 6系统，/dev/sda{5,6,7}是第二个CentOS 7系统，/dev/sda{8,9,10}是第三个CentOS 6系统，每一个操作系统的分区序号从前向后都是/boot分区、根分区、swap分区。

![1594033414233](net-img-1594033414233-20240424163602-szlfm8g.png)

再看下图，是装第三个操作系统时的询问boot loader安装位置的步骤。

![1594033445919](net-img-1594033445919-20240424163602-w2zpwbi.png)

装第一个操作系统时，boot loader可以装在/dev/sda上，也可以选择装在/dev/sda1上，这时装的是MBR和VBR，任选一个都会将另一个也装上，从第二个操作系统开始，装的是EBR而非MBR，且应该指定boot loader位置(如/dev/sda5和/dev/sda8)，否则默认选项是装在/dev/sda上，但这会覆盖原有的MBR。

另外，在指定boot loader安装路径的下方，还有一个方框是操作系统列表，这就是操作系统菜单，其中可以指定默认的操作系统，这里的默认指的是MBR默认跳转到哪个VBR或EBR上。

所以，MBR/VBR和EBR之间的跳转关系如下图。

![1594033487575](net-img-1594033487575-20240424163603-6bs850x.png)

使用这种方式的菜单管理操作系统启动，无需什么stage1，stage1.5和stage2的概念，只要跳转到了分区上的VBR或EBR，那么直接就可以加载引导该分区上的操作系统。

但是，这种管理操作系统启动的菜单已经没有意义了，现在都是使用grub来管理，所以装第二个操作系统或第n个操作系统时不手动指定boot loader安装位置，覆盖掉MBR也无所谓，想要实现单磁盘多系统共存所需要做的，仅仅只是修改grub的配置文件而已。

使用grub管理引导菜单时，VBR/EBR就毫无用处了，具体的见下文。

## grub阶段

使用grub管理启动，则MBR中的boot loader是由grub程序安装的，此外还会安装其他的boot loader。CentOS 6使用的是传统的grub，而CentOS 7使用的是grub2。

如果使用的是传统的grub，则安装的boot loader为stage1、stage1\_5和stage2，如果使用的是grub2，则安装的是boot.img和core.img。传统grub和grub2的区别还是挺大的，所以下面分开解释，如果对于grub有不理解之处，见grub2详解。

### 使用grub2时的启动过程

grub2程序安装grub后，会在/boot/grub2/i386-pc/目录下生成boot.img和core.img文件，另外还有一些模块文件，其中包括文件系统类的模块。

```bash
$ find /boot/grub2/i386-pc/ -name '*.img' -o -name "*fs.mod" -o -name "*ext[0-9].mod"   
/boot/grub2/i386-pc/affs.mod
/boot/grub2/i386-pc/afs.mod
/boot/grub2/i386-pc/bfs.mod
/boot/grub2/i386-pc/btrfs.mod
/boot/grub2/i386-pc/cbfs.mod
/boot/grub2/i386-pc/ext2.mod   # ext2、ext3和ext4都使用该模块
/boot/grub2/i386-pc/hfs.mod
/boot/grub2/i386-pc/jfs.mod
/boot/grub2/i386-pc/ntfs.mod
/boot/grub2/i386-pc/procfs.mod
/boot/grub2/i386-pc/reiserfs.mod
/boot/grub2/i386-pc/romfs.mod
/boot/grub2/i386-pc/sfs.mod
/boot/grub2/i386-pc/xfs.mod
/boot/grub2/i386-pc/zfs.mod
/boot/grub2/i386-pc/core.img      # 注意此行
/boot/grub2/i386-pc/boot.img      # 注意此行
```

其中boot.img就是安装在MBR中的boot loader。当然，它们的内容是不一样的，安装boot loader时grub2-install会将boot.img转换为合适的汇编代码写入MBR中的boot loader部分。

core.img是第二段Boot loader段，grub2-install会将core.img转换为合适的汇编代码写入到紧跟在MBR后面的空间，这段空间是MBR之后、第一个分区之前的空闲空间，被称为MBR gap，这段空间最小31KB，但一般都会是1MB左右。

实际上，core.img是多个img文件的结合体。它们的关系如下图：

![1594033590071](net-img-1594033590071-20240424163604-byv6vs4.png)

这张图解释了开机过程中grub2阶段的所有过程，boot.img段的boot loader只有一个作用，就是跳转到core.img对应的boot loader的第一个扇区，对于从硬盘启动的系统来说，该扇区是diskboot.img的内容，diskboot.img的作用是加载core.img中剩余的内容。

由于diskboot.img所在的位置是以硬编码的方式写入到boot.img中的，所以boot.img总能找到core.img中diskboot.img的位置并跳转到它身上，随后控制权交给diskboot.img。随后diskboot.img加载压缩后的kernel.img(注意，是grub的kernel不是操作系统的kernel)以初始化grub运行时的各种环境，控制权交给kernel.img。

但直到目前为止，core.img都还不识别/boot所在分区的文件系统，所以kernel.img初始化grub环境的过程就包括了加载模块，严格地说不是加载，因为在安装grub时，文件系统类的模块已经嵌入到了core.img中，例如ext类的文件系统模块ext2.mod。

加载了模块后，kernel.img就能识别/boot分区的文件系统，也就能找到grub的配置文件/boot/grub2/grub.cfg，有了grub.cfg就能显示启动菜单，我们就能自由的选择要启动的操作系统。

![1594033605187](net-img-1594033605187-20240424163605-l1if182.png)

当选择某个菜单项后，kernel.img会根据grub.cfg中的配置加载对应的操作系统内核(/boot目录下vmlinuz开头的文件)，并向操作系统内核传递启动时参数，包括根文件系统所在的分区，init ramdisk(即initrd或initramfs)的路径。例如下面是某个菜单项的配置：

```bash
menuentry 'CentOS 6' --unrestricted {
  search --no-floppy --fs-uuid --set=root f5d8939c-4a04-4f47-a1bc-1b8cbabc4d32
  linux16 /vmlinuz-2.6.32-504.el6.x86_64 root=UUID=edb1bf15-9590-4195-aa11-6dac45c7f6f3 ro quiet
  initrd16 /initramfs-2.6.32-504.el6.x86_64.img
}
```

加载完操作系统内核后grub2就将控制权交给操作系统内核。

总结下，从MBR开始后的过程是这样的：

- 1.执行MBR中的boot loader(即boot.img)跳转到diskboot.img。
- 2.执行diskboot.img，加载core.img剩余的部分，并跳转到kernel.img。
- 3.kernel.img读取/boot/grub2/grub2.cfg，并显示启动管理菜单。
- 4.选中某菜单后，kernel.img加载该菜单项配置的操作系统内核/boot/vmlinux-XXX，并传递内核启动参数，包括根文件系统所在分区和init ramdisk的路径。
- 5.控制权交给操作系统内核。

### 使用传统grub时的启动过程

传统grub对应的boot loader是stage1和stage2，从stage1跳转到stage2大多数情况下还会用到stage1\_5对应的boot loader。

与grub2相比，stage1和boot.img的作用是类似的，都在MBR中。当该段boot loader执行后，它的目的是跳转到stage1\_5的第一个扇区上，然后由该扇区的代码加载剩余的内容，并跳转到stage2的第一个扇区上。

stage1\_5存在的理由是因为stage2功能较多，导致其文件体积较大(一般至少都有100多K)，所以并没有像core.img一样嵌入到磁盘上，而是简单地将其放在了boot分区上，但stage1并不识别boot分区的文件系统类型，所以借助中间的辅助boot loader即stage1\_5来跳转。

stage1\_5的目的之一是识别文件系统，但文件系统的类型有很多，所以对应的stage1\_5也有很多种。

```bash
$ ls -C /boot/grub/*stage1_5*
/boot/grub/e2fs_stage1_5     /boot/grub/jfs_stage1_5  
/boot/grub/vstafs_stage1_5   /boot/grub/fat_stage1_5
/boot/grub/minix_stage1_5    /boot/grub/xfs_stage1_5
/boot/grub/ffs_stage1_5      /boot/grub/reiserfs_stage1_5
/boot/grub/iso9660_stage1_5  /boot/grub/ufs2_stage1_5
```

虽然有很多种stage1\_5，但每个boot分区也只能对应一种stage1\_5。这个stage1\_5对应的boot loader一般会被嵌入到MBR后、第一个分区前的中间那段空间(即MBR gap)。

当执行了stage1\_5对应的boot loader后，stage1\_5就能识别出boot所在的分区，并找到stage2文件的第一个扇区，然后跳转过去。

当控制权交给了stage2，stage2就能加载grub的配置文件/boot/grub/grub.conf并显示菜单并初始化grub的运行时环境，当选中操作系统后，stage2将和kernel.img一样加载操作系统内核，传递内核启动参数，并将控制权交给操作系统内核。

所以，stage1、stage1\_5和stage2之间的关系如下图：

![1594033697747](net-img-1594033697747-20240424163605-d5cjo0i.png)

虽然绝大多数都提供了stage1\_5，但它不是必须的，它的作用仅仅只是识别boot分区的文件系统类型，对于一个会编程的人来说，可以将固定boot分区的文件系统识别代码嵌入到stage1中，这样stage1自身就能识别boot分区，就不需要stage1\_5了。

看看安装grub时，grub到底做了些什么工作。

```bash
grub> setup (hd0)
 Checking if "/boot/grub/stage1" exists... yes
 Checking if "/boot/grub/stage2" exists... yes
 Checking if "/boot/grub/e2fs_stage1_5" exists... yes
 Running "embed /boot/grub/e2fs_stage1_5 (hd0)"...  15 sectors are embedded.
succeeded
 Running "install /boot/grub/stage1 (hd0) (hd0)1+15 p (hd0,0)/boot/grub/stage2 /boot/grub/menu.lst"... succeeded
Done.
```

首先检测各stage文件是否存在于/boot/grub目录下，随后嵌入stage1\_5到磁盘上，该文件系统类型的stage1\_5占用了15个扇区，最后安装stage1，并告知stage1 stage1\_5的位置是第1到第15个扇区，之所以先嵌入stage1\_5再嵌入stage1就是为了让stage1知道stage1\_5的位置，最后还告知了stage1 stage2和配置文件menu.lst(它是grub.conf的软链接)的路径。

## 内核加载阶段

提前说明，下文所述均为sysV init系统启动风格，systemd的启动管理方式大不相同，所以不要将systemd管理的启动方式与此做比较。

到目前为止，内核已经被加载到内存掌握了控制权，且收到了boot loader最后传递的内核启动参数以及init ramdisk的路径。

所有的内核都是以bzImage方式压缩过的，压缩后CentOS 6的内核大小大约为4M，CentOS 7的内核大小大约为5M。内核要能正常运作下去，它需要进行解压释放。

解压释放之后，将创建pid为0的idle进程，该进程非常重要，后续内核所有的进程都是通过fork它创建的，且很多cpu降温工具就是强制执行idle进程来实现的。

然后创建pid=1和pid=2的内核进程。pid=1的进程也就是init进程，pid=2的进程是kthread内核线程，它的作用是在真正调用init程序之前完成内核环境初始化和设置工作，例如根据grub传递的内核启动参数找到init ramdisk并加载。

所谓的**救援模式**就是刚加载完内核，init进程接收到控制权的那一阶段，因为没有进行任何操作系统初始化过程，所以可以修复和操作系统相关的很多问题。另外，安装镜像中也有内核，可以通过安装镜像进入救援模式，这种进入救援模式的方式几乎可修复任何操作系统启动相关的问题，即使是/boot目录下内核镜像缺失都可以重装。(还有一种单用户模式，它是运行级别为1的环境，所以已经初始化完运行级别，见后文)

### 加载init ramdisk

在前面，已经创建了pid=1的init进程和pid=2的kthread进程，但注意，它们都是内核线程，全称应该是kernel\_init和kernel\_kthread，而真正能被ps捕获到的pid=1的init进程是由kernel\_init调用init程序后形成的。

要加载/sbin/init程序，首先要找到根分区，根分区是有文件系统的，所以内核需要先识别文件系统并加载文件系统的驱动，但文件系统的驱动又是放在根分区的，这就出现了先有鸡还是先有蛋的矛盾。

解决的方法之一是像grub2识别boot分区的文件系统一样，将根文件系统驱动模块嵌入到内核中，但文件系统的种类太多，而且会升级，这样就导致内核不断的嵌入新的文件系统驱动模块，内核不断增大，这显然是不合适的。

解决方法之二则像传统grub借助中间过渡引导段stage1\_5一样，将根文件系统的驱动模块放入一个中间过渡文件，在加载根文件系统之前先加载这个过渡文件，再由过渡文件跳转到根文件系统。

方法二正是现在采用的，其采用的中间过渡文件称为init ramdisk，它是在安装完操作系统时生成的，这样它会收集到当前操作系统的根文件系统是什么类型的文件系统，也就能只嵌入一个对应的文件系统驱动模块使其变得足够小。

![1594033771298](net-img-1594033771298-20240424163606-0m86696.png)

在CentOS 5上采用的init ramdisk称为initrd，而CentOS 6和CentOS 7采用的则是initramfs，它们的目的是一样的，但在实现上却大有不同。但它们都存放在/boot目录下。

```bash
$ ll -h /boot/init*
-rw-------. 1 root root 19M Feb 25 11:53 /boot/initramfs-2.6.32-504.el6.x86_64.img
```

可以看到，它们的大小有十多兆，由此也可知道init ramdisk的作用肯定不仅仅只是找到根文件系统，它还会做其他工作。具体还做什么工作，请继续阅读下文。

### initrd

initrd其实是一个镜像文件系统，是在内存中划分一片区域模拟磁盘分区，在该文件中包含了找到根文件系统的脚本和驱动。

既然是文件系统，那么内核也必须要带有对应文件系统的驱动，另外文件系统要使用就必须有根`/`​，这个根是内存中的`虚根`​。由于内核加载到这里已经初始化一些运行环境了，所以**内核的运行状态等参数也要保存下来，保存的位置就是内存中虚根下的/proc和/sys，此外还有收集到的硬件设备信息以及设备的运行环境也要保存下来，保存的位置是/dev**。到此为止，pid=2的内核线程kernel\_kthread就完成了基本工作，开始转到kernel\_init进程上了。

再之后就是kernel\_init挂载真正的根文件系统并从虚根切换到实根，最后kernel\_init将调用init程序，也就是真正的pid=1的init进程，然后将控制权交给init，所以从现在开始，将切换到用户空间，后续剩余的事情都将由用户空间的程序完成。

以下是CentOS 5.8中initrd文件的解压过程和解包后的目录结构。

```bash
$ cp /boot/initrd-2.6.18-308.el5.img /tmp/initrd.gz
$ gunzip initrd.gz
$ cpio -id < initrd  
$ ls 
bin  dev  etc  init  initrd  lib  proc  sbin  sys  sysroot
```

### initramfs

initramfs比initrd又先进了一些，initrd必须是一个文件系统，是在内存中模拟出磁盘分区的，所以内核必须要带有它的文件系统驱动，而initramfs则仅仅只是一个镜像压缩文件而非文件系统，所以它不需要带文件系统驱动，在加载时，内核会将其解压的内容装入到一个tmpfs 中。

initramfs和initrd最大的区别在于init进程的区别对待。initramfs为了尽早进入用户空间，它将init程序集成到了initramfs镜像文件中，这样就可以在initramfs装入tmpfs时直接运行init进程，而不用去找根文件系统下的/sbin/init，由此挂载根文件系统的工作将由init来完成，而不再是内核线程kernel\_init完成。最后从虚根切换到实根。

那根分区下的/sbin/init是干嘛的呢？可以认为是init ramdisk中init的一个备份，如果ramdisk中找不到init就会去找/sbin/init。另外，在正常运行的操作系统环境下，/sbin/init还经常用来完成其他工作，如发送信号。

其实initramfs完成了很多工作，解开它的镜像文件就能发现它的目录结构和真实环境下的目录结构类似。以下是CentOS 7上initramfs-3.10.0-327.el7.x86\_64解包过程和解包后的目录结构。

```bash
[~]$ cp /boot/initramfs-3.10.0-327.el7.x86_64.img /tmp/initramfs.gz
[~]$ cd /tmp; gunzip /tmp/initramfs.gz
[tmp]$ cpio -id < initramfs
[tmp]$ ls -l
total 8
lrwxrwxrwx  1 root root    7 Jun 29 23:28 bin -> usr/bin
drwxr-xr-x  2 root root   42 Jun 29 23:28 dev
drwxr-xr-x 11 root root 4096 Jun 29 23:28 etc
lrwxrwxrwx  1 root root   23 Jun 29 23:28 init -> usr/lib/systemd/systemd
lrwxrwxrwx  1 root root    7 Jun 29 23:28 lib -> usr/lib
lrwxrwxrwx  1 root root    9 Jun 29 23:28 lib64 -> usr/lib64
drwxr-xr-x  2 root root    6 Jun 29 23:28 proc
drwxr-xr-x  2 root root    6 Jun 29 23:28 root
drwxr-xr-x  2 root root    6 Jun 29 23:28 run
lrwxrwxrwx  1 root root    8 Jun 29 23:28 sbin -> usr/sbin
-rwxr-xr-x  1 root root 3041 Jun 29 23:28 shutdown
drwxr-xr-x  2 root root    6 Jun 29 23:28 sys
drwxr-xr-x  2 root root    6 Jun 29 23:28 sysroot
drwxr-xr-x  2 root root    6 Jun 29 23:28 tmp
drwxr-xr-x  7 root root   61 Jun 29 23:28 usr
drwxr-xr-x  2 root root   27 Jun 29 23:28 var
```

另外，还可以在其sbin目录下发现init程序。

```bash
[tmp]$ ll sbin/init
lrwxrwxrwx 1 root root 22 Jun 29 23:28 sbin/init -> ../lib/systemd/systemd
```

## 操作系统初始化

下文解释的是sysV风格的系统环境，与systemd初始化大不相同。

当init进程掌握控制权后，意味着已经进入了用户空间，后续的事情也将以用户空间为主导来完成。

init的名称是initialize的缩写，是初始化的意思，所以它的作用也就是初始化的作用。在内核加载阶段，也有初始化动作，初始化的环境是内核的环境，是由kernel\_init、kernel\_thread等内核线程完成的。而init掌握控制权后，已经可以和用户空间交互，意味着真正的开始进入操作系统，所以它初始化的是操作系统的环境。

操作系统初始化涉及了不少过程，大致如下：读取运行级别；初始化系统类的环境；根据运行级别初始化用户类的环境；执行rc.local文件完成用户自定义开机要执行的命令；加载终端；

### 运行级别

在sysV风格的系统下，使用了运行级别的概念，不同运行级别初始化不同的系统类环境，你可以认为windows的安全模式也是使用运行级别的一种产物。

在Linux系统中定义了7个运行级别，使用0-6的数字表示。

```bash
0：halt，即关机
1：单用户模式
2：不带NFS的多用户模式
3：完整多用户模式
4：保留未使用的级别
5：X11，即图形界面模式
6：reboot，即重启
```

实际上，执行关机或重启命令的本质就是向init进程传递0或6这两个运行级别。

sysV的init程序读取/etc/inittab文件来获取默认的运行级别，并根据此文件所指定的配置执行默认运行级别对应的操作。注意，systemd管理的系统是没有/etc/inittab文件的，即使有也仅仅只是出于提醒的目的，因为systemd没有了运行级别的概念。

CentOS 6.6上该文件内容如下：

```bash
[root@xuexi ~]# cat /etc/inittab 
# inittab is only used by upstart for the default runlevel.
#
# ADDING OTHER CONFIGURATION HERE WILL HAVE NO EFFECT ON YOUR SYSTEM.
#
# System initialization is started by /etc/init/rcS.conf
#
# Individual runlevels are started by /etc/init/rc.conf
#
# Ctrl-Alt-Delete is handled by /etc/init/control-alt-delete.conf
#
# Terminal gettys are handled by /etc/init/tty.conf and /etc/init/serial.conf,
# with configuration in /etc/sysconfig/init.
#
# For information on how to write upstart event handlers, or how
# upstart works, see init(5), init(8), and initctl(8).
#
# Default runlevel. The runlevels used are:
#   0 - halt (Do NOT set initdefault to this)
#   1 - Single user mode
#   2 - Multiuser, without NFS (The same as 3, if you do not have networking)
#   3 - Full multiuser mode
#   4 - unused
#   5 - X11
#   6 - reboot (Do NOT set initdefault to this)
# 
id:3:initdefault:
```

该文件告诉我们，系统初始化过程由/etc/init/rcS.conf完成，运行级别类的初始化过程由/etc/init.conf来完成，按下CTRL+ALT+DEL键要执行的过程由/etc/init/control-alt-delete.conf来完成，终端加载的过程由/etc/init/tty.conf和/etc/init/serial.conf读取配置文件/etc/sysconfig/init来完成。再文件最后，还有一行`id:3:initdefault`​，表示默认的运行级别为3，即完整的多用户模式。

确认了要进入的运行级别后，init将先读取/etc/init/rcS.conf来完成系统环境类初始化动作，再读取/etc/init/rc.conf来完成运行级别类动作。

### 系统环境初始化

先看看/etc/init/rcS.conf文件的内容。

```bash

[root@xuexi ~]# cat /etc/init/rcS.conf 
# rcS - runlevel compatibility
#
# This task runs the old sysv-rc startup scripts.
#
# Do not edit this file directly. If you want to change the behaviour,
# please create a file rcS.override and put your changes there.

start on startup

stop on runlevel

task

# Note: there can be no previous runlevel here, if we have one it's bad
# information (we enter rc1 not rcS for maintenance).  Run /etc/rc.d/rc
# without information so that it defaults to previous=N runlevel=S.
console output
pre-start script
  for t in $(cat /proc/cmdline); do
    case $t in
      emergency)
        start rcS-emergency
        break
      ;;
    esac
  done
end script
exec /etc/rc.d/rc.sysinit
post-stop script
  if [ "$UPSTART_EVENTS" = "startup" ]; then
    [ -f /etc/inittab ] && runlevel=$(/bin/awk -F ':' '$3 == "initdefault" && $1 !~ "^#" { print $2 }' /etc/inittab)
    [ -z "$runlevel" ] && runlevel="3"
    for t in $(cat /proc/cmdline); do
      case $t in
        -s|single|S|s) runlevel="S" ;;
        [1-9])         runlevel="$t" ;;
      esac
    done
    exec telinit $runlevel
  fi
end script
```

其中`exec /etc/rc.d/rc.sysinit`​这一行就表示要执行/etc/rc.d/rc.sysinit文件，该文件定义了系统初始化(system initialization)的内容，包括：

```bash
(1).确认主机名。
(2).挂载/proc和/sys等特殊文件系统，使得内核参数和状态可与人进行交互。是否还记得在内核加载阶段时的/proc和/sys？
(3).启动udev，也就是启动类似windows中的设备管理器。
(4)初始化硬件参数，如加载某些驱动，设置时钟等。
(5).设置主机名。
(6).执行fsck检测磁盘是否健康。
(7).挂载/etc/fstab中除/proc和NFS的文件系统。
(8).激活swap。
(9).将所有执行的操作写入到/var/log/dmesg文件中。
```

### 运行级别环境初始化

执行完系统初始化后，接下来就是执行运行级别的初始化。先看看/etc/init/rc.conf的内容。

```bash
[root@xuexi ~]# cat /etc/init/rc.conf 
# rc - System V runlevel compatibility
#
# This task runs the old sysv-rc runlevel scripts.  It
# is usually started by the telinit compatibility wrapper.
#
# Do not edit this file directly. If you want to change the behaviour,
# please create a file rc.override and put your changes there.

start on runlevel [0123456]

stop on runlevel [!$RUNLEVEL]

task

export RUNLEVEL
console output
exec /etc/rc.d/rc $RUNLEVEL
```

最后一行`exec /etc/rc.d/rc $RUNLEVEL`​说明调用/etc/rc.d/rc这个脚本来初始化指定运行级别的环境。Linux采用了将各运行级别初始化内容分开管理的方式，将0-6这7个运行级别要执行的初始化脚本分别放入rc\[0-6\].d这7个目录中。

```bash
[root@xuexi ~]# ls -l /etc/rc.d/
total 60
drwxr-xr-x. 2 root root  4096 Jun 11 02:42 init.d
-rwxr-xr-x. 1 root root  2617 Oct 16  2014 rc
drwxr-xr-x. 2 root root  4096 Jun 11 02:42 rc0.d
drwxr-xr-x. 2 root root  4096 Jun 11 02:42 rc1.d
drwxr-xr-x. 2 root root  4096 Jun 11 02:42 rc2.d
drwxr-xr-x. 2 root root  4096 Jun 11 02:42 rc3.d
drwxr-xr-x. 2 root root  4096 Jun 11 02:42 rc4.d
drwxr-xr-x. 2 root root  4096 Jun 11 02:42 rc5.d
drwxr-xr-x. 2 root root  4096 Jun 11 02:42 rc6.d
-rwxr-xr-x. 1 root root   220 Oct 16  2014 rc.local
-rwxr-xr-x. 1 root root 19914 Oct 16  2014 rc.sysinit
```

实际上/etc/init.d/下的脚本才是真正的脚本，放入rcN.d目录中的文件只不过是/etc/init.d/目录下脚本的软链接。注意，/etc/init.d是Linux耍的一个小把戏，它是/etc/rc.d/init.d的一个符号链接，在有些类unix系统中是没有/etc/init.d的，都是直接使用/etc/rc.d/init.d。

以/etc/rc.d/rc3.d为例。

```bash
[root@xuexi ~]# ll /etc/rc.d/rc3.d/ | head
total 0
lrwxrwxrwx. 1 root root 16 Feb 25 11:52 K01smartd -> ../init.d/smartd
lrwxrwxrwx. 1 root root 16 Feb 25 11:52 K10psacct -> ../init.d/psacct
lrwxrwxrwx. 1 root root 19 Feb 25 11:51 K10saslauthd -> ../init.d/saslauthd
lrwxrwxrwx  1 root root 22 Jun 10 08:59 K15htcacheclean -> ../init.d/htcacheclean
lrwxrwxrwx  1 root root 15 Jun 10 08:59 K15httpd -> ../init.d/httpd
lrwxrwxrwx  1 root root 15 Jun 11 02:42 K15nginx -> ../init.d/nginx
lrwxrwxrwx. 1 root root 18 Feb 25 11:52 K15svnserve -> ../init.d/svnserve
lrwxrwxrwx. 1 root root 20 Feb 25 11:51 K50netconsole -> ../init.d/netconsole
lrwxrwxrwx  1 root root 17 Jun 10 00:50 K73winbind -> ../init.d/winbind
```

可见，rcN.d中的文件都以K或S加一个数字开头，其后才是脚本名称，且它们都是/etc/rc.d/init.d中文件的链接。S开头表示进入该运行级别时要运行的程序，S字母后的数值表示启动顺序，数字越大，启动的越晚；K开头的表示退出该运行级别时要杀掉的程序，数值表示关闭的顺序。

所有这些文件都是由/etc/rc.d/rc这个程序调用的，K开头的则传给rc一个stop参数，S开头的则传给rc一个start参数。

打开rc0.d和rc6.d这两个目录，你会发现在这两个目录中除了`S00killall`​和`S01reboot`​，其余都是K开头的文件。

而**在rc[2-5].d这几个目录中，都有一个S99local文件，且它们都是指向/etc/rc.d/rc.local的软链接**。S99表示最后启动的一个程序，所以rc.local中的程序是2345这4个运行级别初始化过程中最后运行的一个脚本。这是Linux提供给我们定义自己想要在开机时(严格地说是进入运行级别)就执行的命令的文件。

当初始化完运行级别环境后，将要准备登录系统了。

所谓的**单用户模式**(runlevel=1)，就是初始化完运行级别1对应的环境。因为已经初始化了操作系统和运行级别，所以单用户模式所处的层次要比救援模式高的多，能修复的问题也就只有它后面还未初始化的过程：终端初始化和用户登录问题。

## 终端初始化和登录系统

Linux是多任务多用户的操作系统，它允许多人同时在线工作。但每个人都必须要输入用户名和密码才能验证身份并最终登录。但登陆时是以图形界面的方式给用户使用，还是以纯命令行模式给用户使用呢？这是终端决定的，也就是说在登录前需要先加载终端。

### 终端初始化

在Linux上，每次开机都必然会开启所有支持的虚拟终端，如下图。

![1594034222803](net-img-1594034222803-20240424163607-zwobbno.png)

这些虚拟终端是由getty命令(get tty)来完成的，getty命令有很多变种，有mingetty、agetty、rungettty等，在CentOS 5和CentOS 6都使用mingetty，在CentOS 7上使用agetty。getty命令的作用之一是调用登录程序/bin/login。

例如，在CentOS 6下，捕获tty终端情况。

```bash
[root@xuexi ~]# ps -elf | grep tt[y]
4 S root  1412  ...  1016 n_tty_ Jun21 tty2  ... /sbin/mingetty /dev/tty2
4 S root  1414  ...  1016 n_tty_ Jun21 tty3  ... /sbin/mingetty /dev/tty3
4 S root  1417  ...  1016 n_tty_ Jun21 tty4  ... /sbin/mingetty /dev/tty4
4 S root  1419  ...  1016 n_tty_ Jun21 tty5  ... /sbin/mingetty /dev/tty5
4 S root  1421  ...  1016 n_tty_ Jun21 tty6  ... /sbin/mingetty /dev/tty6
4 S root  1492  ... 27118 n_tty_ Jun21 tty1  ... -bash
```

在CentOS 7下，捕获tty终端情况。

```bash
[root@xuexi tmp]# ps -elf | grep tt[y]
4 S root  8258  ...  27507 n_tty_ 04:17 tty2  ... /sbin/agetty --noclear tty2 linux
4 S root  8259  ...  27507 n_tty_ 04:17 tty3  ... /sbin/agetty --noclear tty3 linux
4 S root  8260  ...  27507 n_tty_ 04:17 tty4  ... /sbin/agetty --noclear tty4 linux
4 S root  8262  ...  29109 n_tty_ 04:17 tty1  ... -bash
4 S root  8307  ...  29109 n_tty_ 04:17 tty5  ... -bash
4 S root  8348  ...  29136 n_tty_ 04:17 tty6  ... -bash
```

细心一点会发现，有的tty终端仍然以/sbin/mingetty进程或/sbin/agetty进程显示，有些却以bash进程显示。这是因为getty进程在调用/bin/login后，如果输入用户名和密码成功登录了某个虚拟终端，那么gettty程序会融合到bash(假设bash是默认的shell)进程，这样getty进程就不会再显示了。

虽然getty不显示了，但并不代表它消失了，它仍以特殊的方式存在着。是否还记得/etc/inittab文件？此文件中提示了终端加载的过程由/etc/init/tty.conf读取配置文件/etc/sysconfig/init来完成。

```bash
[root@xuexi ~]# grep tty -A 1 /etc/inittab 
# Terminal gettys are handled by /etc/init/tty.conf and /etc/init/serial.conf,
# with configuration in /etc/sysconfig/init.
```

那么就看看/etc/init/tty.conf文件。

```bash
[root@xuexi ~]# cat /etc/init/tty.conf 
# tty - getty
#
# This service maintains a getty on the specified device.
#
# Do not edit this file directly. If you want to change the behaviour,
# please create a file tty.override and put your changes there.

stop on runlevel [S016]

respawn
instance $TTY
exec /sbin/mingetty $TTY
usage 'tty TTY=/dev/ttyX  - where X is console id'
```

此文件中的respawn表示进程由init进程监视，即使被杀掉了也会由init来重启它。所以，只要getty进程一结束，init会立即监视到而重启该进程。因此，用户登录成功后getty只是融合到了bash进程中，并非退出，否则init会立即重启它，而它会调用login程序让你再次输入用户和密码。

再看看/etc/sysconfig/init文件。

```bash
[root@xuexi ~]# cat /etc/sysconfig/init 
# color => new RH6.0 bootup
# verbose => old-style bootup
# anything else => new style bootup without ANSI colors or positioning
BOOTUP=color
# column to start "[  OK  ]" label in 
RES_COL=60
# terminal sequence to move to that column. You could change this
# to something like "tput hpa ${RES_COL}" if your terminal supports it
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
# terminal sequence to set color to a 'success' color (currently: green)
SETCOLOR_SUCCESS="echo -en \\033[0;32m"
# terminal sequence to set color to a 'failure' color (currently: red)
SETCOLOR_FAILURE="echo -en \\033[0;31m"
# terminal sequence to set color to a 'warning' color (currently: yellow)
SETCOLOR_WARNING="echo -en \\033[0;33m"
# terminal sequence to reset to the default color.
SETCOLOR_NORMAL="echo -en \\033[0;39m"
# Set to anything other than 'no' to allow hotkey interactive startup...
PROMPT=yes
# Set to 'yes' to allow probing for devices with swap signatures
AUTOSWAP=no
# What ttys should gettys be started on?
ACTIVE_CONSOLES=/dev/tty[1-6]
# Set to '/sbin/sulogin' to prompt for password on single-user mode
# Set to '/sbin/sushell' otherwise
SINGLE=/sbin/sushell

```

其中ACTIVE\_CONSOLES指令决定了要开启哪些虚拟终端。SINGLE决定了在单用户模式下要调用哪个login程序和哪个shell。

### 登录过程

如果不在虚拟终端登录，而是通过为ssh分配的伪终端登录，那么到创建完getty进程那一步其实开机流程已经完成了。但不管在哪种终端下登录，登录过程也可以算作开机流程的一部分，所以也简单说明下。

getty进程启用虚拟终端后将调用login进程提示用户输入用户名或密码(或伪终端的连接程序如ssh提示输入用户名和密码)，当用户输入完成后，将验证输入的用户名是否合法，密码是否正确，用户名是否是明确被禁止登陆的，PAM模块对此用户的限制是如何的等等，还要将登录过程记录到各个日志文件中。如果登录成功，将加载该用户的bash，加载bash过程需要读取各种配置文件，初始化各种环境等等。但不管怎么说，只要登录成功就表示开机流程全部完成了。

‍
