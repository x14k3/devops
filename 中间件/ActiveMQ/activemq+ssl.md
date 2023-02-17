#middleware/activemq 

### 1、技术背景

SSL（Secure Sockets Layer 安全套接层）及其继任者TLS（TransportLayer Security传输层安全）是为网络通信提供安全及数据完整性的一种安全协议。TLS与SSL在传输层对网络连接进行加密，用以保障在Internet上数据传输之安全，利用数据加密(Encryption)技术，可确保数据在网络上之传输过程中不会被截取及窃听。JSSE（Java Security Socket Extension）解决方案由SUN推出，实现了SSL和TLS协议。在JSSE中包含了数据加密，服务器验证，消息完整性和客户端验证等技术。通过使用JSSE，开发人员可以在客户机和服务器之间通过TCP/IP协议安全地传输数据。

**SSL消息认证方式有两种：单向认证、双向认证。此配置文档使用双向认证的方式。**

为了实现消息认证，使用Java自带的 keytool 命令可以生成以上密钥及证书文件，首先生成密钥及证书信任文件。
==Server需要：==
- 1）KeyStore：保存服务端的私钥；
- 2）Trust KeyStore：保存客户端的授权证书

==Client需要：==
- 1）KeyStore：保存客户端的私钥；
- 2）Trust KeyStore：保存服务端的授权证书


### 2、生成证书

单向认证，在服务端生成证书

```bash
# 1.生成服务端私钥，并导入服务端KeyStore文件中，此操作生成broker.ks文件，保存服务端私钥，供服务端使用。
keytool -genkey -alias broker -keyalg RSA -keystore broker.ks
# 注意：需要输入口令，该口令为keystore的密令（口令1）。

# 2.使用私钥导出服务端证书， 此操作生成 broker_cert文件，该文件为服务端的证书。
keytool -export -alias broker -keystore broker.ks -file broker_cert
# 注意：【此处需要输入服务端密钥库口令】*(…口令1…)

# 3.导入服务端证书导入到客户端的Trust KeyStore中，此操作生成 client.ts文件，保存服务端证书，供客户端使用
keytool -import -alias broker -keystore client.ts -file broker_cert
# 注意：【此处需要输入密钥库口令】(…口令2…)
```



如果使用双向认证，则继续下面的操作，在客户端生成证书，并导入到服务端的Trust KeyStore 中

```bash
# 1.生成客户端私钥，并且导入到客户端KeyStore文件中， 此操作生成 client.ks文件，保存客户端私钥，供客户端使用。
keytool -genkey -alias client -keyalg RSA -keystore client.ks
# 输入密钥库口令: (…口令3…)

# 2.使用私钥导出客户端证书，此操作生成 client_cert文件，该文件为客户端的证书。
keytool -export -alias client -keystore client.ks -file client_cert
# 注意：【此处需要输入客户端密钥库口令】(…口令3…)

# 3.导入客户端证书导入到服务端的Trust KeyStore中，此操作生成 broker.ts文件，保存客户端证书，供服务端使用
keytool -import -alias client -keystore broker.ts -file client_cert
# 注意：【此处需要输入密钥库口令】(…口令4…)
```



### 3、服务端（ActiveMQ）配置

1、 将生成的文件 broker.ks、broker.ts复制到 \${activemq.base}/conf 目录下。

```bash
cp broker.ks broker.ts  /data/activeMQ/activemq-10098/conf
```

2、 打开 activemq.xml 文件，修改 transportConnectors节点内容为 SSL

```xml
# 修改前
<transportConnectors>
  <transportConnector name="openwire" uri="tcp://0.0.0.0:3002"/> 
</transportConnectors>

# 修改后
<sslContext> 
  <sslContext keyStore="file:${activemq.base}/conf/broker.ks" 
              keyStorePassword="口令1" 
              trustStore="file:${activemq.base}/conf/broker.ts" 
              trustStorePassword="口令4"/> 
  </sslContext> 
<transportConnectors> 
  <transportConnector name="nio+ssl" uri="nio+ssl://0.0.0.0:3002?needClientAuth=true" />   <!-- 使用 needClientAuth=true 开启双向认证-->
</transportConnectors>

```


### 4、客户端（Tomcat）配置

1、将生成的文件client.ts 、client.ks 复制到客户端主机

2、增加Tomcat启动选项

`vim ~/tomcat/bin/catalina.sh`

```sh
# 在echo Using CATALINA_BASE: "%CATALINA_BASE%" 一行前加上: 
set JAVA_OPTS=%JAVA_OPTS% -Djavax.net.ssl.keyStore="【client.ks的路径】" -Djavax.net.ssl.keyStorePassword="【口令3】"-Djavax.net.ssl.trustStore="【client.ts的路径】" -Djavax.net.ssl.trustStorePassword="【口令2】"

```



3、打开 context.xml 文件，修改 ActiveMQ 对应的Resource 节点配置

`vim  ~/tomcat/conf/context.xml`

```xml
<!--------------------- 修改前：----------------------->
<Resourceauth="Container" brokerName="localhostISUCONSOLE" 
brokerURL="failover://(tcp://localhost:3002)"
description="JMSConnection Factory"
factory="org.apache.activemq.jndi.JNDIReferenceFactory"
name="jms/consoleConnectionFactory"
type="org.apache.activemq.ActiveMQConnectionFactory"

useEmbeddedBroker="false"/>

<!--------------------- 修改后：----------------------->

<Resourceauth="Container" brokerName="localhostISU"
brokerURL="failover://(**ssl://localhost:3002**)"
description="JMSConnection Factory"
factory="org.apache.activemq.jndi.JNDIReferenceFactory"
name="jms/ConnectionFactory"
type="**org.apache.activemq.ActiveMQSslConnectionFactory**"
useEmbeddedBroker="false"/>

```




