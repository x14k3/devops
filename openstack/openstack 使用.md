

# 1.Keystone

```bash
# 1.创建用户
openstack user create [--domain <xx>] [--password <xx>] [--email <xx>] <name>
# --domain : 指定域名
# --password : 指定密码
# --email : 指定email地址
# name：用户名
#[--enable 或 --disable]：默认启用，即--enable

# 2.创建项目（租户）
openstack project create [--domain <xx>] [--description <xx>]  <project name>
# <peoject name> ： 代表新建项目名
# <description> : 代表项目描述名
#[--enable | --disable]：默认启用，即--enable

# 3.创建角色
openstack role create <name>

# 4.绑定用户和项目权限
openstack role add --user <xx> --project <xx> <role name>

# 5.用户列表查询
openstack user list

# 6.查询用户详细信息、状态等
openstack user show ID/NAME

# 7.项目列表查询
openstack project list

# 8.查看项目详细信息
openstack project show ID/NAME

# 9.角色列表查询(权限查询)
openstack role list
 
# 10.查看角色详细信息
openstack role show ID/NAME

# 11.创建域
openstack domain create --description "Test Domain" test

# 12.查看所有域
openstack domain list

# 13.删除某角色
openstack role delete 角色名\ID

# 14.删除某用户
openstack user delete 用户名\ID

# 15.删除某项目
openstack project delete 项目名\ID

# 16.删除域
openstack domain delete test

# 17.删除服务
openstack service delete 服务名\服务ID

# 18.删除某用户的某角色
openstack role remove --project 项目名\ID --user 用户名\ID 角色名\ID

# 19.为组件创建服务实体
openstack service create --name 服务名 --description "xxx" 类型
```

# 2.Glance

```bash
# 1.上传镜像
glance image-create --name 'test' --file test.img --disk-format qocw2 --container-format bare --progress 
 # --disk-format：硬盘格式化为想要的格式
 # --container-format： 容器格式化为想要的格式
 
# 2.查看镜像列表
glance image-list
# 3.查看镜像详细信息
glance image-show ID
# 4.删除镜像
glance image-delete ID

```

# 3.Nova

```bash
```
