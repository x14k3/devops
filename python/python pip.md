# python pip

# pip

我们都知道python有海量的第三方库或者说模块，这些库针对不同的应用，发挥不同的作用。我们在实际的项目中，或多或少的都要使用到第三方库，那么如何将他人的库加入到自己的项目中内呢？
pip 是 Python 包管理工具，该工具提供了对Python 包的查找、下载、安装、卸载的功能。
目前如果你在 [python.org](https://www.python.org/) 下载最新版本的安装包，则是已经自带了该工具。

## pip 安装

```bash
# 在linux下使用包管理工具安装pip： 例如，ubuntu下：
apt-get install python-pip
# Fedora系下：Redhat、centos
yum install python-pip
```

## pip 使用

```bash
Usage:   
  pip <command> [options]

Commands:
  install                 # 安装模块
  download          # 下载模块
  uninstall            # 卸载模块
  list                     # 列出已安装的模块
  show                  # 显示有关已安装软件包的信息。
  check                 # 验证已安装的包是否具有兼容的依赖项。
  config                # 管理本地和全局配置。
  search                # Search PyPI for packages.
  cache                 #  Inspect and manage pip's wheel cache.
  wheel                 # 根据您的要求制造轮子
  hash                        Compute hashes of package archives.
  completion                  A helper command used for command completion.
  debug                       Show information useful for debugging.
  help                        Show help for commands.

General Options:
  -h, --help                  Show help.
  --isolated                  Run pip in an isolated mode, ignoring
		                           environment variables and user configuration.
  -v, --verbose             Give more output. Option is additive, and can be
                                 used up to 3 times.
  -V, --version               Show version and exit.
  -q, --quiet                 Give less output. Option is additive, and can be
                              used up to 3 times (corresponding to WARNING,
                              ERROR, and CRITICAL logging levels).
  --log <path>                Path to a verbose appending log.
  --no-input                  Disable prompting for input.
  --proxy <proxy>             Specify a proxy in the form
                              [user:passwd@]proxy.server:port.
  --retries <retries>         Maximum number of retries each connection should
                              attempt (default 5 times).
  --timeout <sec>             Set the socket timeout (default 15 seconds).
  --exists-action <action>    Default action when a path already exists:
                              (s)witch, (i)gnore, (w)ipe, (b)ackup, (a)bort.
  --trusted-host <hostname>   Mark this host or host:port pair as trusted,
                              even though it does not have valid or any HTTPS.
  --cert <path>               Path to alternate CA bundle.
  --client-cert <path>        Path to SSL client certificate, a single file
                              containing the private key and the certificate
                              in PEM format.
  --cache-dir <dir>           Store the cache data in <dir>.
  --no-cache-dir              Disable the cache.
  --disable-pip-version-check
                              Don't periodically check PyPI to determine
                              whether a new version of pip is available for
                              download. Implied with --no-index.
  --no-color                  Suppress colored output.
  --no-python-version-warning
                              Silence deprecation warnings for upcoming
                              unsupported Pythons.
  --use-feature <feature>     Enable new functionality, that may be backward
                              incompatible.
  --use-deprecated <feature>  Enable deprecated functionality, that will be
                              removed in the future.
```

## 配置国内源

```bash
# 1. 每次手动指定
pip install -i https://pypi.doubanio.com/simple 模块名

# 2.修改配置
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

```

# wheel

Python .whl文件(或wheels)是Python中很少讨论的一部分，但是它们对Python包的安装过程非常重要。如果您已经使用pip安装了Python包，那么很有可能是轮子(wheels)使安装速度更快、效率更高了。

轮子是Python生态系统的一个组件，它有助于使包的安装工作正常进行。它们允许更快的安装和更稳定的包分发过程。在本教程中，您将深入了解轮子是什么，它们提供了什么好处，以及它们是如何获得吸引力并使使用Python变得更方便的。

*初探pip安装过程*
我们先来看两个pip安装包的过程。

```bash
root@doshell opt $ pip install numpy
Looking in indexes: http://mirrors.cloud.aliyuncs.com/pypi/simple/
Collecting numpy
  Downloading http://mirrors.cloud.aliyuncs.com/pypi/packages/4c/b9/038abd6fbd67b05b03cb1af590cfc02b7f1e5a37af7ac6a868f5093c29f5/numpy-1.23.5-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (17.1 MB)
     |████████████████████████████████| 17.1 MB 22.1 MB/s 
Installing collected packages: numpy
Successfully installed numpy-1.23.5

root@doshell opt $ pip install uwsgi
Looking in indexes: http://mirrors.cloud.aliyuncs.com/pypi/simple/
Collecting uwsgi
  Downloading http://mirrors.cloud.aliyuncs.com/pypi/packages/b3/8e/b4fb9f793745afd6afcc0d2443d5626132e5d3540de98f28a8b8f5c753f9/uwsgi-2.0.21.tar.gz (808 kB)
     |████████████████████████████████| 808 kB 76.9 MB/s 
Building wheels for collected packages: uwsgi
  Building wheel for uwsgi (setup.py) ... done
  Created wheel for uwsgi: filename=uWSGI-2.0.21-cp39-cp39-linux_x86_64.whl size=551008 sha256=13f4f313fd1aa6ca36634fb8d73d7d107e45c75c13b62eee93c439d2bc25811b
  Stored in directory: /root/.cache/pip/wheels/31/77/7d/5a3f1624ded15696920cfa79c33e76dac4ec0fb4a65463333c
Successfully built uwsgi
Installing collected packages: uwsgi
Successfully installed uwsgi-2.0.21
root@doshell opt $ 
```

细看会发现：

1. **NumPy**下载的是以**whl**格式结尾的东西，而**uWSGI**则是下了**tar.gz**的压缩包；
2. **uWSGI**多了一些build的过程，在build结束之后才开始install。

了解了这些区别之后，我们再来铺垫一点发行版的内容。

## 包的发行版

*1. 什么是源发行版？（Source Distribution/sdist）*
源发行版，顾名思义就是“发行的是源码”，包含了元数据和源码文件(Python, C++等)，必须要经过编译才能使用起来。编译的过程是在用户的机子上进行的。通常用python setup.py sdist来产生源发行版。

*2. 什么是已编译的发行版？（Built Distribution）*
同样地，如果源码被编译好了，那就成了一个已编译的发行版了。我们要谈到的wheel就是已编译发行版的一种格式。有的地方提到二进制发行版（binary distribution）也基本默认是wheel包。（下文如果提到wheel或二进制发行版就默认是已编译发行版了）

所以，结合上面的例子，我们大概可以猜出来NumPy和uWSGI安装上的区别了：
NumPy下载的是已编译的发行版，而uWSGI下载的是源发行版，在本地编译完了之后才执行安装。

*3. 所以为什么有的包直接提供了wheel，有些包要提供源码呢？*
whl的好处：不用怎么担心依赖关系。
提供whl或是源发行包则取决于对项目复杂性、相互依赖关系以及其他因素的综合考量。如果要提供whl包，那就要针对不同的平台都要准备，对兼容性要有比较全面的考虑。

## .whl 包到底是什么

wheel包本质上是一个zip文件。是已编译发行版的一种格式。一个wheel包的文件名由以下这些部分组成
举个例子：
`tensorflow-2.3.1-cp36-cp36m-macosx_10_9_x86_64.whl`

- tensorflow是包名（dist）。
- 2.3.1是包的版本号（version）。
- cp36是对python解释器和版本的要求（python）。cp指的是CPython解释器，35指的是版本3.5的Python。
- cp36m是ABI的标签（python）。ABI即应用二进制接口（Application Binary Interface）。一般不用关心。
- macosx_10_9_x86_64是平台标签（platform），告诉我们这个包是为macOS操作系统的，使用10.9的macOS developer SDK编译，适用于x86-64指令集。

## wheel包的好处

1. 安装快；
2. 一般比源发行版体积小很多。比方说matplotlib，它的wheel包最大只有11.6MB，而源码却有37.9MB。网络传输的压力显然是wheel小；
3. 免除了_setup.py_的执行。setup.py是Python的disutils、setuptools编译机制所需要的文件，需要执行大量的编译、安装工作，如果没有wheel的存在，包的安装、维护都会很麻烦；
4. 不需要编译器。pip在下载时帮你确定了版本、平台等信息；
5. 使用wheel的话，pip自动为你生成.pyc文件，方便Python解释器的读取。
