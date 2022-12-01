#middleware/nacos

Nacos定义为一个IDC内部应用组件，并非面向公网环境的产品，建议在内部隔离网络环境中部署，强烈不建议部署在公共网络环境。


*   [官网：https://nacos.io/](https://links.jianshu.com/go?to=https://nacos.io/ "官网：https://nacos.io/")

*   [下载地址：https://github.com/alibaba/nacos/releases](https://links.jianshu.com/go?to=https://github.com/alibaba/nacos/releases "下载地址：https://github.com/alibaba/nacos/releases")

*   解压

*   启动

    ```bash
    cd ~/nacos/bin
    sh startup.sh -m standalone   # 单实例启动

    ```


## 配置文件

```properties
### 默认 Web 上下文路径：
server.servlet.contextPath=/nacos

### 包含消息字段
server.error.include-message=ALWAYS

### 默认 Web 服务器端口：
server.port=8848

### 指定本地服务器的 IP：
# nacos.inetutils.ip-address=

### 是否使用 MySQL 作为数据源：
# spring.datasource.platform=mysql
### 数据库计数：
# db.num=1

### 数据库的连接网址：
#db.url.0=jdbc:mysql://127.0.0.1：3306/nacos？characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC
# db.user.0=nacos
# db.password.0=nacos

### 连接池配置：hikariCP
db.pool.config.connectionTimeout=30000
db.pool.config.validationTimeout=10000
db.pool.config.maximumPoolSize=20
db.pool.config.minimumIdle=2

### 是否启用实例自动过期，类似于实例的健康检查：
#nacos.nameing.expireInstance=true

### 是否打开访问日志：
server.tomcat.accesslog.enabled=true

### 访问日志模式：
server.tomcat.accesslog.pattern=%h %l %u %t “%r” %s %b %D %{User-Agent}i %{Request-Source}i

### 访问日志的目录：
server.tomcat.basedir=file：.

```




## nacos 获取配置时启用权限认证

*   启用 Nacos 的权限认证

    `vim nacos/conf/application.properties`

    ```bash
    ### 
    nacos.core.auth.enabled=true
    ```

*   添加 Nacos 用户

    默认的用户 *nacos* 绑定的角色是 *ROLE\_ADMIN* , 权限比较大, 最好是新增一个只读的用户用来读取对应命名空间(*namespace*)的配置.

    1.  权限控制 -> 用户列表 中新增用户

    2.  权限控制 -> 角色管理 中新增用户对应的角色  一个用户可以绑定多个角色.

    3.  权限控制 -> 权限管理 中新增角色对应的权限  可以设置角色对应的命名空间(页面上名称为资源), 在动作下拉框中指定读写权限(只读\只写\读写).  一个角色可以配置多个权限.

    合理的使用 *namespace* 和 *group* 来隔离配置文件, 再辅以用户的角色、权限控制, 组合的权限策略还是比较灵活的, 应该能满足大多数项目的安全需求.

*   &#x20;*curl* 命令验证一下效果

    ```bash
    curl -XGET 'http://localhost:8101/nacos/v1/cs/configs?dataId=client&group=DEFAULT_GROUP&tenant=jy2v&username=nstc&password=Ninestar123'
    curl -XGET 'http://localhost:8101/nacos/v1/cs/configs?dataId=client&group=DEFAULT_GROUP&tenant=jy2v&username=nacos&password=nacos'

    ```

*   修改 Spring Boot 配置文件

    在 *bootstrap.yml* 中添加 *spring.cloud.nacos.config.username* 和 *spring.cloud.nacos.config.password* 配置项;

    如果不仅使用了配置中心, 还使用了 *Nacos* 的注册中心功能, 那么同时还要配置 *spring.cloud.nacos.discovery.username* 和 *spring.cloud.nacos.discovery.password* 配置项, 而且必须使用默认的 *ROLE\_ADMIN* 角色的用户.

## nacos命令行

```bash
# 创建空间
curl -X POST 'http://192.168.10.135:8101/nacos/v1/console/namespaces' -d 'customNamespaceId=jy2v&namespaceName=jy2v&namespaceDesc=jy2v'

# 发布配置
curl -X POST "http://192.168.10.135:8101/nacos/v1/cs/configs?tenant=jy2v&dataId=client&group=DEFAULT_GROUP&content=user.id=1%0Auser.name=james%0Auser.age=17&type=yaml"
# tenant   空间名
# content  配置内容

# 获取配置
curl -X GET "http://192.168.10.167:8101/nacos/v1/cs/configs?dataId=gds&group=DEFAULT_GROUP&tenant=jy2v"
```

使用python将nacos配置文件转义为url格式，然后通过curl 上传到nacos控制台

```python
#!/bin/python
import sys
import os
import urllib
nacosFilePath='/tmp/nacos'
nacosFiles = os.listdir(nacosFilePath)
for fileName in nacosFiles:
    with open(nacosFilePath + '/' + fileName,'r+w') as f:
        text = f.read()
        urltext = urllib.quote(text.decode(sys.stdin.encoding).encode('utf8'))
        f.seek(0)
        f.write(urltext)
    
-------------------------------------------------------------------------------------------------------------
gener_bs_nacosFiles(){
  if [[ -f ${SUB_SCRIPT}/bs_nacos_alter_mysql.sh ]]; then
    sh ${SUB_SCRIPT}/bs_nacos_alter_mysql.sh
    mkdir -p ${MIC_LOG_PATH}/{appService,bank,account,gateway,gds,listeners,payService,master,internal-bank,cash,derivatives,budget,ecd,custom,tss,task-admin,task-execute}
  python -V
  if [ $? == 0 ];then
mkdir -p /tmp/nacos
cp ${MIC_CONFIG_PATH_MYSQL}/* /tmp/nacos/
sed -i "/^nacosFilePath/cnacosFilePath='/tmp/nacos'" ${SUB_SCRIPT}/setNacosFile.py
/usr/bin/python ${SUB_SCRIPT}/setNacosFile.py
sleep 5
TMP_NACOS_account=`cat /tmp/nacos/account`
TMP_NACOS_appService=`cat /tmp/nacos/appService`
TMP_NACOS_bank=`cat /tmp/nacos/bank`
TMP_NACOS_budget=`cat /tmp/nacos/budget`
TMP_NACOS_cash=`cat /tmp/nacos/cash`
TMP_NACOS_custom=`cat /tmp/nacos/custom`
TMP_NACOS_derivatives=`cat /tmp/nacos/derivatives`
TMP_NACOS_ecd=`cat /tmp/nacos/ecd`
TMP_NACOS_gateway=`cat /tmp/nacos/gateway`
TMP_NACOS_gds=`cat /tmp/nacos/gds`
TMP_NACOS_internalBank=`cat /tmp/nacos/internalBank`
TMP_NACOS_listeners=`cat /tmp/nacos/listeners`
TMP_NACOS_master=`cat /tmp/nacos/master`
TMP_NACOS_payService=`cat /tmp/nacos/payService`
TMP_NACOS_task_admin=`cat /tmp/nacos/task-admin`
TMP_NACOS_task_execute=`cat /tmp/nacos/task-execute`
TMP_NACOS_tss=`cat /tmp/nacos/tss`

# 创建空间
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/console/namespaces" -d "customNamespaceId=${NACOS_SPACE}&namespaceName=${NACOS_SPACE}&namespaceDesc=${NACOS_SPACE}"
# 导入配置
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=account&group=DEFAULT_GROUP&content=${TMP_NACOS_account}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=appService&group=DEFAULT_GROUP&content=${TMP_NACOS_appService}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=bank&group=DEFAULT_GROUP&content=${TMP_NACOS_bank}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=budget&group=DEFAULT_GROUP&content=${TMP_NACOS_budget}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=cash&group=DEFAULT_GROUP&content=${TMP_NACOS_cash}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=custom&group=DEFAULT_GROUP&content=${TMP_NACOS_custom}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=derivatives&group=DEFAULT_GROUP&content=${TMP_NACOS_derivatives}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=ecd&group=DEFAULT_GROUP&content=${TMP_NACOS_ecd}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=gateway&group=DEFAULT_GROUP&content=${TMP_NACOS_gateway}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=gds&group=DEFAULT_GROUP&content=${TMP_NACOS_gds}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=internalBank&group=DEFAULT_GROUP&content=${TMP_NACOS_internalBank}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=listeners&group=DEFAULT_GROUP&content=${TMP_NACOS_listeners}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=master&group=DEFAULT_GROUP&content=${TMP_NACOS_master}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=payService&group=DEFAULT_GROUP&content=${TMP_NACOS_payService}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=task-admin&group=DEFAULT_GROUP&content=${TMP_NACOS_task_admin}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=task-execute&group=DEFAULT_GROUP&content=${TMP_NACOS_task_execute}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=tss&group=DEFAULT_GROUP&content=${TMP_NACOS_tss}"
rm -rf /tmp/nacos
    echo -e "\n\e[1;36m naocs 配置完成 \n \e[0m"
    sleep 2
```