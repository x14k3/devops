# WinUbuntu + VScode下Git的配置与使用 

## Window10环境下配置使用git

### 1.Git初始化及本地仓库配置

　　1.在官网上下载并安装Git. 本教程的安装路径为F:\\Github
2.在桌面或者任意目录下右键打开git bash (或者直接打开CMD命令行). 键入命令(以下所有命令行都采用双引号括起来做提示):
" git config --global user.name "FuNian788" "
" git config --global user.email "xxx.com" "
(此处通过git config user.name / git config user.email等命令来查询已经配置的用户名和邮箱)
3.在本地的现有文件夹中 通过 git init 命令初始化本地仓库
4.通过 " git add . " 命令暂存所有更改的文件
5.通过 " git commit -m"备注信息" "命令提交当前文件夹内所有文件到版本库
6.通过 " ssh-keygen -t rsa (-C) "email.com" " 命令生成SSH私钥和公钥(通过三次回车跳过提示信息)

### 2.Github配置

　　7.在"C:\\Users\\username.ssh"文件夹内打开id\_rsa.pub公匙文件.复制内容
8.登录Github.在 用户头像 > Settings > SSH and GPG keys > New SSH key > Key 中粘贴刚才的公钥内容
9.在Github上建立远程仓库.单击仓库内"Clone or download"按钮.选择"Use SSH"切换到SSH模式并复制远程仓库地址

### 3.配置Git 关联本地仓库和远程仓库

　　10.在本地仓库文件夹下的Git Bash内通过 " git remote add 远程仓库名称 远程仓库SSH地址 " 命令将本地仓库与远程仓库建立连接
通过" git remote "命令查看已经建立关联的远程仓库名称
通过" git remote -v"命令查看已经建立关联的远程仓库详细信息
11.通过" ssh -T git@github.com " 命令测试远程仓库的网络连接情况
12.通过" git pull 远程仓库名 master --allow-unrelated-histories "命令合并远程仓库到本地仓库
13.通过" git push 远程仓库名 master " 将本地仓库的内容推送到远程仓库

## Ubuntu环境下配置使用git

　　1.在ubuntu环境下下载Git.
2.接下来的步骤同上述2-13条.但需要注意的是.在12条处.笔者电脑会报错"unknown option'allow-unrelated-histories'".实践中通过重新建仓及去掉这句话来实现Git的正常运行.

### Congratulations！如果以上步骤尝试成功，就可以在VScode中快乐使用Git了！

### Visual Studio Code下Git图形界面使用方法

　　1.通过Visual Studio Code对本地仓库的文件进行修改/增添/删除
2.在系统菜单中执行"暂存所有更改"命令暂存文件
在系统菜单中执行"全部提交"命令提交到本地仓库 提交的同时输入备注信息
3.在系统菜单中执行"推送到"命令选择推送的远程仓库
4.在系统菜单中执行"拉取自.."命令选择将远程仓库内容下载到本地仓库中

### 以下操作经验证 不需要进行

　　1.计算机 > 属性 > 高级系统设置 > 环境变量 > 系统变量下的Path > 编辑
新建并添加Git的cmd路径和bin路径. (如F:\\Github\\Git\\bin & F:\\Github\\Git\\cmd)
2.打开visual studio code并在 文件 > 首选项 > 设置中添加 "git.path"键.值为Git目录下的cmd下的git.exe文件 (如："git.path":"F:\\Github\\Git\\cmd\\git.exe")

　　‍
