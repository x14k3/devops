

# 一、作用：

- 用户管理：验证用户身份信息合法性
- 认证服务：提供了其余所有组件的认证信息/令牌的管理，创建，修改等等，使用MySQL作为统一的数据库。
- Keystone是Openstack用来进行身份验证(authN)及高级授权(authZ)的身份识别服务，目前支持基于口令的authN和用户服务授权。

# 二、概念：

```text
Project        # 个人或服务所拥有的资源集合。在一个Project(Tenant)中可以包含多个User，每一个User都会根据权限的划分来使用Project(Tenant)中的资源。
User           # 访问OpenStack的对象。用户拥有证书（credentials），且可能分配给一个或多个租户。经过验证后，会为每个单独的租户提供一个特定的令牌。
Credentials    # 确认用户身份的凭证。可以是用户名和密码、用户名和API Key和Token。
Token          # 一个字符串表示，作为访问资源的令牌。Token包含了在指定范围和有效时间内可以被访问的资源，具有时效性。
Role           # 用于划分权限。可以通过给User指定Role，使User获得Role对应的操作权限。Keystone返回给User的Token包含了Role列表，被访问的Services会判断访问它的User和User提供的Token中所包含的Role。
Policy         # 用来控制User对Project中资源(包括Services)的操作权限。对于Keystone service来说，Policy就是一个JSON文件，默认是/etc/keystone/policy.json。
Authentication # 确定用户身份的过程
Service        # Openstack中运行的组件服务
Endpoint       # 通过网络来访问和定位某个Openstack service的地址，通常是一个URL。
```

# 三、架构

## 1.工作原理

![](image-20221127212632051-20230610173810-sauixva.png)

1.Keystone根据User提供的Credentials从SQL Database中进行身份和权限校验，验证通过返回User一个Token和Endpoint 。

2.首先User向Keystone提供自己的Credentials(凭证：用于确认用户身份的数据，EG. username/password)。

3.User得到授权(Token)和Endpoint后根据自身权限操作OpenStack的资源

## 2.在各个组件中的作用

![](image-20221127212639207-20230610173810-jc7sm9y.png)

## 3.常用操作

![](image-20221127212645236-20230610173810-rtwss6n.png)

**openstack endpoint类型**

Endpoint是一个可以通过网络来访问和定位某个Openstack service的地址，通常是一个URL。

openstack endpoint有三种类型admin，internal，public。

```bash
admin      # 给admin用户使用
internal   # 内部使用， OpenStack内部服务使用来跟别的服务通信
public     # 互联网用户可以访问的地址
```
