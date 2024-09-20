# jar包服务启动停止shell脚本

　　‍

```bash
#!/bin/bash

# jdk
jdk="jdk路径"

# 项目名
pjname="xxxxxx"

# jar包目录
dir="/java/$pjname"

# 多个jar包名称
jar1="xxx"
jar2="xxx"
jar3="xxx"
jar4="xxx"
alljar="$jar1 $jar2 $jar3 $jar4"

# 成功
success(){
    echo -e "\033[32m[$pjname-$1]服务$2\033[0m"
}

# 失败
fail(){
    echo -e "\033[31m[$pjname-$1]服务$2\033[0m"
}

# 警告
waring(){
    echo -e "\033[33m  请输入正确的要${1}的服务名称：[ $jar1 | $jar2 | $jar3 | $jar4 ]\n  如果要${1}所有服务请使用: all\033[0m"
}

# 提示
tips(){
    echo -e "\033[36m请输入正确的参数：[ start | stop ]\033[0m"
}

# 服务检查
started(){
    jps|grep $pjname-$1 && success $1 已在运行中 && $2
}
verifysa(){
    started $1 continue
}
verifys(){
    started $1 exit
}

# 服务检查
killed(){
    ps -ef |grep -v "grep"|grep "$pjname-$1"|awk '{print $2}'|xargs kill -9 >/dev/null 2>&1 && success $1 停止成功|| fail $1 未启动 && $2
}
verifyt(){
    killed $1 exit
}
verifyta(){
    killed $1 continue
}


# 启动后验证
verify() {
    jps|grep $pjname-$1 && success $1 ${2}成功 || fail $1 ${2}失败
}

# 启动
starting(){
    nohup java -Xms512m -Xmx4096m -XX:MaxNewSize=256m -XX:MaxPermSize=512m -Djava.security.egd=file:/dev/./urandom -Dspring.cloud.nacos.config.server-addr=${NACOS_URL} -Dspring.cloud.nacos.config.namespace=${NACOS_NAMESPACE} -jar ${APP_PATH}/$APP_NAME 2>&1 | usr/local/sbin/cronolog ${LOGPATH}/${APP_NAME}.${TODAY}.out &
    verify $1 启动
}

# 停止
stoping(){
    ps -ef |grep -v "grep"|grep "$pjname-$1"|awk '{print $2}'|xargs kill -9 >/dev/null 2>&1
    verify $1 停止
}

# 执行
case $1 in
    start)
        if [[ $2 = $jar1 || $2 = $jar2 || $2 = $jar3 || $2 = $jar4 ]];then
            verifys $2
            starting $2
        elif [[ $2 = all ]];then
            for i in $alljar;do verifysa $i;starting $i;done
        else
            waring 启动
        fi
    ;;
  
    stop)
        if [[ $2 = $jar1 || $2 = $jar2 || $2 = $jar3 || $2 = $jar4 ]]
        then
            verifyt $2
            stoping $2
        elif [[ $2 = all ]];then
            for i in $alljar;do verifyta $i;stoping $i;done
        else
            waring 停止
        fi
    ;;
    *)
        tips
    ;;
esac
```
