# git

## git 服务端部署

或者参考gitlab部署

```bash
yum install git-core
#为 Git 创建一个用户
 useradd -d /home/git git
echo "Ninestar123" | passwd --stdin git

# 为了容易的访问服务器，我们设置一个免密 ssh 登录。首先在你本地电脑上创建一个 ssh 密钥：
ssh-keygen -t rsa -b 1024
# 现在您必须将这些密钥复制到服务器上，以便两台机器可以相互通信。在本地机器上运行以下命令：
cat ~/.ssh/id_rsa.pub | ssh git@remote-server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
# 现在，用 ssh 登录进服务器并为 Git 创建一个项目路径。你可以为你的仓库设置一个你想要的目录。
mkdir   /home/git/project-1.git
# 初始化
cd  /home/git/project-1.git
git init --bare

==============================================
# 现在我们需要在本地机器上新建一个基于 Git 版本控制仓库：
mkdir -p /data/git/project.local
cd /data/git/project.local
# 现在在该目录中创建项目所需的文件。留在这个目录并启动 git：
git init
# 把所有文件添加到本地仓库中：
git add .
# 现在，每次添加文件或进行更改时，都必须运行上面的 add 命令。 您还需要为每个文件更改都写入提交消息。提交消息基本上说明了我们所做的更改。
git commit -m "message"  -a
#在这种情况下，我有一个名为 GoT（《权力的游戏》的点评）的文件，并且我做了一些更改，所以当我运行命令时，它指定对文件进行更改。 在上面的命令中 -a 选项意味着提交仓库中的所有文件。 如果您只更改了一个，则可以指定该文件的名称而不是使用 -a。
git commit -m "message"  GoT.txt
# 到现在为止，我们一直在本地服务器上工作。添加远程仓库，以便其他人通过互联网进行协作。
git remote add origin ssh://git@remote-server/home/git/project-1.git
git remote add origin https://github.com/x14k3/devops.git
# 现在，您可以使用 pull 或 push 选项在服务器和本地计算机之间推送或拉取：
git push origin master

======================================================
# 如果有其他团队成员想要使用该项目，则需要将远程服务器上的仓库克隆到其本地计算机上：
git clone https://github.com/x14k3/devops
# 现在他们可以编辑文件，写入提交更改信息，然后将它们推送到服务器：
git commit -m 'corrections in GoT.txt story' -a
# 然后推送改变：
git push origin master

```

‍

## git 常用命令

### 0. 配置

Git的设置文件为`.gitconfig`​，它可以在用户主目录下（全局配置），也可以在项目目录下（项目配置）。

```bash
# 显示当前的Git配置
git config --list

# 编辑Git配置文件
git config -e [--global]
# 设置提交代码时的用户信息
git config [--global] user.name "[name]"
git config [--global] user.email "[email address]"

```

‍

### 1. 获取与创建项目

> **简而言之**，用 `git init`​ 来在目录中创建新的 Git 仓库。使用 `git clone`​ 拷贝一个 Git 仓库到本地，让自己能够查看该项目，或者进行修改。

```bash
# 新建一个目录，将其初始化为Git代码库; 你可以在任何时候、任何目录中这么做，完全是本地化的。
git init [project-name] 
# 复制一个 Git 仓库;复制该项目的全部记录，让你本地拥有这些。并且该操作将拷贝该项目的主分支， 使你能够查看代码，或编辑、修改。
git clone git://github.com/schacon/simplegit.git
```

‍

### 2. 基本的快照

> **简而言之**，使用 `git add`​ 添加需要追踪的新文件和待提交的更改，然后使用 `git status`​ 和 `git diff`​ 查看有何改动，最后用 `git commit`​ 将你的快照记录。这就是你要用的基本流程，绝大部分时候都是这样的。执行 `git rm`​ 来删除 Git 追踪的文件。它还会删除你的工作目录中的相应文件。

```bash
git add .         # 添加文件到缓存,无论是修改过的还是新建的都需要添加到缓存
git status        # 查看你的文件在工作目录与缓存的状态
git status  -s    # 简短的输出

git diff          # 显示暂存区和工作区的差异
git diff --stat   # 显示摘要而非整个 diff
git diff --cached # 查看已缓存的改动

git commit  -m "xxx" -a  # 提交工作区自上次commit之后的变化，直接到仓库区 ;-v 提交时显示所有diff信息

git reset HEAD    # 取消缓存已缓存的内容
git rm            # 将文件从缓存区移除
```

‍

### 3. 分支与合并

> **简而言之**，你可以执行 `git branch (branchname)`​ 来创建分支，使用 `git checkout (branchname)`​ 命令切换到该分支，在该分支的上下文环境中，提交快照等，之后可以很容易地来回切换。当你切换分支的时候，Git 会用该分支的最后提交的快照替换你的工作目录的内容，所以多个分支不需要多个目录。使用 `git merge`​ 来合并分支。你可以多次合并到统一分支，也可以选择在合并之后直接删除被并入的分支。使用 `git log`​ 列出促成当前分支目前的快照的提交历史记录。这使你能够看到项目是如何到达现在的状况的。

```bash
git branch                     # 列出分支；-r 列出所有远程分支 -a 列出所有本地分支和远程分支
git branch (branchname)        # 新建本地分支
git branch -d (branchname)     # 删除分支
git branch -dr [remote/branch] # 删除远程分支
git checkout -b (branchname)   # 创建新分支，并立即切换到它
git merge                      # 将分支合并到你的当前分支
git log    # 显示一个分支中提交的更改记录，--oneline 选项来查看历史记录的紧凑简洁的版本。 --graph 选项，查看历史中什么时候出现了分支、合并
git tag [tag] [commit]   # 给历史记录中的某个重要的一点打上标签,新建一个tag在指定commit

```

‍

### 4. 分享与更新项目

> **简而言之** 使用 `git fetch`​ 更新你的项目，使用 `git push`​ 分享你的改动。你可以用 `git remote`​ 管理你的远程仓库。

```bash
git remote            # 列出远端别名， -v 参数，你还可以看到每个别名的实际链接地址
git remote add [alias] [url]  # 为你的项目添加一个新的远端仓库
git remote rm      # 删除现存的某个别名

git fetch [alias]       # 从远端仓库下载新分支与数据 【从远程获取最新版本到本地，但不会自动merge】
git pull [alias]  [branch]     # 从远端仓库提取数据并尝试合并到当前分支【会获取所有远程索引并合并到本地分支中来】

git push [alias] [branch]    # 推送你的新分支与数据到某个远端仓库

```

‍

### 4. 检查与比较

> **简而言之** 执行 `git log`​ 找到你的项目历史中的特定提交 ——       按作者、日期、内容或者历史记录。执行 `git diff`​ 比较历史记录中的两个不同的点 ——       通常是为了看看两个分支有啥区别，或者从某个版本到另一个版本，你的软件都有啥变化。

```bash
# 显示有变更的文件
git status
# 显示当前分支的版本历史
 git log
# 显示commit历史，以及每次commit发生变更的文件
git log --stat
# 搜索提交历史，根据关键词
git log -S [keyword]
# 显示某个commit之后的所有变动，每个commit占据一行
git log [tag] HEAD --pretty=format:%s
# 显示某个commit之后的所有变动，其"提交说明"必须符合搜索条件
 git log [tag] HEAD --grep feature
# 显示某个文件的版本历史，包括文件改名
git log --follow [file]
git whatchanged [file]
# 显示指定文件相关的每一次
diffgit log -p [file]
# 显示过去5次提交
git log -5 --pretty --oneline
# 显示所有提交过的用户，按提交次数排序
git shortlog -sn
# 显示指定文件是什么人在什么时间修改过
git blame [file]
# 显示暂存区和工作区的差异
git diff
# 显示暂存区和上一个commit的差异
git diff --cached [file]
# 显示工作区与当前分支最新commit之间的差异
git diff HEAD
# 显示两次提交之间的差异
git diff [first-branch]...[second-branch]
# 显示今天你写了多少行代码
git diff --shortstat "@{0 day ago}"
# 显示某次提交的元数据和内容变化
git show [commit]
# 显示某次提交发生变化的文件
git show --name-only [commit]
# 显示某次提交时，某个文件的内容
git show [commit]:[filename]
# 显示当前分支的最近几次提交
git reflog
```
