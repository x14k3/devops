# shell expect

‍

## [#](https://wiki.eryajf.net/pages/5279.html#_1%E3%80%81expect%E6%98%AF%E4%BB%80%E4%B9%88) 1、expect是什么

使用Linux的程序员对输入密码都不会陌生，在Linux下对用户有严格的权限限制，干很多事情越过了权限就得输入密码，比如使用超级用户执行命令，又比如scp、ssh连接远程主机等等。 比如我们要是 到10.20.24.103这台机器上去，就需要输入密码：

```bash
$ ssh 10.20.24.103
root@10.20.24.103's password: 
```

那么问题来了，如果我们脚本里面有scp的操作，总不可能执行一次scp就输入密码一次，这样就需要一个人盯着脚本运行了。 为了解决这个问题，我们需要一个自动输入密码的功能。

‍

## [#](https://wiki.eryajf.net/pages/5279.html#_2%E3%80%81expect%E7%9A%84%E5%8E%9F%E7%90%86) 2、expect的原理

针对这种scp或者ssh命令的功能，可能很多人想到的就是勉密钥登录。这种其实可以但是这种在生产环境不建议这么做，不安全。

至于ssh勉密钥登录的操作可以自行去百度。目前大数据上的分布式处理就是用这种方式来建立主机的互信关系的。

今天我们主要是讲没有建立信任关系下自动输入密码的功能，这个引入今天的主角 expect，使用如下命令进行安装：

```
$ sudo yum install expect
```

‍

## [#](https://wiki.eryajf.net/pages/5279.html#_3%E3%80%81%E5%85%A5%E9%97%A8%E8%84%9A%E6%9C%AC) 3、入门脚本

简单示例如下：

```
$ cat expect.sh 
#!/usr/bin/expect

set timeout 20
spawn ssh root@10.20.24.103
expect "root"
send "paic1234\n"
interact
```

‍

​`说明 :`​

* 第一行是指定执行的模式，我们平时写shell 是用 #!/bin/bash 等等，这个我们执行我们用 `#!/usr/bin/expect`​
* set timeout 20 这个是用来设置相应的时间，如果里面的脚本执行或者网络问题超过了这个时间将不执行，这个timeout模式是10
* spawn 表示在expect下面需要执行的shell脚本
* expect 是捕获执行shell以后系统返回的提示框内容。`""`​这个表示提示框里面是否包括这个内容
* send 如果expect监测到内容了，那么就将send后的内容发送出去 \n表示回车
* interact 表示结束expect回话，可以继续输入，但是不会返回终端

```
$ hostname
SZB-L0032014
$ ./expect.sh 
spawn ssh root@10.20.24.103
root@10.20.24.103's password: 
Last login: Wed Mar  1 08:24:22 2017 from szb-l0032014
$ hostname
SZB-L0032013
```

‍

## [#](https://wiki.eryajf.net/pages/5279.html#_4%E3%80%81expect%E7%9A%84%E6%A1%88%E4%BE%8B) 4、expect的案例

自动输入github账号和密码 提交到github

```
root@doshell opt $ cat gitpull.sh 
#!/bin/bash
figlet GIT PULL
#=================================================
# System Required: CentOS/Debian/Ubuntu
# Description: git pull script
# Version: 1.0.0
# Author: doshell
# Blog: https://github.com/x14k3/devops/
#=================================================
CWD="/opt"
TODAY=`date "+%Y%m%d"`
if [[ ! -f ${CWD}/mark.md.zip ]];then
        echo -e "\033[36m ${CWD}/mark.md.zip does not exist! \033[0m"
        exit 1
fi
rm ${CWD}/devops/0* -rf
unzip -od ${CWD}/devops ${CWD}/mark.md.zip
mv ${CWD}/mark.md.zip /tmp/mark.md.zip-${TODAY}

cd ${CWD}/devops
git add .
git commit -m "update"

cat ${CWD}/github.token

/usr/bin/expect <<-EOF
set timeout 20
spawn git push origin master
expect "Username for 'https://github.com': " 
send "x14k3\r"
expect "Password for 'https://x14k3@github.com': "
send "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\r"
set results $expect_out(buffer)
expect eof
EOF

```

## [#](https://wiki.eryajf.net/pages/5279.html#_5%E3%80%81%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9) 5、注意事项

* 1、llength argv表示参数的个数2、argv表示参数的个数
* 2、argv0 表示脚本的名称
* 3、lindex $argv 0 表示第一个参数，依次类推到n，参数下标是从0开始的
* 4、if 判断需要用{}括起来
* 5、if 与后面的{}直接需要有空格
* 6、expect {}，多行期望，匹配到哪条执行哪条，有时执行shell后预期结果是不固定的，有可能是询问是yes/no，有可能是去输入密码，所以可以用expect{}
* 7、else不能单独放一行，所以else要跟在}后面
* 8、两个花括号之间必须有空格隔开，比如if {} {}，否则会报错 expect:extra characters after close-brace
* 9、使用{来衔接下一行，所以if的条件后需要加左花括号{

通过各种脚本发现expect对脚本的格式要求特别高，比如{}直接要空格、else以后需要增加{等等，如果发现不能正常运行，优先检查格式是否有问题

‍
