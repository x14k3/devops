#openSource

# 对称加密

*   加解密使用同一个密钥；将数据分割成固定大小的块，逐块加密；且块与块之间有关联关系； &#x20;

*   算法：DES,3DES,AES,Blowfish,Twofish,IDEA,RC6,CAST5 &#x20;

*   缺陷：密钥过多；密钥分发成为难题；

常用选项有：

```bash
-ciphername      # 指定加密算法（默认可不写）
-in filename     # 指定要加密的文件存放路径
-out filename    # 指定加密后的文件存放路径
-salt            # 自动插入一个随机数作为文件内容加密，默认选项
-e               # 加密，可以指明一种加密算法，若不指的话将使用默认加密算法
-d               # 解密，解密时也可以指定算法，若不指定则使用默认算法，但一定要与加密时的算法一致
-a/-base64       # 使用-base64位编码格式
```

```bash
echo "qwe" > test.txt
# 加密
openssl enc -des3 -a -in test -out testjm # 或 openssl enc -e -des3 -a -in test -out testjm

# 解密
openssl enc -d -des3 -a -in testjm -out newtest

```

# 公钥加密

密钥分为**公钥和私钥**：用公钥加密的数据，只能用与之配对的私钥解密；私钥加密的数据，只能用与之配对的公钥解密
- 公钥：从私钥中提取产生；可公开给所有人；pubkey 
- 私钥：通过工具创建，使用者自己保留，必须保证其私密性；secret key


用途： 
- 数字签名：确认发送方的身份；
- 密钥交换：发送方用对方的公钥加密一个对称密钥，并发送给对方；

算法：RSA,DSA,ELGamal
首先需要先使用 genrsa 标准命令生成私钥，然后再使用 rsa 标准命令从私钥中提取公钥。

## genrsa生成私钥

用法：`openssl genrsa [-des|-des3|-aes128|-aes192|-aes256] [-passout arg] [-out filename] [numbits]`

```bash
# 选项说明
  -[des|des3|aes128|aes192|aes256]   # 私钥加密算法（对称加密）。
  -passout arg                       # 加密私钥文件时，传递密码的格式，如果要加密私钥文件时单未指定该项，则提示输入密码。arg的格式如下：
    pass:password                    # password表示传递的明文密码。
    env:var                          # 从环境变量var获取密码值。
    file:filename                    # filename文件中的第一行为要传递的密码。若filename同时传递给"-passin"和"-passout"选项，则filename的第一行为"-passin"的值，第二行为"-passout"的值。
    stdin                            # 从标准输入中获取要传递的密码。
  -out filename                      # 将生成的私钥保存至filename文件，若未指定输出文件，则为标准输出。
  -numbits                           # 指定要生成的私钥的长度，默认为1024。该项必须为命令行的最后一项参数。

```

示例：生成一个1024位的RSA私钥，加密算法选择des3，密码为1111，保存为server.key文件

```bash
openssl genrsa -des3 -passout pass:1111 -out server.key 1024
```

## rsa 生成公钥

用法: `openssl rsa [-in filename] [options]`

```bash
# 选项说明
  -inform arg: 输入私钥文件格式，值为：[DER|NET|PEM]。
  -outform arg: 输出私钥文件格式，值为：[DER|NET|PEM]。
  -in filename: 待处理私钥文件。
  -passin arg： 输入这个私钥文件的解密密码（如果在生成这个私钥文件的时，选择了加密算法了的话）。arg的格式如下：
    pass:password：password表示传递的明文密码。
    env:var：从环境变量var获取密码值。
    file:filename：filename文件中的第一行为要传递的密码。若filename同时传递给"-passin"和"-passout"选项，则filename的第一行为"-passin"的值，第二行为"-passout"的值。
    stdin：从标准输入中获取要传递的密码。
  -[des|des3|aes128|aes192|aes256]: 待输出私钥加密算法（对称加密）。
  -passout arg：如果希望输出的私钥文件继续使用加密算法的话则指定密码。arg的格式如下：
    pass:password：password表示传递的明文密码。
    env:var：从环境变量var获取密码值。
    file:filename：filename文件中的第一行为要传递的密码。若filename同时传递给"-passin"和"-passout"选项，则filename的第一行为"-passin"的值，第二行为"-passout"的值。
    stdin：从标准输入中获取要传递的密码。
  -out filename：待输出私钥文件，若未指定输出文件，则为标准输出。
  -noout: 不打印私钥key数据。
  -text: 以文本形式打印私钥key数据。
  -pubin: 检查待处理文件是否为公钥文件。
  -pubout: 输出公钥文件。

```

示例：

```bash
# （1）查看私钥文件明细。
  openssl rsa -in server.key -noout -text
# （2）对加密的私钥文件进行解密。
  openssl rsa -in server_pass.key -passin pass:1111 -out server_nopass.key
# （3）对非加密的私钥文件转加密，加密算法选择aes256。
  openssl rsa -in server_nopass.key -aes256 -passout pass:1111 -out server_pass.key
# （4）对非加密的私钥文件生成对应的公钥文件。
  openssl rsa -in server_pass.key -pubout -out server_public.key
# （5）对加密的私钥文件生成对应的公钥文件。
  openssl rsa -in server_pass.key -passin pass:1111 -pubout -out server_public.key
# （6）私钥PEM转DER
  openssl rsa -in server.key -outform DER -out server_der.key
```

## req生成证书

**req**主要功能有：**生成证书请求文件**， 查看验证证书请求文件，还有就是**生成自签名证书**。

使用openssl把自己的作为一个CA

CA配置文件所在：/etc/pki/
CA配置文件：/etc/pki/tls/openssl.cnf

```bash
####################################################################
[ ca ]
default_ca      = CA_default            # The default ca section   可以创建多个CA，ca_default是默认的CA

####################################################################
[ CA_default ]  默认CA的相关配置

dir             = /etc/pki/CA           # Where everything is kept  变量
certs           = $dir/certs            # Where the issued certs are kept存放发布的证书
crl_dir         = $dir/crl              # Where the issued crl are kept  吊销列表
database        = $dir/index.txt        # database index file.  存放证书的编号
#unique_subject = no                    # Set to 'no' to allow creation of  
                                        # several ctificates with same subject.
new_certs_dir   = $dir/newcerts         # default place for new certs.  新证书的存放
certificate     = $dir/cacert.pem       # The CA certificate  CA证书
serial          = $dir/serial           # The current serial number下一个证书编号
crlnumber       = $dir/crlnumber        # the current crl number吊销证书号
                                        # must be commented out to leave a V1 CRL
crl             = $dir/crl.pem          # The current CRL
private_key     = $dir/private/cakey.pem# The private key  CA私钥文件路径
RANDFILE        = $dir/private/.rand    # private random number file

x509_extensions = usr_cert              # The extentions to add to the cert

# Comment out the following two lines for the "traditional"
# (and highly broken) format.
name_opt        = ca_default            # Subject Name options
cert_opt        = ca_default            # Certificate field options

# Extension copying option: use with caution.
# copy_extensions = copy

# Extensions to add to a CRL. Note: Netscape communicator chokes on V2 CRLs
# so this is commented out by default to leave a V1 CRL.
# crlnumber must also be commented out to leave a V1 CRL.
# crl_extensions        = crl_ext

default_days    = 365                   # how long to certify for证书颁发有效期
default_crl_days= 30                    # how long before next CRL30天发布一下证书吊销列表
default_md      = sha256                # use SHA-256 by default 哈希算法
preserve        = no                    # keep passed DN ordering

# A few difference way of specifying how similar the request should look
# For type CA, the listed attributes must be the same, and the optional
# and supplied fields are just that :-)
policy          = policy_match 策略匹配；默认使用的策略

# For the CA policy
[ policy_match ]
countryName             = match   国家名match必须与CA匹配optional可以不匹配
stateOrProvinceName     = match 州
organizationName        = match 组织
organizationalUnitName  = optional 部门
commonName              = supplied 主机或域名
emailAddress            = optional 邮件地址

# For the 'anything' policy
# At this point in time, you must list all acceptable 'object'
# types.
[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
```

用法 : `openssl req [-new -key filename|-newkey arg] [options] [-out filename]`

```bash
# 选项说明
  -new             # 表示要生成证书请求文件。
  -key filename    # 指定私钥文件，生成证书请求时需要，只与生成证书请求选项"-new"配合。
  -newkey arg      # 类似于"-new"选项加上"-key"选项，用于生成一个新的证书，并创建私钥，私钥文件名称由"-keyout"参数指定。arg的格式如下：
    rsa:bits       #  生成RSA私钥，bits指定私钥长度。
  -nodes           # 如果指定"-newkey"自动生成私钥，那么该选项说明生成的私钥不需要加密。
  -config filename # 指定特殊路径的配置文件，ubuntu上默认参数为:/etc/ssl/openssl.cnf。
  -batch           # 指定非交互模式，直接读取"-config"文件配置参数，或者使用默认参数值。
  -keyout          # 指定新创建私钥文件名，配合"-newkey"使用。
  -x509            # 表示要生成一个自签名证书，而不是生成证书请求文件，一般用于测试或者为根CA创建自签名证书。
  -days n          # 指定自签名证书的有效期限，默认30天，需要和"-x509"一起使用。
  -out filename    # 指定生成的证书请求文件，或者自签名证书。
  -noout           # 不输出REQ数据。
  -text            # 以文本形式打印证书请求。
  -pubkey          # 输出证书请求文件中的公钥。
  -subject         # 查看证书请求文件中的个人信息部分。
  -subj arg        # 替换或自定义证书请求时需要输入的信息，并输出修改后的请求信息。arg的格式为："/type0=value0/type1=value1..."，
 # 如果value为空，则表示使用配置文件中指定的默认值，如果value值为"."，则表示该项留空。
 # 其中可识别type有："C"是国家，"ST"是州/省，"L"是位置，"O"是组织（一般写公司名），"OU"是单位（可以写公司的部门名），"CN"是常用名（一般写域名或者主机地址），"emailAddress"是电子邮箱地址。

```

### 1.生成私钥

```bash
openssl genrsa -des3 -out server.key 2048

# 生成带密码的私钥
openssl genrsa -des3 -out server.pwd.key 2048
# 去除私钥中的密码
openssl rsa -in server.pass.key -out server.key
```

### 2.生成CSR(证书签名请求)

```bash
openssl req -new -key server.key -out server.csr -subj "/C=CN/ST=BeiJing/L=BeiJing/O=dev/OU=dev/CN=xxx.com"
```

### 3.生成SSL证书

```bash
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
```

### \*直接生成自签证书

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout /etc/vsftpd/vsftpd.pem -out /etc/vsftpd/vsftpd.pem
```

# openssl升级

```bash
# 待完善
tar -zxvf openssl-1.1.1c.tar.gz
cd openssl-1.1.1c
./config --prefix=/usr/local/openssl   #如果此步骤报错,需要安装perl以及gcc包
make && make install
mv /usr/bin/openssl /usr/bin/openssl.bak
ln -sf /usr/local/openssl/bin/openssl /usr/bin/openssl
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
ldconfig -v                    # 设置生效
```

# keytool

[数字证书管理工具openssl和keytool的区别](https://www.cnblogs.com/zhangshitong/p/9015482.html "数字证书管理工具openssl和keytool的区别")

一句话：keytool没办法签发证书，而openssl能够进行签发和证书链的管理

因此，keytool 签发的所谓证书只是一种 `自签名证书`

**keytool 特点**

既然 keytool 只能自签名，那要他何用？

**keytool 其实是 JDK 提供给我们弄些 JDK 能认识的证书的。**

因此，我们用 keytool 的目的，更多的是在这里：**让Java编写的程序能用上证书**。
