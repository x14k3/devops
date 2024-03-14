# linux 防火墙

* 📄 [firewalld](siyuan://blocks/20231110105237-htsujad)
* 📑 [iptables](siyuan://blocks/20231110105237-f3d4oum)

  * 📄 [iptables 示例](siyuan://blocks/20240314194239-attjy4f)

# 理解 firewalld/ufw 与iptables、netfilter 的关系

iptables 作为 Linux/Unix 下一款优秀的防火墙软件，在安全方面发挥着极其重要的作用，作为系统管理员来讲一点也不陌生。不过对于一些新手来说，复杂性是一个门槛，Linux厂商为了解决这个问题，于是推出了新的管理工具,如 Centos 下的 Firewalld 和 Ubuntu 下的ufw, 他们对新手十分友好，只需要几个很简单的命令即可实现想要的功能，再不也必为记不住iptables中的四表五键而烦恼了。  
那么，是不是有了 firewalld 和 ufw就不需要iptables了呢？并不是的。

首先我们要清楚firewalld、ufw 与iptables的关系，可以理解为两者只是对iptables其进行了一层封装，它们在用户交互方面做了非常多的改进，使其对用户更加友好，不需要再记住原来那么多命令了。

而目前对于一些系统管理员来讲，大概率还是会直接使用 iptables，主要原因是灵活性，当然也有一定的历史原因。对比前面两个管理工具，他们也存在一定的问题，如只能对单条规则进行管理，详细参考相关文档。

另外对于 firewalld 还有图形界面。

**除了这三个还有一个 netfilter 的东西，它又是什么呢？**

firewalld/ufw 自身并不具备防火墙的功能，而是和 iptables 一样需要通过内核的 netfilter 来实现，也就是说 firewalld 和 iptables 一样，他们的作用都是用于维护规则，而真正使用规则干活的是内核的netfilter。所以iptables服务和firewalld服务都不是真正的防火墙，只是用来定义防火墙规则功能的管理工具，通过iptables将定义好的规则交给内核中的netfilter(网络过滤器来读取)从而实现真正的防火墙功能。不过由于用户一般操作的都是iptables，所以称其为防火墙也并没有什么不妥的。

总结一下，Netfilter/Iptables 是Linux系统自带的防火墙，Iptables管理规则，Netfilter则是规则的执行者，它们一起实现Linux下安全防护。

以上就是他们四者的关系。

‍
