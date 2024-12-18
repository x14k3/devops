# CentOS7 升级 Glibc 2.17 到2.28

　　在手动升级 alist 从 3.2.0 版本到 3.6.0 版本的时候，发现环境中现有的 Glibc 版本已经无法满足alist的要求了，遂升级一波，记录一下。

```
./alist: /lib64/libc.so.6: version `GLIBC_2.28' not found (required by ./alist)
```

---

　　‍

　　默认的GCC 版本无法无法编译 Glibc 2.28。 安装GLIBC所需的依赖，该版本需要 GCC 4.9 以上 及 make 4.0 以上。 GCC 11.2版本太新，无法与Glibc 2.28兼容。

　　安装gcc-8.2.0所依赖的环境

```
yum install bison -y
yum -y install wget bzip2 gcc gcc-c++ glibc-headers
```

　　升级GNU Make

```
wget http://ftp.gnu.org/gnu/make/make-4.2.1.tar.gz
tar -zxvf make-4.2.1.tar.gz
cd make-4.2.1
mkdir build
cd build
../configure --prefix=/usr/local/make &amp;&amp; make &amp;&amp; make install
export PATH=/usr/local/make/bin:$PATH
ln -s /usr/local/make/bin/make /usr/local/make/bin/gmake
make -v
```

　　升级GCC

```
wget http://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz
# 腾讯软件源 https://mirrors.cloud.tencent.com/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz
tar -zxvf gcc-11.2.0.tar.gz
yum -y install bzip2 #已安装可以跳过这一步
# 中标麒麟系统需要以下依赖
# yum -y install gmp mpfr mpc isl bzip2
cd gcc-11.2.0
./contrib/download_prerequisites
mkdir build
cd build/
../configure -enable-checking=release -enable-languages=c,c++ -disable-multilib
# --prefix=/usr/local 配置安装目录
#–enable-languages表示你要让你的gcc支持那些语言，
#–disable-multilib不生成编译为其他平台可执行代码的交叉编译器。
#–disable-checking生成的编译器在编译过程中不做额外检查，
#也可以使用*–enable-checking=xxx*来增加一些检查

# 编译，这一步需要时间非常久 可以使用 make -j 4 让make最多运行四个编译命令同时运行，加快编译速度（建议不要超过CPU核心数量的2倍）
make
# 删除旧版本
yum -y remove gcc g++
# 安装
make install
# 验证
gcc -v
 
Using built-in specs.
COLLECT_GCC=/usr/local/bin/gcc
COLLECT_LTO_WRAPPER=/usr/local/libexec/gcc/x86_64-pc-linux-gnu/11.2.0/lto-wrapper
Target: x86_64-pc-linux-gnu
Configured with: ../configure -enable-checking=release -enable-languages=c,c++ -disable-multilib
Thread model: posix
Supported LTO compression algorithms: zlib
gcc version 11.2.0 (GCC)
 
验证：gcc -v；或者g++ -v，如果显示的gcc版本仍是以前的版本，就需要重启系统；
或者可以查看gcc的安装位置：which gcc；
然后在查看版本 /usr/local/bin/gcc -v
确定以及配置成功后可以将原先的版本删除

#配置新版本全局可用
ln -s /usr/local/bin/gcc /usr/bin/gcc
ln -s /usr/local/bin/g++ /usr/bin/g++

#更新动态库
#查看当前的动态库
strings /usr/lib64/libstdc++.so.6 | grep CXXABI
rm -f /usr/lib64/libstdc++.so.6
ln -s /usr/local/lib64/libstdc++.so.6.0.29 /usr/lib64/libstdc++.so.6
#查看更新后的动态库
strings /usr/lib64/libstdc++.so.6 | grep CXXABI
# 安装后的动态库会位于/usr/local/lib64目录下，
#其他版本在该目录下寻找对应的动态库libstdc++.so.6.X.XX
```

　　下载、编译安装 Glibc

```
wget https://ftp.gnu.org/gnu/glibc/glibc-2.28.tar.xz
tar -xvf glibc-2.28.tar
cd glibc-2.28
mkdir build
cd build
../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin
make -j4
make install
```

　　查询支持的 Glibc

```
strings /lib64/libc.so.6 | grep GLIBC
```
