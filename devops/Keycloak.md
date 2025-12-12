Keycloak是一款开源的认证授权平台，在Github上已有9.4k+Star。Keycloak功能众多，可实现用户注册、社会化登录、单点登录、双重认证 、LDAP集成等功能。

## 安装

> 使用Docker搭建Keycloak服务非常简单，两个命令就完事了，我们将采用此种方式。

- 首先下载Keycloak的Docker镜像，注意使用`jboss`的镜像，官方镜像不在DockerHub中；

```
docker pull jboss/keycloak:14.0.0
```

- 使用如下命令运行Keycloak服务：

```
docker run -p 8080:8080 --name keycloak \
-e KEYCLOAK_USER=admin \
-e KEYCLOAK_PASSWORD=admin \
-d jboss/keycloak:14.0.0
```

- 运行成功后可以通过如下地址访问Keycloak服务，点击圈出来的地方可以访问管理控制台，访问地址：http://192.168.7.142:8080


![[devops/assets/c695357f250e3a4afdb8ac170d0a3f44_MD5.png|800]]
## 控制台使用

> 接下来我们来体验下Keycloak的管理控制台，看看这个可视化安全框架有什么神奇的地方。

- 首先输入我们的账号密码`admin:admin`进行登录；

![[devops/assets/c3fc5aa313f13e805b0e68ad9275db46_MD5.png|800]]

- 登录成功后进入管理控制台，我们可以发现Keycloak是英文界面，良心的是它还支持多国语言（包括中文），只要将`Themes->Default Locale`改为`zh-CN`即可切换为中文；

![[devops/assets/f29f70db0f023fbe80c7b2e08c2c453e_MD5.png|800]]

- 修改完成后保存并刷新页面，Keycloak控制台就变成中文界面了；

![[devops/assets/30c053dc90951d253ab5bf1843a48b99_MD5.png|800]]

- Keycloak非常良心的给很多属性都添加了解释，而且还是中文的，基本看下解释就可以知道如何使用了；

![[devops/assets/380190fe8df5b5410007e320b4983052_MD5.png|800]]

- 在我们开始使用Keycloak保护应用安全之前，我们得先创建一个领域（realm），领域相当于租户的概念，不同租户之间数据相互隔离，这里我们创建一个`macrozheng`的领域；

![[devops/assets/013e63da27886f454c08867caa440e93_MD5.png|800]]

- 接下来我们可以在`macrozheng`领域中去创建用户，创建一个`macro`用户；

![[devops/assets/7d4714aa49ba533b895acd313a5c6b33_MD5.png|800]]

- 之后我们编辑用户的信息，在`凭据`下设置密码；

![[devops/assets/0f3b236d577d208d07eb78cb94095acf_MD5.png|800]]

- 创建完用户之后，就可以登录了，用户和管理员的登录地址并不相同，我们可以在`客户端`页面中查看到地址；

![[devops/assets/3d5394b6eed2d694ecc1671f49fe9c7e_MD5.png|800]]

- 访问该地址后即可登录，访问地址：http://192.168.7.142:8080/auth/realms/macrozheng/account

![[devops/assets/295b823b1d6c6d2202ecab8500db49b3_MD5.png|800]]

- 用户登录成功后即可查看并修改个人信息。

![[devops/assets/5f6407bd3a96788a6869fd15f40d1b51_MD5.png|800]]
## 结合Oauth2使用

> OAuth 2.0是用于授权的行业标准协议，在[《Spring Cloud Security：Oauth2使用入门》](https://mp.weixin.qq.com/s/FF2nioDuyvcr6mvRa8ZXWw)一文中我们详细介绍了Oauth2的使用，当然Keycloak也是支持的，下面我们通过调用接口的方式来体验下。

### 两种常用的授权模式

> 我们再回顾下两种常用的Oauth2授权模式。
#### 授权码模式

![[devops/assets/f8fa4c3838aa4fdc3e2a7f76e39717e8_MD5.png]]

- (A)客户端将用户导向认证服务器；
- (B)用户在认证服务器进行登录并授权；
- (C)认证服务器返回授权码给客户端；
- (D)客户端通过授权码和跳转地址向认证服务器获取访问令牌；
- (E)认证服务器发放访问令牌（有需要带上刷新令牌）。

#### 密码模式

![[devops/assets/346afd9fe62451e0340ec0c9057267ae_MD5.png]]

- (A)客户端从用户获取用户名和密码；
- (B)客户端通过用户的用户名和密码访问认证服务器；
- (C)认证服务器返回访问令牌（有需要带上刷新令牌）。

### 密码模式体验

- 首先需要在Keycloak中创建客户端`mall-tiny-keycloak`；

![[devops/assets/9c18f14b4618a3c094b4285e70763072_MD5.png|800]]

- 然后创建一个角色`mall-tiny`；

![[devops/assets/fd085192ead066b5094c8f86f21df799_MD5.png|800]]

- 然后将角色分配给`macro`用户；

![[devops/assets/c559c6daadcc2f925f72be8078f59984_MD5.png|800]]

- 一切准备就绪，在Postman中使用Oauth2的方式调用接口就可以获取到Token了，获取token的地址：http://192.168.7.142:8080/auth/realms/macrozheng/protocol/openid-connect/token

![[devops/assets/76c9f8f6dd772529c6f1a330cae4ef30_MD5.png|800]]

## 结合SpringBoot使用

> 接下来我们体验下使用Keycloak保护SpringBoot应用的安全。由于Keycloak原生支持SpringBoot，所以使用起来还是很简单的。

- 由于我们的SpringBoot应用将运行在`localhost:8088`上面，我们需要对Keycloak的客户端的`有效的重定向URI`进行配置；

![[devops/assets/9fc7f6665bff0e8e45912c209211958f_MD5.png|800]]

- 接下来我们需要修改应用的`pom.xml`，集成Keycloak；

```
<!--集成Keycloak-->
<dependency>
    <groupId>org.keycloak</groupId>
    <artifactId>keycloak-spring-boot-starter</artifactId>
    <version>14.0.0</version>
</dependency>
```


- 再修改应用的配置文件`application.yml`，具体属性参考注释即可，需要注意的是给路径绑定好可以访问的角色；

```
# Keycloak相关配置
keycloak:
  # 设置客户端所在领域
  realm: macrozheng
  # 设置Keycloak认证服务访问路径
  auth-server-url: http://192.168.7.142:8080/auth
  # 设置客户端ID
  resource: mall-tiny-keycloak
  # 设置为公开客户端，不需要秘钥即可访问
  public-client: true
  # 配置角色与可访问路径的对应关系
  security-constraints:
    - auth-roles:
        - mall-tiny
      security-collections:
        - patterns:
            - '/brand/*'
            - '/swagger-ui/*'
```


- 接下来访问下应用的Swagger页面，访问的时候会跳转到Keycloak的控制台去登录，访问地址：http://localhost:8088/swagger-ui/

![[devops/assets/646478dfd1bdae35de698e3ed2637127_MD5.png|800]]

- 登录成功后，即可访问被保护的Swagger页面和API接口，一个很标准的Oauth2的授权码模式，流程参考授权码模式的说明即可。

![[devops/assets/c3e8a3e19c27a4532883062c97852a16_MD5.png|800]]
## 总结

Keycloak是一款非常不错的可视化安全框架，让我们无需搭建认证服务即可完成认证和授权功能。原生支持SpringBoot，基本无需修改代码即可集成，不愧为现代化的安全框架！

