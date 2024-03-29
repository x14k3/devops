# 0day

* 📄 [CVE-2011-1473 TLS Client-initiated 重协商攻击](siyuan://blocks/20240205134209-xhlnp1v)

## **01 什么是0day漏洞？**

**一个漏洞从发现到解决有三个时间点**：

* 漏洞被发现（T~0~）
* 漏洞信息公布（T~1~）
* 漏洞被修补（T~2~）

——T~0~————T~1~————T~2~————

漏洞的0/1/N day类型，就是利用漏洞进行攻击的时间（T~exp~），对应上边时间轴中漏洞的状态而决定的。

当T~exp~1，此时漏洞即0day漏洞，又称“零日漏洞”（zero-day），是已经被发现，还未被公开，官方还没有相关补丁的漏洞，攻击者此时攻击如入无人之境，攻击效果最佳。

当T~1~exp2，此时漏洞即1day漏洞，漏洞信息已经被披露，某些勤快的系统管理员已经关注并使用了临时修补手段，但大部分受影响系统因官方补丁的缺失导致其脆弱性依然广泛存在，攻击者此时攻击有效性仍较高。

当T~exp~>T~2~，此时漏洞即Nday漏洞,由于官方补丁已出，此时攻击者利用该漏洞进行攻击，有效性已大幅降低，只能寄希望于捡漏了。

‍

## **02 0day漏洞是如何产生的？**

**只要有代码，就会有漏洞。** 0day漏洞本质上也是漏洞，漏洞产生的内因就是代码的缺陷，代码的缺陷率可以降低却不可以完全消除，因此，代码与漏洞注定相伴相生。公开数据显示，每1000行代码中就会有2-4个漏洞，操作系统、中间件、应用系统、软件以及应用软件开发过程中难免要引入的各类第三方开源组件、框架等，每年都会爆出很多0day漏洞，甚至某些安全产品自身也会遭受0day漏洞的攻击，因为安全产品自身功能也是由代码实现的。

**有市场就有需求。** 多年前，0day漏洞还只是“炫技小子”跟朋友炫耀的谈资，而在信息化如此发达的今天，互联网像是一座金矿，0day漏洞则更多的被用来实现攻击者的经济目的甚至政治目的。在数据为王的时代，数据的增值无形中也带动了0day漏洞赏金水涨船高，所谓重赏之下必有“勇”夫，0day漏洞的挖掘者越来越多，0day漏洞越来越多浮出水面也就不足为奇了。

‍

## **03 为什么防不住0day漏洞？**

**无法解决的0day漏洞防御滞后性问题。** 0day漏洞之所以称为0day，正是因为其补丁永远晚于0day漏洞攻击，这是面对0day漏洞攻击时防守方的天然劣势。很多情况下，攻击者利用0day漏洞攻击的成功率极高，往往可以达到目的并全身而退，而防守方却一无所知，只有在漏洞公布之后才根据线索找到一些漏洞攻击时留下的蛛丝马迹。

**看不见的才是最可怕的。** 2009年，伊朗纳坦兹核燃料浓缩工厂浓缩铀的产量每况愈下，终于，安全人员在一台装有控制软件的电脑上发现了带有震网病毒的U盘，该病毒最终导致1000台铀浓缩离心机废弃。据分析，震网设计者精心构置了微软操作系统中4个在野0day漏洞，并和工控系统的在野0day漏洞进行组合，以实现精准打击、定向破坏。面对0day漏洞，防守方无法知晓攻击者在什么时间，采用什么方式，针对哪些薄弱环节进行攻击，只能乱拳出击；而攻击者目的明确，有的放矢，往往采用“社工+常规攻击+0day漏洞”或多种0day漏洞的组合式攻击，致命的0day漏洞在攻击过程中只是作为突破或提权最关键环节的一把钥匙，令人防不胜防。

‍

## **04 面对0day漏洞，我们应该做什么？**

**一、持续提高安全意识**

信息安全，意识为先。据统计，单纯依靠0day漏洞攻击成功事件，数量远低于包括弱密码、不合规配置、安全意识不够等基础工作不到位引发的安全事件。因此，应对0day漏洞，内功修炼很重要，要做好安全合规，守好安全红线，做到不设置弱密码、不安装盗版软件、不使用陌生U盘、不点击陌生邮件，在此基础上谈论如何应对0day漏洞才有意义。

**二、建立SDL开发安全管理体系**

建立SDL开发安全管理体系是系统化应对0day漏洞、减少0day漏洞出现的有效方法，既治标也治本。SDL的核心理念就是将安全考虑集成在软件开发的需求分析、设计、编码、测试和维护等每一个阶段，以大幅降低漏洞产生概率。以微软为例，在全面推行SDL后，Windows  XP和Windows Vista的漏洞报告数量减少了45%，SQLServer2000、2005版本之间的漏洞报告数量减少了91%。

**三、摸清家底，及时修补**

摸清家底需要解决资产“有哪些”、“谁在用”的问题，将全部重要资产进行纳管，及时准确的获取相关资产的版本信息，下线风险较大的资产，收敛暴露面。同时，结合NVD、CNVD等漏洞库信息，以及业界专业安全公司提供的威胁情报，形成多渠道的情报来源，及时准确披露漏洞信息，对相关资产第一时间做好补丁升级，在0day漏洞攻击发生时能最快定位到受影响资产，最大程度地减少0day漏洞有效作用时间。

**四、构建纵深防御体系**

没有任何一款单独的安全产品，可以针对所有威胁向量提供保护。面对0day漏洞，传统的单点防护手段已无法胜任，我们需要不断拓展防护层次，并且在对抗中不断提升检测精度，并综合利用内部多种日志和流量信息，进行关联分析，让攻击者“进不来”、“拿不走”、“跑不掉”，不断增加攻击者0day漏洞的攻击成本。
