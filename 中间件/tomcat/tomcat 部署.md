

Tomcat 是由 Apache 开发的一个 Servlet 容器，实现了对Servlet 和 JSP 的支持，并提供了作为Web服务器的一些特有功能，如Tomcat管理和控制平台、安全域管理。Tomcat开源框架 属于Java语言编写web服务器

tomcat 和jdk关系（区别）

- jdk是JAVA的编译器,写java代码时需要使用jdk进行编译运行
- tomcat是一种WEB服务器.是jsp和servlet的运行时的WEB容器
- apache是一种最流行的HTTP服务器

## tomcat 部署

1. [[../JDK/JDK 部署|JDK 部署]]
2. tomcat 下载地址：[https://tomcat.apache.org/](https://tomcat.apache.org/)
3. tomcat archive：[https://archive.apache.org/dist/tomcat/](https://archive.apache.org/dist/tomcat/)

```bash
# 进入下载目录，进行解压缩：
wget https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.12/bin/apache-tomcat-7.0.12.zip
tar zxvf  apache-tomcat-7.0.12.tar.gz

chmod u+x apache-tomcat-7.0.12/bin/*.sh
# 启动
apache-tomcat-7.0.12/bin/startup.sh

```

### 1.tomcat日志切割

- **下载cronolog**
  [https://developer.aliyun.com/packageSearch?word=cronolog](https://developer.aliyun.com/packageSearch?word=cronolog)

```bash
yum install cronolog
#或者使用下载压缩包安装
# 1. 下载(最新版本)
wget http://cronolog.org/download/cronolog-1.6.2.tar.gz
tar zxvf cronolog-1.6.2.tar.gz
# 3. 进入安装目录
cd cronolog-1.6.2
# 4. 运行安装
./configure
make &7 make install
# 5. 查看是否安装成功
which cronolog
```

- **修改catalina.sh**

  `vim ~/bin/catalina.sh`

  ```bash
  # 大概500/509行
  if [ "$1" = "-security" ] ; then
      if [ $have_tty -eq 1 ]; then
        echo "Using Security Manager"
      fi
      shift
      eval $_NOHUP "\"$_RUNJAVA\"" "\"$CATALINA_LOGGING_CONFIG\"" $LOGGING_MANAGER "$JAVA_OPTS" "$CATALINA_OPTS" \
        -D$ENDORSED_PROP="\"$JAVA_ENDORSED_DIRS\"" \
        -classpath "\"$CLASSPATH\"" \
        -Djava.security.manager \
        -Djava.security.policy=="\"$CATALINA_BASE/conf/catalina.policy\"" \
        -Dcatalina.base="\"$CATALINA_BASE\"" \
        -Dcatalina.home="\"$CATALINA_HOME\"" \
        -Djava.io.tmpdir="\"$CATALINA_TMPDIR\"" \
        org.apache.catalina.startup.Bootstrap "$@" start 2>&1 \
        | /usr/sbin/cronolog "$CATALINA_BASE"/logs/catalina.%Y-%m-%d.out >> /dev/null &
    else
      eval $_NOHUP "\"$_RUNJAVA\"" "\"$CATALINA_LOGGING_CONFIG\"" $LOGGING_MANAGER "$JAVA_OPTS" "$CATALINA_OPTS" \
        -D$ENDORSED_PROP="\"$JAVA_ENDORSED_DIRS\"" \
        -classpath "\"$CLASSPATH\"" \
        -Dcatalina.base="\"$CATALINA_BASE\"" \
        -Dcatalina.home="\"$CATALINA_HOME\"" \
        -Djava.io.tmpdir="\"$CATALINA_TMPDIR\"" \
        org.apache.catalina.startup.Bootstrap "$@" start 2>&1 \
        | /usr/sbin/cronolog "$CATALINA_BASE"/logs/catalina.%Y-%m-%d.out >> /dev/null &
    fi
  ```

### 2.umask

对于文件和目录来说， 最大的权限其实都是777，但是执行权限对于文件来说，很可怕，而对目录来说执行权限是个基本权限。所以默认目录的最大权限是777，而文件的默认最大权限就是666。

对于root用户的umask=022这个来说，777权限二进制码就是（111）（111）（111），022权限二进制码为（000）（010）（010）。

- 所有权限二进制的1:代表有这个权限
- umask二进制1：**代表要去掉这个权限**，不管你原来有没有权限，你最终一定没有这个权限。
- umask二进制的0：代表我不关心对应位的权限，你原来有权限就有权限，没有就没有， 我不影响你。

tomcat 设置umask

`vim ~/bin/catalina.sh`

```bash
if [ -z "$UMASK" ]; then 
    UMASK="0022" 
fi 
umask $UMASK 
```

### 3.不修改端口，部署多个项目

能否在同一个tomcat的webapps目录下运行多个不同项目呢？答案是可以的。

**1、将多个项目包放入webapps文件夹下**

```bash
#当我们在浏览器中输入 
http://192.168.8.15:8080/   
#默认访问webapps下的ROOT项目

http://192.168.8.15:8080/bank  
#默认访问webapps下的bank项目中的index.jsp&index.html页面
#接下来我们可以通过nginx反向代理来访问不同的项目
```

### 4.logs 日志文件说明

***catalina.out***

catalina.out即标准输出和标准出错，所有输出到这两个位置的都会进入catalina.out，这里包含tomcat运行自己输出的日志以及应用里向console输出的日志。

***catalina.日期.log***

catalina.{yyyy-MM-dd}.log是tomcat自己运行的一些日志，这些日志还会输出到catalina.out，但是应用向console输出的日志不会输出到catalina.{yyyy-MM-dd}.log。

***host-manager.日期.log***

这个估计是放tomcat的自带的manager项目的日志信息的，也没有看到有什么重要的日志信息

***localhost.日期.log***

localhost.{yyyy-MM-dd}.log主要是应用初始化(listener, filter, servlet)未处理的异常最后被tomcat捕获而输出的日志，而这些未处理异常最终会导致应用无法启动。

***localhost***​***access***​***log.日期.txt***

这个是存放访问tomcat的请求的所有地址以及请求的路径、时间，请求协议以及返回码等信息(重要)
