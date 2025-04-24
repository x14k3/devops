# Tomcat 集群负载均衡

对于高访问量、高并发量的网站或web应用来说，目前最常见的解决方案应该就是利用负载均衡进行server集群，例如比较流行的nginx+redis+tomcat。集群之后比如我们有N个Tomcat，用户在访问我们的网站时有可能第一次请求分发到tomcat1下，而第二次请求又分发到了tomcat2下，有过web开发经验的朋友都知道这时session不一致会导致怎样的后果，所以我们需要解决一下多个tomcat之间session共享的问题。

**Tomcat集群session同步方案有以下几种方式：**

1. tomcat自带的集群配置【Tomcat Cluster】：只能支持小规模集群；
2. 利用nginx的基于访问ip的hash路由策略，保证访问的ip始终被路由到同一个tomcat上，这个配置更简单。可以解决session(并不是共享session解决)的问题! 并且如果应用是某一个局域网大量用户同时登录，这样负载均衡就没什么作用了；
3. 利用memcached存储session，并把多个tomcat的session集中管理，从而实现Session共享；
4. 采用Redis作为session存储方案：支持大规模集群，目前不支持tomcat8以上版本；
5. 利用filter方法实现。这种方法比较推荐，因为它的服务器使用范围比较多，不仅限于tomcat ，而且实现的原理比较简单容易控制。
6. 利用terracotta服务器共享session。这种方式配置比较复杂。

## 基于Tomcat Cluster的session共享

两台服务器同时安装jdk和tomcat

1. *[jdk](../jdk/jdk.md)*
2. *tomcat 安装*

下载地址：https://tomcat.apache.org/

3. 配置tomcat发布器的端口

```xml
    <!--Engine name="Catalina" defaultHost="localhost"-->
    <Engine name="Catalina" defaultHost="localhost" jvmRoute="tomcat1">
    <!--
    <Engine name="Catalina" defaultHost="localhost" jvmRoute="tomcat2">
    -->
```

4. *在tomcat的server.xml配置参数据中增加session同步复制的设置*

`vim server.xml`   增加下列代码，增加Engine后面的cluster中去

```xml
<!--
<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"/>
-->
<!--下面的代码是实现session复制功能-->
        <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"
                 channelSendOptions="8">

          <Manager className="org.apache.catalina.ha.session.DeltaManager"
                   expireSessionsOnShutdown="false"
                   notifyListenersOnReplication="true"/>

          <Channel className="org.apache.catalina.tribes.group.GroupChannel">
            <Membership className="org.apache.catalina.tribes.membership.McastService"
                        address="228.0.0.4"
                        port="45564"
                        frequency="500"
                        dropTime="3000"/>
            <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                      address="auto"
                      port="4000"
                      autoBind="100"
                      selectorTimeout="5000"
                      maxThreads="6"/>

            <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
              <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/>
            </Sender>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatchInterceptor"/>
          </Channel>

          <Valve className="org.apache.catalina.ha.tcp.ReplicationValve"
                 filter=""/>
          <Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve"/>

          <Deployer className="org.apache.catalina.ha.deploy.FarmWarDeployer"
                    tempDir="/tmp/war-temp/"
                    deployDir="/tmp/war-deploy/"
                    watchDir="/tmp/war-listen/"
                    watchEnabled="false"/>

          <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/>
        </Cluster>
```

5. *同时需要修改tomcat的web.xml配置参数才能真正实现session同步复制的设置*

`vim web.xml`

```xml
<!--....--!>
    <welcome-file-list>
        <welcome-file>index.html</welcome-file>
        <welcome-file>index.htm</welcome-file>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>
<distributable />   <!--在倒数第二行增加这个代码才能实现session同步复制功能-->
</web-app>
```

5. *启动tomcat*

## 利用filter方法实现session共享
