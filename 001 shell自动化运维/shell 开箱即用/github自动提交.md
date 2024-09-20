# github自动提交

　　‍

```bash
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

/usr/bin/expect <<-EOF
set timeout 20
spawn git push origin master
expect "Username for 'https://github.com': " 
send "x14k3\r"
expect "Password for 'https://x14k3@github.com': "
send "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\r"
# 执行过程显示出来
set results $expect_out(buffer)
expect eof
EOF
```
