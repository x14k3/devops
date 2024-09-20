# openWRT

　　OpenWrt 可以被描述为一个嵌入式的 Linux 发行版。它是一个适用于路由器的Linux发行版。和其他Linux发行版一样，它也内置了包管理工具，你可以从一个软件仓库里直接安装软件。
OpenWrt可以用在所有需要嵌入式Linux的地方，它有众多功能，比如SSH服务器，VPN，流量整形服务，甚至是BitTorrent客户端。

## 软路由&硬路由

　　*硬路由* 其实就是我们市面上能正常买到的大厂商制作的无线路由器。比如华硕啊，网件，领势，tplink，mercury，等等。使用特定电子电路和低功耗cpu来实现交换逻辑和寻址的_路由器_。

　　*软路由* 就是**台式机或服务器配合软件形成路由解决方案，主要靠软件的设置，达成路由器的功能**。 它是由个人电脑（X86架构的CPU）+Linux系统+专用的路由程序（openwrt、爱快、ros、lede等）组成，说白了软路由就是PC的硬件加上路由系统来实现路由器的功能.

---

## 固件版本区别

　　固件分为三个版本，Lean 版，Offical 版，Project 版:

- Lean 基于 [Lean 大源码](https://github.com/coolsnowwolf/lede) 编译的固件 (Luci 采用 Lean 版 Luci 18.06 )；运行稳定，插件数量略多于 Offical 版，默认情况下，建议使用此版；
- Offical 基于 [OpenWrt 官方源码](https://github.com/openwrt/openwrt/tree/master) Master 分支编译的固件 (Luci 采用官方版 Luci 19.07)；Offical 版固件使用官方 Snapshot 源码 + 官方 LuCI 19.07 源码编译，在 Offical 版固件的基础上，添加了大多数 Lean 版源码中的插件，此版本比较难用，但对官方源的兼容性较好，如果你有从软件源中安装软件包的需求，且为有 OpenWrt 使用经验，可自行解决各种问题的进阶用户，可以考虑使用此版，
- Project 基于 [Project-OpenWrt 源码](https://github.com/project-openwrt/openwrt/tree/18.06-kernel5.4) 18.06-kernel5.4 分支编译的固件，(Luci 采用 Lean 版 Luci 18.06 )，目前 Project 版仅支持竞斗云。

---

## 文件格式区别

　　固件文件名中带有 ext4 字样的文件为搭载 ext4 文件系统固件，ext4 格式的固件更适合熟悉 Linux 系统的用户使用，在 Linux 下可以比较方便地调整 ext4 分区的大小。
固件文件名中带有 squashfs 字样的文件为搭载 squashfs 文件系统固件，而 squashfs 格式的固件适用于 “不折腾” 的用户，其优点是可以比较方便地进行系统还原，哪怕你一不小心玩坏固件，只要还能进入控制面板或 SSH，就可以很方便地进行 “系统还原操作”。
固件文件名中带有 factory 字样的文件为全新安装 OpenWrt 所用的固件，推荐在全新安装 OpenWrt 时解压 gz 文件刷入 SD 卡或硬盘。
固件文件名中带有 sysupgrade 字样的文件为升级 OpenWrt 所用的固件，无需解压 gz 文件，可直接在 Luci 面板中升级。

---

## openwrt 部署
