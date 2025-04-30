# jdk 部署

```bash
wget https://mirrors.huaweicloud.com/java/jdk/8u192-b12/jdk-8u192-linux-x64.tar.gz
mkdir -p /usr/local/java
tar -zxf jdk-8u192-linux-x64.tar.gz -C /usr/local/java
#配置环境变量
cat <<EOF>> /etc/profile
export JAVA_HOME=/usr/local/java/jdk1.8.0_192
export JRE_HOME=\${JAVA_HOME}/jre
export CLASSPATH=\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=$PATH:\$JAVA_HOME/bin
EOF

source /etc/profile
#验证JDK
java -version
```
