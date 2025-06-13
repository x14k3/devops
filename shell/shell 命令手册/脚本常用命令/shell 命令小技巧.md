# shell 命令小技巧

## 1、SSH key加密算法

​`RSA，DSA，ECDSA，EdDSA和Ed25519`​都用于数字签名，但只有RSA也可以用于加密。根据数学特性，这四种类型又可以分为两大类，dsa/rsa是一类，ecdsa/ed25519是一类，后者算法更先进。

- **RSA（Rivest–Shamir–Adleman）：** 是最早的公钥密码系统之一，被广泛用于安全数据传输。它的安全性取决于整数分解，因此永远不需要安全的RNG（随机数生成器）。与DSA相比，RSA的签名验证速度更快，但生成速度较慢。
- **DSA（数字签名算法）：** 是用于数字签名的联邦信息处理标准。它的安全性取决于离散的对数问题。与RSA相比，DSA的签名生成速度更快，但验证速度较慢。如果使用错误的数字生成器，可能会破坏安全性。从OpenSSH 7.0开始，默认情况下SSH不再支持DSA密钥（ssh-dss）。
- **ECDSA（椭圆曲线数字签名算法）：** 是DSA（数字签名算法）的椭圆曲线实现。椭圆曲线密码术能够以较小的密钥提供与RSA相对相同的安全级别。它还具有DSA对不良RNG敏感的缺点。dsa因为安全问题，已不再使用了。ecdsa因为政治原因和技术原因，也不推荐使用
- **EdDSA（爱德华兹曲线数字签名算法）：** 是一种使用基于扭曲爱德华兹曲线的Schnorr签名变体的数字签名方案。签名创建在EdDSA中是确定性的，其安全性是基于某些离散对数问题的难处理性，因此它比DSA和ECDSA更安全，后者要求每个签名都具有高质量的随机性。
- **Ed25519：** 是EdDSA签名方案，但使用SHA-512 / 256和Curve25519；它是一条安全的椭圆形曲线，比DSA，ECDSA和EdDSA 提供更好的安全性，并且具有更好的性能（人为注意）。ed25519是目前最安全、加解密速度最快的key类型，由于其数学特性，它的key的长度比rsa小很多，优先推荐使用。它目前唯一的问题就是兼容性，即在旧版本的ssh工具集中可能无法使用。

  ```
  ssh-keygen -t ed25519 -C "curiouser@curiouser.com" -f ./id_ed25519
  ```

**如果可以的话，优先选择ed25519，否则选择rsa。**

参考：

- [https://security.stackexchange.com/questions/90077/ssh-key-ed25519-vs-rsa](https://security.stackexchange.com/questions/90077/ssh-key-ed25519-vs-rsa)
- [https://www.cnblogs.com/librarookie/p/15389876.html](https://www.cnblogs.com/librarookie/p/15389876.html)

## 2、bash不显示路径

命令行会变成-bash-3.2$主要原因可能是用户主目录下的配置文件丢失

```
# 方式一
cp -a /etc/skel/. ~

# 方式二
echo "export PS1='[\u@\h \W]\$'" >> ~/.bash_profile ;\
source ~/.bash_profile
```

## 3、同时监控多个文件

```bash
tail -f file1 file2
```

## 5、cp目录下的带隐藏文件的子目录

```
cp -R /home/test/* /tmp/test
```

/home/test下的隐藏文件都不会被拷贝，子目录下的隐藏文件倒是会的

```
cp -R /home/test/. /tmp/test
```

cp的时候有重复的文件需要覆盖时会让不停的输入yes来确认，可以使用yes|

```
yes|cp -r /home/test/. /tmp/test
```

## 9、查看物理CPU个数、核数、逻辑CPU个数

​`CPU总核数 = 物理CPU个数 * 每颗物理CPU的核数`​ `总逻辑CPU数 = 物理CPU个数 * 每颗物理CPU的核数 * 超线程数`​

```
# 查看CPU信息（型号）
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c

# 查看物理CPU个数
cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l

# 查看每个物理CPU中core的个数(即核数)
cat /proc/cpuinfo| grep "cpu cores"| uniq

# 查看逻辑CPU的个数
cat /proc/cpuinfo| grep "processor"| wc -l
```

## 10、Linux缓存

cached是cpu与内存间的，buffer是内存与磁盘间的，都是为了解决速度不对等的问题。buffer是即将要被写入磁盘的，而cache是被从磁盘中读出来的

- **buff**：作为buffer cache的内存，是块设备的读写缓冲区
- **cache**：作为page cache的内存，文件系统的cache。Buffer cache是针对磁盘块的缓存，也就是在没有文件系统的情况下，直接对磁盘进行操作的数据会缓存到buffer cache中。
- **pagecache**：页面缓存（pagecache）可以包含磁盘块的任何内存映射。这可以是缓冲I/O，内存映射文件，可执行文件的分页区域——操作系统可以从文件保存在内存中的任何内容。Page cache实际上是针对文件系统的，是文件的缓存，在文件层面上的数据会缓存到page cache。
- **dentries**：表示目录的数据结构
- **inodes**：表示文件的数据结构

```
#内核配置接口 /proc/sys/vm/drop_caches 可以允许用户手动清理cache来达到释放内存的作用，这个文件有三个值：1、2、3（默认值为0）

#释放pagecache
echo 1 > /proc/sys/vm/drop_caches

#释放dentries、inodes
echo 2 > /proc/sys/vm/drop_caches

#释放pagecache、dentries、inodes
echo 3 > /proc/sys/vm/drop_caches
```

## 11、设置代理

```
$> bash -c 'cat >> /etc/profile <<EOF
# HTTP协议使用代理服务器地址
export http_proxy=http://1.2.3.4:3128
# HTTPS协议使用代理服务器地址
export https_proxy=https://1.2.3.4:3128
# FTP协议使用代理服务器地址
export https_proxy=https://1.2.3.4:3128
# 不使用代理的IP或主机
export no_proxy=.abc.com,127.0.0.0/8,192.168.0.0/16,.local,localhost,127.0.0.1

export HTTP_PROXY="http://1.2.3.4:3128"
export HTTPS_PROXY="http://1.2.3.4:3128"
export NO_PROXY="192.168.0.0/16,.taobao.com,.okd311.curiouser.com"

export 
EOF' ;\
   sed -i '/^##/d' /etc/profile ;\
   source /etc/profile
```

**注意**：

- 当使用“**export http_proxy**”和“**export https_proxy**”设置代理时，curl默认所有的请求都是走的代理，请求域名不通过/etc/hosts解析。
- 所以当有需求curl命令不走代理，通过/etc/hosts解析时，代理设置要通过“**export HTTP_PROXY**”和“**export HTTPS_PROXY**”设置。（原因是url.c（版本7.39中的第4337行）处看先检查小写版本，如果找不到，则检查大写。链接：[https://stackoverflow.com/questions/9445489/performing-http-requests-with-curl-using-proxy）](https://stackoverflow.com/questions/9445489/performing-http-requests-with-curl-using-proxy%EF%BC%89)
- **no_proxy不支持模糊匹配**。不支持`*.a.com`​，支持`.a.com`​

## 13、时间戳与日期

### 日期与时间戳的相互转换

```
#将日期转换为Unix时间戳
date +%s

#将Unix时间戳转换为指定格式化的日期时间
date -d @1361542596 +"%Y-%m-%d %H:%M:%S"
```

### date日期操作

```
date +%Y%m%d               #显示前天年月日
date -d "+1 day" +%Y%m%d   #显示前一天的日期
date -d "-1 day" +%Y%m%d   #显示后一天的日期
date -d "-1 month" +%Y%m%d #显示上一月的日期
date -d "+1 month" +%Y%m%d #显示下一月的日期
date -d "-1 year" +%Y%m%d  #显示前一年的日期
date -d "+1 year" +%Y%m%d  #显示下一年的日期
```

### 获得毫秒级的时间戳

在linux Shell中并没有毫秒级的时间单位，只有秒和纳秒。其实这样就足够了，因为纳秒的单位范围是（000000000..999999999），所以从纳秒也是可以的到毫秒的

```
current=`date "+%Y-%m-%d %H:%M:%S"`     #获取当前时间，例：2015-03-11 12:33:41
timeStamp=`date -d "$current" +%s`      #将current转换为时间戳，精确到秒
currentTimeStamp=$((timeStamp*1000+`date "+%N"`/1000000)) #将current转换为时间戳，精确到毫秒
echo $currentTimeStamp
```

## 14、nohup手动后台运行进程并记录进程号

```
nohup jar -jar jar包 </dev/null > /data/app/logs/app.log 2>&1 &
echo $! > /data/app/run.pid

# 2>&1是把标准错误2重定向到标准输出1中，而标准输出又导入文件里面，所以标准错误和标准输出都会输出到文件。
# 同时把启动的进程号pid输出到文件

注意：
    如果运行时的shell为zsh，将任务放置后台的命令由”&“变为”&!“。
    参考：https://stackoverflow.com/questions/19302913/exit-zsh-but-leave-running-jobs-open
```

## 15、生成文件的MD值

在网络传输、设备之间转存、复制大文件等时，可能会出现传输前后数据不一致的情况。这种情况在网络这种相对更不稳定的环境中，容易出现。那么校验文件的完整性，也是势在必行的。

在网络传输时，我们校验源文件获得其md5sum，传输完毕后，校验其目标文件，并对比如果源文件和目标文件md5 一致的话，则表示文件传输无异常。否则说明文件在传输过程中未正确传输。

md5值是一个128位的二进制数据，转换成16进制则是32（128/4）位的进制值。 md5校验，有很小的概率不同的文件生成的md5可能相同。比md5更安全的校验算法还有SHA\*系列的。

### **Linux的md5sum命令**

md5sum命令用于生成和校验文件的md5值。它会逐位对文件的内容进行校验。是文件的内容，与文件名无关，也就是文件内容相同，其md5值相同。

```
#md5sum命令的详解
$> md5sum --h
Usage: md5sum [OPTION]... [FILE]
With no FILE, or when FILE is -, read standard input.
-b, --binary         二进制模式读取文件
-c, --check          从文件中读取、校验MD5值
      --tag          创建一个BSD-style风格的校验值
-t, --text           文本模式读取文件（默认）
#校验文件MD5值使用的参数
The following four options are useful only when verifying checksums:
      --quiet          don't print OK for each successfully verified file
      --status         don't output anything, status code shows success
      --strict         exit non-zero for improperly formatted checksum lines
  -w, --warn           warn about improperly formatted checksum lines

      --help     display this help and exit
      --version  output version information and exit


#生成的MD5值重定向到文件中
$>md5sum filename > filename.md5
#生成的MD5值重定向追加到文件中
$> md5sum filename >>filename.md5
#多个文件输出到一个md5文件中，这要使用通配符*
$> md5sum *.iso > iso.md5
#同时计算多个文件的MD5值
$> md5sum filetohashA.txt filetohashB.txt filetohashC.txt > hash.md5

#校验MD5:把下载的文件file和该文件的file.md5报文摘要文件放在同一个目录下
$> md5sum -c file.md5
#创建一个BSD风格的校验值
$> md5sum --tag file.md5
MD5 (file.md5) = 9192e127b087ed0ae24bb12070f3051a
```

## 19、检查软件是否已安装，没有就自动安装

```
rpm -qa |grep "jq"
if [ $? -eq 0 ] ;then
    echo "jq hava been installed "
else
    yum -y install epel-release && yum -y install jq
fi
```

## 20、使用privoxy代理http，https流量使用socket连接ShadowSocks服务器

```
echo "安装ShadowSocks" && \
yum -y install epel-release && yum -y install python-pip && \
pip install shadowsocks && \
bash -c 'cat > /etc/shadowsocks.json <<EOF
{
"server": "***.***.***.***",
"server_port": "443",
"local_address": "127.0.0.1",
"local_port":"1080",
"password": "******",
"timeout":300,
"method": "aes-256-cfb",
"fast_open": false
}
EOF' && \
bash -c 'cat > /etc/systemd/system/shadowsocks.service << EOF
[Unit]
Description=Shadowsocks
[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/sslocal -c /etc/shadowsocks.json
[Install]
WantedBy=multi-user.target
EOF' && \
  systemctl daemon-reload  && \
  systemctl enable shadowsocks && \
  systemctl start shadowsocks

yum install -y privoxy && \
sed -i 's/#        forward-socks5t   \/               127.0.0.1:9050 ./        forward-socks5t   \/               127.0.0.1:1080 ./' /etc/privoxy/config && \
privoxy --user privoxy /etc/privoxy/config && \
echo "export http_proxy=http://127.0.0.1:8118" >> /etc/profile && \
echo "export https_proxy=http://127.0.0.1:8118" >> /etc/profile && \
source /etc/profile && \
curl www.google.com
```

## 21、批量打通指定主机SSH免密钥登录脚本

**CentOS**

```
$> bash -c 'cat > ./HitthroughSSH.sh <<EOF
#!/bin/bash

##
#===========================================================
echo "script    usage : ./HitthroughSSH.sh hosts.txt"
echo "hosts.txt format: host_ip:root_password"

#=========================================================
echo "==Setup1:Check if cmd expect exist,if no,install automatically"
rpm -qa | grep expect 
if [ \$? -ne 0 ];then
yum install -y expect
fi
#=====================================
echo "==Setup2:Check if have been generated ssh private and public key.if no ,generate automatically "

if [ ! -f ~/.ssh/id_rsa ];then
  ssh-keygen -t rsa  -P "" -f ~/.ssh/id_rsa
fi
#===========================================================
echo "Setup3:Read IP and root password from text"
echo "Setup4:Begin to hit root ssh login without password thorough hosts what defined in the hosts.txt"
for p in \$(cat \$1)  
do   
    ip=\$(echo "\$p"|cut -f1 -d":")       
    password=\$(echo "\$p"|cut -f2 -d":")  
    expect -c "   
            spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@\$ip  
            expect {   
                \"*yes/no*\" {send \"yes\r\"; exp_continue}   
                \"*password*\" {send \"\$password\r\"; exp_continue}   
                \"*Password*\" {send \"\$password\r\";}   
            }   
        "
    ssh root@\$ip "date"
done
EOF' ;\
  sed -i -c -e '/^$/d;/^##/d' ./HitthroughSSH.sh ;\
  chmod +x ./HitthroughSSH.sh ;\
  bash -c 'cat > ./hosts.txt <<EOF
172.16.0.3:Abc@1234
172.16.0.4:Abc@1234
172.16.0.5:Abc@1234
172.16.0.6:Abc@1234
172.16.0.7:Abc@1234
EOF' ;\
  ./HitthroughSSH.sh ./hosts.txt ;\
  rm -rf ./HitthroughSSH.sh ./hosts.txt
```

## 22、硬盘自动分区，格式化，开机自动挂载到/data

```
disk=/dev/sdc;\
bash -c "fdisk ${disk}<<End
n
p
1


wq
End" ;\
mkfs.ext4 ${disk}1 ;\
blkid | grep ${disk}1 | cut -d ' ' -f 2 >>/etc/fstab ;\
sed -i '$ s/$/ \/data ext4 defaults 0 0/' /etc/fstab ;\
mkdir /data ;\
mount -a ;\
df -h
```

## 24、Linux禁用透明大页

**Redhat**

```
sed -i '$a echo nerver > /sys/kernel/mm/redhat_transparent_hugepage/defrag\necho nerver > /sys/kernel/mm/redhat_transparent_hugepage/enabled'
```

**CentOS**

```
echo never > /sys/kernel/mm/transparent_hugepage/defrag ;\
echo never > /sys/kernel/mm/transparent_hugepage/enabled ;\
sed -i '/GRUB_CMDLINE_LINUX/ s/"$/ transparent_hugepage=never"/' /etc/default/grub ;\
grub2-mkconfig -o /boot/grub2/grub.cfg
```

## 27、字符转换命令expand/unexpand

用于将文件的制表符（Tab）转换为空格符（Space），默认一个Tab对应8个空格符，并将结果输出到标准输出。若不指定任何文件名或所给文件名为”-“，则expand会从标准输入读取数据。

功能与之相反的命令是unexpand，是将空格符转成Tab符。

vi/vim在命令模式下通过设置":set list"可显示文件中的制表符“^I”

**expand命令参数**

```
-i, --initial       do not convert tabs after non blanks
-t, --tabs=NUMBER   have tabs NUMBER characters apart, not 8
-t, --tabs=LIST     use comma separated list of explicit tab positions
    --help     display this help and exit
    --version  output version information and exit
```

**unexpand命令参数**

```
-a, --all        convert all blanks, instead of just initial blanks
    --first-only  convert only leading sequences of blanks (overrides -a)
-t, --tabs=N     have tabs N characters apart instead of 8 (enables -a)
-t, --tabs=LIST  use comma separated LIST of tab positions (enables -a)
    --help     display this help and exit
    --version  output version information and exit
```

**实例**

将文件中每行第一个Tab符替换为4个空格符，非空白符后的制表符不作转换

```
#使用"----"或"--"代表一个制表符，使用":"代表一个空格
----abcd--e

$ expand -i -t 4 old-file > new-file

::::abcd--e
```

**注意**

不是所有的Tab都会转换为默认或指定数量的空格符，expand会以对齐为原则将Tab符替换为适当数量的空格符，替换的原则是使后面非Tab符处在一个物理Tab边界（即Tab size的整数倍。例如：

```
#使用"----"或"--"代表一个制表符，使用":"代表一个空格
abcd----efg--hi

$ expand -t 4 file

abcd::::efg::hi
```

## 28、修改时区

1. Docker容器中

    - 添加环境变量：TZ = Asia/Shanghai
2. Linux主机

    ```
    timedatectl set-timezone "Asia/Shanghai"
    # 设置时区
    timedatectl status 
    # 查看当前的时区状态
    date -R
    # 查看时区
    ```

    或者

    ```
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    ```

‍

## 29、shell脚本的调试

- 在脚本运行时添加`-x`​参数
- 在脚本中开头添加`set -x`​

‍

## 30、删除“-”开头的文件或文件夹

当直接使用`rm -f`​删除以`-`​开头的文件与文件夹时，rm或其他命令报参数错误，会误认为`-`​后面的内容是命令的参数

```
rm  -rf -- -XGET

cd -- -XGET
```

## 31、硬盘快速分区

### 方式一：使用parted命令

parted命令详解：[https://www.cnblogs.com/Cherry-Linux/p/10103172.html](https://www.cnblogs.com/Cherry-Linux/p/10103172.html)

```
disk=/dev/vdb && \
parted -s -a optimal $disk mklabel gpt -- mkpart primary ext4 1 -1
```

### 方式二：使用fdisk

```
disk=/dev/vdb && \
bash -c "fdisk ${disk}<<End
n
p
1


wq
End"
```

## 32、别名传参

别名并不能直接传参，但是可以使用以下方式代替：

### 方式一：使用functions替代

```
$ test () { num=${1:-5} dmesg |grep -iw usb|tail -$num }
$ test 5
```

### 方式二：使用read读取输入，然后使用变量替换命令中的参数

```
$ alias taila='{ IFS= read -r line_num && tail -n $line_num /var/logs/message ;} <<<'
$ taila 50
```

## 34、裸磁盘分区扩容

1. 停掉向挂载路径写文件的服务或进程
2. 卸载挂载

    ```bash
    umount /data
    ```

    如果提示`umount:/data:target is bus`​,使用`fuser`​找出正在往挂载路径写文件的进程并kill掉，再次卸载挂载

    ```
    yum install psmisc -y
    fuser -mv /data
                         USER        PID ACCESS COMMAND
    /data:                root     kernel mount /data
                         root      13830 ..c.. bash
    ```

3. 修复分区表

    磁盘扩大容量后，分区表中记录的柱头等信息需要更新，否则创建新分区时会报`GPT PMBR size mismatch`​

    ```
    parted -l
    在弹出Fix/Ignore?的提示时输入Fix后回车即可。
    ```

4. 删掉旧分区再重建新分区

    ```
    fdisk /dev/sdb
        d            # 删除原来的分区/dev/sdb1
        n            #    创建新的分区      
        1            # 分区号与旧的保持一致
        w            # 写入分区表并生效
    ```

5. 调整分区

    ```
    e2fsck -f /dev/sdb1 检查分区信息
    resize2fs /dev/sdb1 调整分区大小
    ```

6. 重新挂载并验证数据是否丢失？容量是否扩容？

## 38 、生成随机字符串

```
# 根据时间戳加随机数计算md5值并取前10位
echo $(date +%s)$RANDOM | md5sum | base64 | head -c 10

head -c 16 /dev/random | base64

openssl rand -hex 10

cat /proc/sys/kernel/random/uuid| cksum |cut -f1 -d" " | base64

head -n 5 /dev/urandom |sed 's/[^a-Z0-9]//g'|strings -n 4

tr -dc '_A-Z#\-+=a-z(0-9%^>)]{<|' </dev/urandom | head -c 15; echo
```

## 39、ssh目录的权限问题

- ​`home`​目录的权限为**700**：`chmod 700 /home/用户`​
- ​`.ssh目录`​的权限应为**700**：`chmod 700 ~/.ssh`​
- ​`.ssh目录下authorized_keys文件`​的权限应为**600**：`chmod 600 ~/.ssh/authorized_keys`​

## 41、使用curl命令发送邮件

```
curl -s --ssl-reqd --write-out %{http_code} --output /dev/null \
  --url "smtp://发件人SMTP服务器地址:发件人SMTP服务器端口" \
  --user "发件人SMTP服务器用户名:发件人SMTP服务器密码" \
  --mail-from 发件人邮箱地址 \
  --mail-rcpt 收件人邮箱地址 \
  --upload-file /tmp/emai-data.txt

# /tmp/emai-data.txt的内容

FROM: 发件人邮箱地址
To: 收件人邮箱地址
CC: 抄送人邮箱地址
Subject: 主题
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="DELIMETER"

--DELIMETER
Content-Type: text/html; charset="utf-8"

<html>
<body>
<h1>测试<h1>
</body>
</html>

--DELIMETER
Content-Type: text/plain; name=test.txt
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=test.txt

[base64编码的附件内容]

--DELIMETER
```

## 42、split按行或大小切割大文件

**split命令** 可以将一个大文件分割成很多个小文件，有时需要将文件分割成更小的片段，比如为提高可读性，生成日志等。

**选项**

```
-a, --suffix-length=N   指定后缀长度(默认为2)
    --additional-suffix=SUFFIX  append an additional SUFFIX to file names
-b, --bytes=SIZE        put SIZE bytes per output file
-C, --line-bytes=SIZE   put at most SIZE bytes of lines per output file
-d, --numeric-suffixes[=FROM]  使用数字作为后缀(默认起始值为0)
-e, --elide-empty-files  do not generate empty output files with '-n'
    --filter=COMMAND    write to shell COMMAND; file name is $FILE
-l, --lines=NUMBER      值为每一输出档的行数大小。
-n, --number=CHUNKS     generate CHUNKS output files; see explanation below
-u, --unbuffered        immediately copy input to output with '-n r/...'
      --verbose        在每个输出文件打开前输出文件特征
      --help        显示此帮助信息并退出
      --version        显示版本信息并退出

SIZE is an integer and optional unit (example: 10M is 10*1024*1024).  Units are K, M, G, T, P, E, Z, Y (powers of 1024) or KB, MB, ... (powers of 1000).

CHUNKS may be:
N       split into N files based on size of input
K/N     output Kth of N to stdout
l/N     split into N files without splitting lines
l/K/N   output Kth of N to stdout without splitting lines
r/N     like 'l' but use round robin distribution
r/K/N   likewise but only output Kth of N to stdout
```

**实例**

使用split命令将date.file文件分割成大小为10KB的小文件：

```bash
split -b 10k date.file 

date.file  xaa  xab  xac  xad  xae  xaf  xag  xah  xai  xaj
```

文件被分割成多个带有字母的后缀文件，如果想用数字后缀可使用-d参数，同时可以使用-a length来指定后缀的长度：

```bash
split -b 10k date.file -d -a 3

date.file  x000  x001  x002  x003  x004  x005  x006  x007  x008  x009
```

为分割后的文件指定文件名的前缀：

```bash
split -b 10k date.file -d -a 3 split_file

date.file  split_file000  split_file001  split_file002  split_file003  split_file004  split_file005  split_file006  split_file007  split_file008  split_file009
```

使用-l选项根据文件的行数来分割文件，例如把文件分割成每个包含10行的小文件：

```bash
split -l 10 date.file
```

## 46、对bash执行curl的脚本进行传参

```
curl http://test.com/test/test.sh | bash -s arg1 arg2

bash <(curl -s http://test.com/test/test.sh ) arg1 arg2
# 若参数中带有”-“，则可使用长选项”–”解决
curl -s http://test.com/test/test.sh | bash -s -- arg1 arg2
# 若参数为”-p arg -d arg”,则
curl -s http://test.com/test/test.sh | bash -s -- -p arg1 -d arg2
```

## 47、windows下编写的脚本文件，放到Linux中无法识别格式

在Linux中执行.sh脚本，异常`/bin/sh^M: bad interpreter: No such file or directory。`​windows下编写的脚本文件，放到Linux中无法识别格式，在vi的时候,会在下面显示此文件的格式,比如 `"dos.txt" [dos] 120L, 2532C`​ 字样,表示是一个`[dos]`​格式文件,如果是MAC系统的,会显示`[MAC]`​。dos格式文件传输到unix系统时,会在每行的结尾多一个`^M`​

用vi打开脚本文件，在命令模式下输入`set ff=unix`​ 用命令`:set ff?`​可以看到dos或unix的字样

其他工具去除参考：[文本处理的第七章节](https://gitbook.curiouser.top/origin/linux-%E6%96%87%E6%9C%AC%E5%A4%84%E7%90%86.html)

## 55、SSH跳板登录

```
ssh username@目标机器ip -o ProxyCommand=’ssh username@跳板机ip -W %h:%p’
```

也可以在配置文件 `~/.ssh/config`​ (若没有则创建)中配置

```
Host test-ssh-forward
  HostName 目标机器ip
  User root
  ProxyCommand ssh root@跳板机ip -W %h:%p
```

通过中间主机SSH连接

```
ssh -t reachable_host ssh unreachable_host
```

## 56、OpenSSH客户端配置

针对OpenSSH客户端ssh命令的配置有全局配置文件`/etc/ssh/ssh_config`​ ，用户级别配置文件`~/.ssh/config`​。可在其中配置常用的SSH主机配置

```
Host 主机别名
    HostName 主机IP地址 
    User 登录用户
    Port 端口                      # 默认为22
    IdentityFile ssh私钥文件路径    # 默认为~/.ssh/identity 、~/.ssh/id_rsa 、~/.ssh/id_dsa
    Compression yes               # 是否进行压缩
    LogLevel INFO
```

‍

## 60、crontab下使用date和sudo命令

- crontab下使用date命令需要转义`%`​，例如： `date +"\%Y\%m\%d_\%H:\%M"`​ 和 `$(date +"\%Y\%m\%d_\%H:\%M")`​
- 直接在crontab里以sudo执行命令无效，会提示 `sudo: sorry, you must have a tty to run sudo`​ .需要修改`/etc/sudoers`​，执行visudo或者`vim /etc/sudoers`​ 将`Defaults requiretty`​这一行注释掉。因为sudo默认需要tty终端，而crontab里的命令实际是以无tty形式执行的。注释掉"Defaults requiretty"即允许以无终端方式执行sudo

  ```
  但是，这里关于安全性方面有一点需要注意。关于该配置项，说明如下Disable "`ssh hostname sudo <cmd>`", because it will show the password in clear.You have to run "ssh -t hostname sudo <cmd>".该配置的作用是禁止执行"ssh hostname sudo <cmd>"，因为这种方式会将sudo密码以明文显示，你可以运行"ssh -t hostname sudo <cmd>"来替代。开启的情况下，"ssh hostname sudo <cmd>"无法执行成功，关闭了之后，就没有这一层的检查了。
  ```

参考：[https://blog.csdn.net/kai404/article/details/52169122](https://blog.csdn.net/kai404/article/details/52169122)

## 63、脚本加密shc

```
CFLAGS=-static sh -r -T -e 03/31/2027 -f tesh.sh
# CFLAGS=-static 设置进行静态编译链接
# -f 指定脚本文件
# -e 设置脚本在指定日期后失效，日期格式：dd/mm/yyyy
# -m 指定过期提示的信息
# -T 设置是否允许二进制可被工具(例如strace, ptrace, truss)调试
# -r 在不同操作系统执行
```

- 生成以下文件

  - ​`tesh.sh`​
  - ​`tesh.sh.x`​是加密后可执行的二进制文件
  - ​`tesh.sh.x.c`​ 是 `tesh.sh.x`​ 的源文件（注意是C语言版本的源文件）
- shc生成的二进制文件只能通过 `./xxx`​ 命令来执行，不能通过 `/bin/bash xxx`​ 来执行。
- shc加密的脚本在运行时`ps -ef`​可以看到shell的源码
- 在执行加密脚本的时候，还是会在内存中解密全部的shell代码。解密的思路就是**从内存中获取解密后的代码**。
- shc加密脚本解密可参考：[https://cloud.tencent.com/developer/article/1451796](https://cloud.tencent.com/developer/article/1451796)

参考：

1. [https://linux.die.net/man/1/shc](https://linux.die.net/man/1/shc)
2. [https://www.linuxjournal.com/article/8256](https://www.linuxjournal.com/article/8256)

## 64、节省tar解压大文件中指定文件的速度

```
tar -zxvf 压缩包 --occurrence 压缩包中的文件路径
# --occurrence参数默认会在解压到第一次匹配的文件后不再处理后续解压。极大节省了解压时间
```

参考：[https://superuser.com/questions/655739/extract-single-file-from-huge-tgz-file](https://superuser.com/questions/655739/extract-single-file-from-huge-tgz-file)

## 65、seq快速生成序列化数据

### seq命令格式与参数

```
seq [选项]... 尾数
seq [选项]... 首数 尾数
seq [选项]... 首数 增量 尾数
选项：
  -f, --format=格式   使用printf样式的浮点格式
  -s, --separator=字符串   使用指定字符串分隔数字(默认使用：\n)
  -w, --equal-width  在列前添加0 使得宽度相同【自动补位】
```

### 生成IP地址

```
seq -f "10.1.2.%g" 2 254 > ip-pools
# 10.1.2.2
# 10.1.2.3
# ....
# 10.1.2.254
```

### 指定分隔符 横着输出

```bash
seq -s '-' 5
# 1-2-3-4-5
```

### 默认补位操作

```
seq -w 1 5
# 01
# 02
# 03
# 04
# 05
```

## 67、 特殊文件操作

### 快速备份文件

```bash
cp filename{,.backup}
```

### 删除文件夹中与特定文件扩展名不匹配的所有文件

```bash
rm !(*.foo|*.bar|*.baz)
```

### 将多行字符串传递给文件

```
# cat  >filename ... - overwrite the file
# cat >>filename ... - append to a file
cat > filename << __EOF__
data data data
__EOF__
```

### 使用 vim 编辑远程主机上的文件

```
vim scp://user@host//etc/fstab
```

## 68、lsof

```
# 显示当前使用互联网连接的进程
lsof -P -i -n

# 显示使用特定端口号的进程
lsof -i tcp:443

# 列出所有侦听端口以及关联进程的 PID
lsof -Pan -i tcp -i udp

# 列出所有打开的端口及其所属的可执行文件
lsof -i -P | grep -i "listen"

# 显示所有开放端口
lsof -Pnl -i

# 显示开放端口 (LISTEN)
lsof -Pni4 | grep LISTEN | column -t

# 列出由特定命令打开的所有文件
lsof -c "process"

# 查看每个目录的用户活动
lsof -u username -a +D /etc

# 显示 10 个最大的打开文件
lsof / | \
awk '{ if($7 > 1048576) print $7/1048576 "MB" " " $9 " " $1 }' | \
sort -n -u | tail | column -t

# 显示进程的当前工作目录
lsof -p <PID> | grep cwd
```

‍

## 70、监控特定端口的打开连接，包括按 IP 侦听、计数和排序

```
watch -n 1 "netstat -plan | grep :443 | awk {'print \$5'} | cut -d: -f 1 | sort | uniq -c | sort -nk 1"
```

## 71、压缩包加密

- **加密**

  ```
  tar -czvf - test-files | openssl des3 -salt -k 加密密码 -out files.tar.gz

  zip -P 加密密码 -r 压缩文件名.zip 要压缩的文件夹
  ```
- **解密**

  ```
  openssl des3 -d -k password -salt -in files.tar.gz | tar xzvf -

  unzip -P 加密密码 压缩文件名.zip
  ```

## 72、tailf自动退出

tail 的`--pid`​参数，监控某一个pid，当检测到pid停止的时候，停止tail

- **根据进程状态决定是否终止退出**

  ```
  tail -f --pid=$(ps -ef | grep java | grep -v "grep" | awk '{ print $2 } ' | sort -nr | head -1) ./nohup.log
  # MacOS下tail没有--pid参数，可使用 gtail 替代
  gtail -f --pid=$(ps -ef | grep java | grep -v "grep" | awk '{ print $2 } ' | sort -nr | head -1) ./nohup.log
  ```
- **根据输出日志关键字决定是否终止退出**

  ```bash
  ```

参考：[https://cloud.tencent.com/developer/article/2019300](https://cloud.tencent.com/developer/article/2019300)

## 73、base64 编解码字符末尾“=”的特殊说明

**编码**

如果要编码的二进制数据不是3的倍数，就用`\x00`​字节在末尾补足，然后再在编码的末尾加上1到2个等号（`=`​），表示补了多少字节，这样解码的时候就可以自动去掉了。特别注意，Base64编码后的文本的长度总是4的倍数，但是如果再加上1到2个`=`​不就不是4的倍数了吗？所以并不是先编码，再加上1到2个`=`​，而是编码之后，把最后的1到2个字符（这个字符肯定是`A`​）**替换**成`=`​

**解码**

与编码相反，首先去除末尾的等号（`=`​），然后比对初始的64字符的数组，把编码后的文本转成各字符在数组里的索引值，再然后转成6比特的二进制数，最后删除多余的`\x00`​。

1. 标准Base64里是包含 `+`​ 和 `/`​ 的，在URL里不能直接作为参数，所以出现一种 “url safe” 的Base64编码，其实就是把 `+`​ 和 `/`​ 替换成 `-`​ 和 `_`​ 。
2. 同样的，`=`​也会被误解，所以编码后干脆去掉`=`​，解码时，自动添加一定数量的等号，使得其长度为4的倍数即可正常解码了。

**参考**：[https://www.jianshu.com/p/ccdef9b179e7](https://www.jianshu.com/p/ccdef9b179e7)

## 75、TCP端口状态

```
LISTEN：      侦听来自远方的TCP端口的连接请求
SYN-SENT：    再发送连接请求后等待匹配的连接请求
SYN-RECEIVED：再收到和发送一个连接请求后等待对方对连接请求的确认
ESTABLISHED： 代表一个打开的连接
FIN-WAIT-1：  等待远程TCP连接中断请求，或先前的连接中断请求的确认
FIN-WAIT-2：  从远程TCP等待连接中断请求
CLOSE-WAIT：  等待从本地用户发来的连接中断请求
CLOSING：     等待远程TCP对连接中断的确认
LAST-ACK：    等待原来的发向远程TCP的连接中断请求的确认
TIME-WAIT：   等待足够的时间以确保远程TCP接收到连接中断请求的确认
CLOSED：      没有任何连接状态
```

## 78、查看磁盘vid、pid

如何查看设备的Vendor ID (制造商ID：vid) 和 Product ID (型号ID: pid)

- **Windows**

  > 设备管理器 --> 展开磁盘驱动器选项，右键选择属性，在详细信息选项卡中找到硬件ID。
  >
- **Linux**

  ```bash
  lspci -v
  ```
- **MacOS**

  ```
  ioreg -c IOBlockStorageDriver -r -w 0
  ```

## 79、dig

> dig <要查询的域名> @

```
# 要查询 example.com 的 A 记录，并且不使用本地缓存
dig a www.baidu.com @8.8.8.8 |grep "www.baidu.com" | sed '1,2d' | awk '{print $5}'

# 只显示A记录，不显示CNAME
dig +short +nocomments +noquestion a www.baidu.com @8.8.8.8 | awk 'match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/) {print substr($0, RSTART, RLENGTH)}'
```

## 79、trip

[https://trippy.cli.rs/#configuration-reference](https://trippy.cli.rs/#configuration-reference)
