# Apache服务之配置文件

## 1. Apache 目录结构

> ​`Apache`​的配置指令分为两大类
>
> * **核心指令**：由核心模块提供的指令，必须包含在`httpd.conf`​文件中，否则`Apache`​无法工作
> * **扩展指令**：由标准模块和第三方模块提供的指令，用于扩展`Apache`​服务特性

---

### 1.1 二进制安装的目录结构

```bash
# CentOS6系统自带的Apache服务
/etc/httpd
├── conf
│   ├── httpd.conf
│   └── magic
├── conf.d
│   ├── info.conf
│   ├── mod_dnssd.conf
│   ├── README
│   └── welcome.conf    # 默认的欢迎页面
├── logs -> ../../var/log/httpd  # 日志存放路径
├── modules -> ../../usr/lib64/httpd/modules  # 模块加载地址
└── run -> ../../var/run/httpd  # 运行路径
```

　　‍

```bash
# CentOS7通过yum安装的Apache服务
/etc/httpd
|-- conf
|   |-- httpd.conf
|   |-- httpd.conf.bak
|   `-- magic
|-- conf.d
|   |-- autoindex.conf
|   |-- README
|   |-- userdir.conf
|   `-- welcome.conf
|-- conf.modules.d
|   |-- 00-base.conf
|   |-- 00-dav.conf
|   |-- 00-lua.conf
|   |-- 00-mpm.conf
|   |-- 00-proxy.conf
|   |-- 00-systemd.conf
|   `-- 01-cgi.conf
|-- logs -> ../../var/log/httpd
|-- modules -> ../../usr/lib64/httpd/modules
`-- run -> /run/httpd
```

---

### 1.2 编译安装的目录结构

* ​`httpd.conf`​

  * 主配置文件
* ​`mime.types`​

  * 用于定义`MIME`​类型，通过这些定义使`Apache`​能通过文件扩展名来控制将那些类型的`MIME`​发送给浏览器
* ​`magic`​

  * ​`mod_mine_magic`​模块的配置文件
  * 当`mod_mine_magic`​无法分辨出正确文件类型时，才由这个文件所定义的类型来提供服务
* ​`extra`​

  * 存放`Apache`​所需要引用的配置
  * 在`httpd.conf`​文件中通过`Include`​指令启动或者停用对于功能
* ​`original`​

  * 对于配置文件的原始状态的备份

```bash
/etc/httpd24
├── extra
│   ├── httpd-autoindex.conf
│   ├── httpd-dav.conf
│   ├── httpd-default.conf
│   ├── httpd-info.conf
│   ├── httpd-languages.conf
│   ├── httpd-manual.conf
│   ├── httpd-mpm.conf
│   ├── httpd-multilang-errordoc.conf
│   ├── httpd-ssl.conf
│   ├── httpd-userdir.conf
│   ├── httpd-vhosts.conf
│   └── proxy-html.conf
├── httpd.conf
├── magic
├── mime.types
└── original
    ├── extra
    │   ├── httpd-autoindex.conf   # 自动索引配置
    │   ├── httpd-dav.conf         # WebDAV配置
    │   ├── httpd-default.conf     # Apache的默认配置
    │   ├── httpd-info.conf        # mod_status和mod_info模块配置
    │   ├── httpd-languages.conf   # 多语言配置支持
    │   ├── httpd-manual.conf      # 在网站上提供Apache手册
    │   ├── httpd-mpm.conf         # 多路处理模型配置
    │   ├── httpd-multilang-errordoc.conf   # 实现多语言的错误信息配置
    │   ├── httpd-ssl.conf         # SSL配置
    │   ├── httpd-userdir.conf     # 用户目录配置
    │   ├── httpd-vhosts.conf      # 虚拟主机配置
    │   └── proxy-html.conf        # 代理配置
    └── httpd.conf
```

---

## 2. `httpd.conf`​文件

> ​`httpd.conf`​文件大致分为三大部分

* **主服务器部分**：核心模块提供的指令定义服务器功能和参数
* **容器环境部分**：以`<容器名>`​开头且`<容器名/>`​结尾样式的指令封装
* **服务器扩展部分**：通过`Include`​指令来加载其他的参数，如虚拟主机的配置

```apache
# 主服务器部分
ServerRoot "/usr/local/apache"
Listen 12.34.56.78:80
LoadModule cache_module modules/mod_cache.so


# 容器环境部分



# 服务器扩展部分
Include /etc/httpd24/extra/httpd-ssl.conf
Include /etc/httpd24/extra/httpd-info.conf
```

---

### 2.1 主服务器部分

#### 2.1.1 `ServerName`​指令

* 功能介绍

  * 用于定义`Apache`​默认主机名
  * 这个指定在`httpd.conf`​配置文件中默认被注释掉了，需要启用的话，将`#`​删除即可
  * 可以使**站点名称地址**或者\*\*`IP`​地址\*\*，推荐使用完整的`IP`​地址
* 注意事项

  * 如果没有使用这个指令来指定默认的主机名，在启动`Apache`​时会提示错误信息
  * 报错信息提示没有找到域名，因此只能是用`127.0.0.1`​的地址作为服务器的默认地址，只有本机能访问
  * 如果使用**站点名称地址**，那么`Apache`​会根据`host.conf`​文件来选择是先从本机名称列表`/etc/hosts`​中查找与站点名称对应的`IP`​地址还是向`DNS`​查询站点名称相对应的`IP`​地址

```apache
# 站点名称地址
ServerName www.escape.com

# IP地址
ServerName 12.34.56.78
```

　　‍

```bash
# host.conf文件说明
[root@MiWiFi-R3-srv ~]# cat /etc/host.conf
multi on

# 1. order是解析顺序的参数
# order hosts,bind,nis  说明先查询解析/etc/hosts文件，然后DNS，再是NIS

# 2. multi on
# 表示是否运行/etc/hosts文件允许主机指定多个多个地址 ，on表示运行

# 3. nospoof on
# 是否允许服务器对ip地址进行其欺骗，这里的on表示不允许

# 4. rccorder
# 如果被设置为on，那么所有查询将被重新排序
```

---

#### 2.1.2 `ServerRoot`​指令

* 功能介绍

  * ​`ServerRoot`​指令用于定义服务器所在的目录
  * 这个路径通常是在编译过程中由`-prefix=ServerRoot路径`​选项来指定的，二进制安装一般在`/etc/httpd`​目录
  * ​`Apache`​的根目录包含`bin`​、`conf`​、`htdocs`​等目录文件夹
* 注意事项

  * 在启动`Apahce`​服务时可以使用`-d`​参数来指定一个`ServerRoot`​的位置
  * 一般是为了测试同一个版本的`Apache`​在多个环境下的配置，生产环境中很少使用

```apache
# 编译安装
ServerRoot /usr/local/apache
```

---

#### 2.1.3 `DocumentRoot`​指令

* 功能介绍

  * ​`DocumentRoot`​指令用于指定`Apache`​所提供的页面服务的根路径，就是通过`URL`​请求的根目录
* 注意事项

  * 此路径不能使用相对路径
  * 如果路径中间有空格，需要使用引号括起来

```apache
DocumentRoot "/var/www/html"
```

---

#### 2.1.4 `ServerAdmin`​指令

* ​`ServerAdmin`​指令用于定义当服务器出现错误后提示给管理员邮件地址

```apache
ServerAdmin escape@escape.com
```

---

#### 2.1.5 `Alias`​与`ServerAlias`​指令

* ​`Alias`​指令

  * 用于实现目录映射功能，识别为`CGI`​脚本目录
* ​`ServerAlias`​指令

  * 用于实现目录映射功能，识别为普通目录而非`CGI`​脚本

```apache
# Alias指令
Alias /var/www/html /home/www/html

# ServerAlias指令
ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
```

---

#### 2.1.6 `User`​与`Group`​指令

* ​`User`​与`Group`​指令用于定义运行`Apache`​服务器的账号和工作组
* 用于定义用户请求时创建的子进程的账号和工作组，以及一些权力范围

```apache
# 编译安装
User deamon
Group deamon

# 二进制安装
User apache
Group apche
```

　　‍

```bash
[root@MiWiFi-R3-srv ~]# ps -aux | grep httpd
root      22661  0.0  1.2 312464 12072 ?        Ss   04:42   0:04 /usr/sbin/httpd -DFOREGROUND
apache    22662  0.0  0.7 314680  7404 ?        S    04:42   0:00 /usr/sbin/httpd -DFOREGROUND
apache    22663  0.0  0.7 314680  7172 ?        S    04:42   0:00 /usr/sbin/httpd -DFOREGROUND
apache    22664  0.0  0.6 314680  6660 ?        S    04:42   0:00 /usr/sbin/httpd -DFOREGROUND
......
```

---

#### 2.1.7 `Listen`​指令

* ​`Listen`​指令用来定义`Apache`​的监听端口号，默认为`80`​端口
* 如果使用了出`80`​外的其他端口，浏览器访问时需要加上端口号，否则无法访问

```apache
# 监听在特定IP地址特定端口上
Listen 12.34.56.78:80

# 监听在所有IP地址的特点端口上
Listen 80
Listen *:80
```

---

#### 2.1.8 `LoadModule`​指令

* ​`LoadModule`​指令用于加载模块或者目标文件

```apache
# 加载模块
LoadModule authn_file_module modules/mod_authn_file.so

# 加载扩展配置文件
Include conf.modules.d/*.conf
```

---

#### 2.1.9 `ErrorDocument`​指令

* ​`ErrorDocument`​指令根据响应码自定义服务器出错时所提供的错误信息页面
* 有三种方法：定义文本信息、实用脚本、制定一个页面

```apache
# 定义文本信息
ErrorDocument 500 "The server made a boo boo."

# 实用脚本
ErrorDocument 404 "/cgi-bin/missing_handler.pl"

# 制定一个页面
ErrorDocument 404 /missing.html
ErrorDocument 402 http://www.example.com/subscription_info.html
```

---

#### 2.1.10 `Options`​指令

　　**指令介绍**

* ​`Options`​指令决定在那些目录中使用哪些服务器的特性

　　**指令参数**

* ​**​`None`​**​

  * 表示`Options`​指令不生效
* ​**​`ExecCGI`​**​

  * 允许在当前目录下执行`CGI`​脚本
* ​**​`Includes`​**​

  * 允许使用`SSI`​功能，即开启服务器方包含功能
* ​**​`IncludesNOEXEC`​**​

  * 允许使用`SSI`​功能，但`#exec cmd`​和`#exec cgi`​功能进制使用
* ​**​`Indexes`​**​

  * 开启索引功能
  * 一个请求目录的`URL`​中没有设定`DirectoryIndex`​指令指定索引文件，那么服务器会自动返回一个请求目录内容的目录列表，即列出当前目录下所有的文件和目录列表，做下载站可以使用
* ​**​`FollowSymLinks`​**​

  * 允许在当前目录中使用符号链接，如目录下有链接文件，会显示出链接文件实际的文件内容
  * 如果参数在`<Location>`​容器中则会忽略，而且不会改变用于匹配的`<Directory>`​容器的路径
* ​**​`SymLinksIfOwnerMatch`​**​

  * 与`FollowSymLinks`​类似，但只有当服务器仅在符号链接与其目录或文件拥有相同的`UID`​时才使用
  * 如果参数在`<Location>`​容器中则会忽略
* ​**​`All`​**​

  * 使用除`MultiViews`​外的所以特性，是`Options`​指令的默认参数
* ​**​`MultiViews`​**​

  * 用于启用`mod_negotiaions`​模块提供的多重视图功能参数，需要配合`DefaultLanguage`​指令使用

```apache

    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted



    Options Indexes FollowSymLinks
    AllowOverride +MultiViews -FollowSymLinks
    Require all granted

```

---

### 2.2 容器环境部分

#### 2.2.1 `ifModule`​容器

* ​`<ifModule>`​容器作用于模块
* 首先判断模式是否被加载，然后在决定是否进行处理，如果为真则执行，否则不执行
* 容器可以相互嵌套使用，不受影响

```apache
# 如果mpm_prefork_module被载入，则加载CGI中的mod_cgi模块

    LoadModule cgi_module modules/mod_cgi.so



# 如果mpm_prefork_module没有被载入，则加载CGI中的mod_cgid模块

    LoadModule cgid_module modules/mod_cgid.so

```

---

#### 2.2.2 `ifDefine`​容器

* ​`<ifDefine>`​容器与`<ifModule>`​容器类似，都是用于进行条件判断
* ​`<ifDefine>`​容器需要条件为真才执行，而且需要在`httpd`​启动时指定特定的参数才能起作用

```apache
# 容器配置

    LoadModule proxy_module modules/libproxy.so


# 启动命令指定才起作用
$ httpd -D Proxy
```

---

#### 2.2.3`Directory`​与`DirectoryMatch`​容器

* ​`<Directory>`​容器

  * 用于让它所封装的指令在指定的目录和子目录中起作用，目录必须是完整路径
  * 目录路径中可以使用通配符，`*`​、`?`​、`[]`​等
  * 使用通配符需要在目录路径前加上`~`​标识
* ​`<DirectoryMatch>`​容器

  * 与`<Directory>`​容器类似，可以直接接受正则表达式，无需添加`~`​标识

```apache
# 正常目录路径

    AllowOverride None
    Require all granted


# 加入正则表达式，匹配apache00-apche99目录下的html目录

    AllowOverride None
    Require all granted



    AllowOverride None
    Require all granted

```

---

#### 2.2.4`Files`​与`FilesMatch`​容器

* ​`<Files>`​容器

  * ​`<Directory>`​容器用于目录，`<Files>`​容器用于文件
  * 目录路径中可以使用通配符，`*`​、`?`​、`[]`​等
  * 使用通配符需要在目录路径前加上`~`​标识
* ​`<FilesMatch>`​容器

  * 与`<Files>`​容器类似，可以直接接受正则表达式，无需添加`~`​标识

```apache
# 容器

    AllowOverride None
    Require all granted


# 容器

    AllowOverride None
    Require all granted


```

---

#### 2.2.5`Location`​与`LocationMatch`​容器

* ​`<Location>`​与`<LocationMatch>`​容器用于对`URL`​进行访问控制
* ​`<Location>`​容器还可以将`URL`​请求映射到`Apache`​模块处理器上，如`mod_status`​模块

```apache
# 将限制所以以/cgi开头的URL拒绝访问

    Order deny,allow
    Deny from all


# 限制mod_status模块

    SetHandler server-status
    Order deny,allow
    Deny from all
    Allow from all
    Allow from .example.com

```

---

#### 2.2.5 `Limit`​与`LimitExcept`​容器

* 用于对用户请求进行一些限制

```apache
# 对http协议进行限制

    Require valid-user




    Require valid-user

```

---

### 2.3 服务器扩展部分

#### 2.3.1 自带扩展模块

* 编译和`httpd2.4`​之后的程序都是用这种分割式配置文件的形式，方便修改和使用
* 如果有需要可以自定义指定需要配置的内容，在`httpd.conf`​文件中进行引入，即可使用

|序号|配置文件名称|用途|
| ------| --------------| --------------------------|
|1|​`httpd-autoindex.conf`​|自动索引配置|
|2|​`httpd-dav.conf`​|​`WebDAV`​配置|
|3|​`httpd-default.conf`​|​`Apache`​的默认配置|
|4|​`httpd-info.conf`​|​`mod_status`​和`mod_info`​模块配置|
|5|​`httpd-languages.conf`​|多语言配置支持|
|6|​`httpd-manual.conf`​|在网站上提供`Apache`​手册|
|7|​`httpd-multilang-errordoc.conf`​|实现多语言的错误信息配置|
|8|​`httpd-ssl.conf`​|​`SSL`​配置|
|9|​`httpd-userdir.conf`​|用户目录配置|
|10|​`httpd-vhosts.conf`​|虚拟主机配置|
|11|​`proxy-html.conf`​|代理配置|

---

#### 2.3.2 引入扩展模块

```apache
# 二进制安装
Include conf.d/*.conf
Include conf.modules.d/*.conf

# 编译安装
Include /etc/httpd24/extra/httpd-mpm.conf
Include /etc/httpd24/extra/httpd-multilang-errordoc.conf
Include /etc/httpd24/extra/httpd-autoindex.conf
```

---

## 3. `.htaccess`​文件

> 在`Apache`​中，通常都是使用`httpd.conf`​文件对服务器进行配置，但是对于一些管理员来说，可以使用`.htaccess`​文件对目录进行更简单、更精细的配置。

　　**好处**

* 随时对目录功能和权限进行控制
* 输入`.htaccess`​文件的配置无需重启`Apache`​服务就能生效

　　**坏处**

* 会导致服务器性能急剧下降
* 安全问题，导致服务器难以配置

　　**总结**

* 所以在`Apache`​中不建议使用`.htaccess`​文件，如果非要是用的话，应在`httpd.conf`​的`<Directory>`​容器中使用`AllowOverride`​指令来开启，这样能够有效的降低服务器的性能损失。

　　**注意事项**

* 使用`.htaccess`​文件需要先开启`AllowOverride`​功能，默认是关闭的
* 只需要在指定的目录下，创建一个`.htaccess`​文件就可以使用`.htaccess`​功能了

---

### 3.1 `AllowOverride`​指令

> 使用`AllowOverride`​指令就是配置，让`.htaccess`​文件支持哪些指令

　　**参数选项**

* ​**​`None`​**​

  * 进制使用`.htaccess`​文件功能
* ​**​`All`​**​

  * 使用所有能在`.htaccess`​文件中使用的指令
* ​**​`AuthConfig`​**​

  * 使用鉴权指令，如`AuthName`​、`AuthType`​等
* ​**​`FileInfo`​**​

  * 使用控制文件类型的指令，如`ErrorDocument`​、`SetOutputFilter`​等
* ​**​`Indexes`​**​

  * 使用目录索引指令
* ​**​`Options`​**​

  * 使用控制目录功能指令
* ​**​`Limit`​**​

  * 使用主机访问控制指令

```apache
# 启动.htaccess文件功能，并让.htaccess文件支持目录所以指令
AllowOverride Indexes

# /var/www/escape目录下.htaccess文件的内容，让其支持CGI
Options ExecCGI
AddHandler cig-script cgi pl
```

---

### 3.2 映射用户到目录

> 实现在一台服务器上为多个用户提供他们自己的`Web`​站点

* 实现步骤

```apache
# 【第一步】httpd.conf中加载mod_userdir模块
LoadModule mod_userdir modules/mod_userdir.so
```

```apache
# 【第二步】启用编译安装的httpd-userdir.conf文件
# 默认模板的作用就是将用户的请求映射到用户的public_html目录
# 在这个目录中启用.htaccess文件支持，并对所有链接进行访问控制，只允许GET、POST、OPTIONS方法进行访问
[root@MiWiFi-R3-srv extra]# cat httpd-userdir.conf
UserDir public_html

```

```apache
# 【第三步】赋权限、重启
$ chmod 755 -R /home/escape
$ echo "text" > /home/escape/public_html/index.html
$ ./apachectl restart
```

```apache
# 【第四步】访问用户站点
http://192.168.31.94/~escape
```

* 关于`UserDir`​的更多配置详见[用户私人网站目录](http://httpd.apache.org/docs/2.4/howto/public_html.html)

---

### 3.3 目录的索引

> 为网站自动添加索引功能，实现网站`http://www.escape.com`​自动匹配`http://www.escape.com/index.html`​

　　**所需模块**

* 需要使用`mod_dir`​和`mod_autoindex`​模块实现服务器的索引支持

　　**提供两种索引方式**

* 由`mod_dir`​模块提供

  * 一是由用户编写一个索引文件，通常为`index.html`​或`index.php`​文件
* 由`mod_autoindex`​模块提供

  * 二是在`mod_dir`​模块指定的索引没有找到时，由`Apache`​服务器生成一个目录列表，完成目录的索引，如下载站

```apache
# mod_dir模块提供DirectoryIndex指令指定
DirectoryIndex index.html index.php

# 也可以使用绝对路径来指定
DirectoryIndex /cig-bin/index.cgi

# mod_autoindex模块
Include conf/extra/httpd-autoindex.conf
# httpd-autoindex.conf有大量配置可供选择
```

---

## 4. 使用`GUI`​进行服务配置

> 介绍几种`GUI`​界面的配置工具，其底层还是通过修改配置文件进行完成的。

### 4.1 `Webmin`​

　　**介绍**

* 最强大的基于`Web`​页面的`Linux`​系统管理工具

　　**安装**

```bash
# 下载、解压
$ wget https://sourceforge.net/projects/webadmin/files/webmin/1.860/webmin-1.860.tar.gz/download?use_mirror=nchc
$ tar -xf webmin-1.860 -C /usr/share/
$ cd /usr/share/webmin-1.860

# 安装，如下图配置
$ ./setup.sh

# 启动
http://192.168.31.94:10000
```

---

### 4.2 `Zecos ApacheConf`​

　　**介绍**

* 最强大的基于`Web`​页面的`Windos`​系统管理工具

　　**安装**

* 官网下载安装  `http://www.apache-gui.com`​

---

### 4.3 `redhat-config-httpd`​

　　**介绍**

* 红帽的`Apache`​配置程序

　　**安装**

* ​`yum install redhat-config-httpd`​
