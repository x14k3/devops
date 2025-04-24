# github自动提交

```bash
git remote -v
----------------------------------------------------
git	https://github.com/x14k3/devops.git (fetch)
git	https://github.com/x14k3/devops.git (push)

git config --list
----------------------------------------------------
user.email=doshell@qq.com
user.name=x14k3
https.proxy=https://127.0.0.1:10809
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
remote.git.url=https://github.com/x14k3/devops.git
remote.git.fetch=+refs/heads/*:refs/remotes/git/*
```

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
if [[ ! -f ${CWD}/devops.md.zip ]];then
        echo -e "\033[36m ${CWD}/devops.md.zip does not exist! \033[0m"
        exit 1
fi
rm ${CWD}/devops/0* -rf
unzip -od ${CWD}/devops ${CWD}/devops.md.zip
mv ${CWD}/devops.md.zip /tmp/devops.md.zip-${TODAY}

cd ${CWD}/devops
git add .
git commit -m "update"

/usr/bin/expect <<-EOF
set timeout 20
spawn git push git master
expect "Username for 'https://github.com': " 
send "x14k3\r"
expect "Password for 'https://x14k3@github.com': "
send "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\r"
# 执行过程显示出来
set results $expect_out(buffer)
expect eof
EOF
```
