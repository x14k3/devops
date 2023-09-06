# kylin apt

‍

软件源使用方法

在系统的/etc/apt/sources.list文件中，根据不同版本填入以下内容

```sql
#4.0.2桌面版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 4.0.2-desktop main restricted universe multiverse

#4.0.2-sp1桌面版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 4.0.2sp1-desktop main restricted universe multiverse

#4.0.2-sp2桌面版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 4.0.2sp2-desktop main restricted universe multiverse

#4.0.2服务器版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 4.0.2-server main restricted universe multiverse

#4.0.2-sp1服务器版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 4.0.2sp1-server main restricted universe multiverse

#4.0.2-sp2服务器版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 4.0.2sp2-server main restricted universe multiverse

#4.0.2-sp2 FT2000+服务器版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 4.0.2sp2-server-ft2000 main restricted universe multiverse

#4.0.2-sp3桌面版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 4.0.2sp3-desktop main restricted universe multiverse

#4.0.2-sp3服务器版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 4.0.2sp3-server main restricted universe multiverse

#4.0.2-sp4桌面版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 4.0.2sp4 main restricted universe multiverse

#V10版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 10.0 main restricted universe multiverse

#V10 SP1版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 10.1 main restricted universe multiverse

#V10 SP1 2107版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 10.1-2107-updates main restricted universe multiverse

#V10 SP1 2203版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 10.1-2203-updates main restricted universe multiverse

#V10 SP1 2203 HWE版本:
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 10.1-2203-hwe-updates main restricted universe multiverse\
```

更新apt源

```sql
apt update
```
