
### git init 创建新仓库

```sh
cd test                  #进入 test 文件夹
git init                 #会在该文件夹下生成 .git
Initialized empty Git repository in /Users/chen/test/.git/
```

### git clone 克隆仓库

```sh
git clone git@github.com:deepzz0/test.git [指定目录]   #克隆远程仓库，第三个参数可选：克隆到指定目录
git clone /Users/chen/test.git                        #克隆本地仓库
```

### git add 添加文件索引

```sh
git add README.md data/README2.md #添加文件到索引，添加多个文件用空格隔开。
git add .                         #添加所有文件到索引，包含：修改的文件，新加的文件
```

### git commit 提交修改

```sh
git commit -m "描述信息"      #提交修改内容
git commit -a -m "描述内容"   #提交在 git 管理中的被修改或被删除文件
git commit --amend           #修改描述信息
```

### git push 提交代码

```sh
git push <远程主机名> <本地分支名>:<远程分支名>
git push origin master        #将本地master分支推送到 origin 主机的master分支
git push -u origin master     #将master分支推送到origin主机，如果不存在，则会被创建，同时指定origin为默认主机，可查看 git remote
git push origin :develop      #删除远程develop分支，等同：$ git push origin -d develop
git push --all origin         #将本地所有分支推送到origin主机

git push -f                   #强制提交，将远程分支强制更新到本地分支状态，小心使用，一般用来回退误提交。
git push -4/-6                #指定使用 IPv4 或 IPv6 地址访问
git push origin HEAD:master   #忽略当前分支名称，直接提交到 origin 主机的 master 分支
```

### git pull 获取代码

```sh
git pull <远程主机名> <远程分支名>:<本地分支名>      #取回<远程主机名>的<远程分支名>，并与<本地分支名>合并
git pull origin master:deepzz                     #将远程主机的master分支与本地deepzz分支合并
git pull origin master                            #将远程主机 master 分支与当前分支合并
git pull —rebase <远程主机名> <远程分支名>:<本地分支名> #rebase 可以查看前面

git pull --depth=<depth>                          #限制从远程分支获取指定数量的提交
git pull -4/-6                                    #指定使用 IPv4 或 IPv6 地址访问
```

### git rm 删除文件或目录

```sh
git rm test.txt              #将 text.txt 从磁盘删除，并移除 索引
git rm -rf data              #删除目录及其文件，移除索引
git rm --cached test.txt     #删除缓存数据
```

### git reset 取消操作回退

```sh
git reset --hard HEAD~1     #撤销最近一次commit, 数字可变。 在这之后的 commit 全部舍弃
git reset --soft HEAD~1     #撤销最近一次commit, 数字可变。在这之后的 commit 都会事暂存状态，等待提交
git reset --soft HEAD^      #会滚最后一次提交

git push --force            #强制提交，丢弃之后的 commit
```

### git remote 远程主机

```sh
git remote                     #罗列所有远程主机
git remote -v                  #罗列主机并显示网址
cd test                        #进入 test 文件夹
git init                       #初始化仓库
git remote add origin git@github.com:deepzz0/test.git #在本地添加远程仓库
echo "# test" >> README.md     #创建并写入 “# test” 到文件 README.md
git add README.md              #添加 README.md 到版本控制下, 全部添加：$ git add .
git commit -m "first commit"   #提交时填写 message
git push -u origin master      #首次提交，指定分支的upstream，此后在该分支pull/push都会关联到master

…..
To git@github.com:deepzz0/test.git
 * [new branch]      master -> master
…..
-----------------------------------------------------------------------------------------------------------

git remote set-url --add origin <url2>   #为本地仓库添加第二个远程仓库，这样一次提交可提交到所有 远程仓库。该操作会在 .git/config 下的 config 文件里增加一行。

git config -e                            #查看 config 文件内容

----------------------------------------------------------------------------------------------------------------

git remote set-url origin git@github.com:deepzz0/test2.git #你可以重新关联本地仓库到新的远程仓库地址。
```

### git mv 重命名文件或目录

```sh
git add testt.txt              #将 text.txt 添加到索引
git mv test.txt newtext.txt    #将testgit
相当于：
    mv test.txt newtest.txt    #重命名
    git rm --cached test.txt   #移除 test.txt 索引
    git add newest.txt         #添加到索引
```

### git log 显示提交记录

```sh
git log   #显示提交纪录，从最新开始排列
```

### git status 查看文件状态

```sh
git status    #查看当前仓库文件状态：新加文件未 git add, 新加文件 git add 过，新修改文件未 git add.
```

### git branch 分支

```sh
git branch                        #显示分支列表
git branch -r                     #显示远程分支列表
git branch -a                     #显示所有分支列表
git branch deepzz                 #创建名为 deepzz 的分支
git branch -m oldbranch newbranch #重命名分支，-M：如果 newbranch 分支存在，强制重命名
git branch -d branchname          #删除本地分支，-D：强制删除本地分支
git branch -d -r branchname       #删除远程分支，同git push origin :branchnamee
```

### git checkout 切换分支

```sh
git checkout branchname            #切换新分支 head 版本
git checkout tagname               #切换到指定 tag 版本
git checkout master filename       #放弃修改文件，从 master 分支重新拣出 filename 文件
git checkout commit_id filename    #拣出指定提交 commit_id 的文件
git checkout .                     #放弃修改所有文件

git checkout -b branchname         #从当前分支创建一个 branchname 分支，并且chechkout过去
```

### git diff 查看修改

```sh
git diff                    #查看尚未 add 的文件修改内容
git diff --cached           #查看 add 的文件修改内容
git diff --staged           #显示下一次 commit 提交会修改到的内容
git diff HEAD               #显示工作版本与HEAD的差别
git diff branchname master  #查看两个分支最新的提交之间的不同
git diff branchname         #查看当前目录与另一个分支的区别
git diff HEAD^ HEAD         #比较上次 commit 和 上上次 commit 的不同
git diff SHA1 SHA2          #比较两个历史版本的区别
```

### git tag TAG相关

```sh
git tag                            #查看 tag 列表
git tag -l 'v0.1.*'                #搜索符合模式的tag
git tag v0.1.2-light               #创建轻量标签
git tag -a v0.1.2 -m "0.1.2版本"    #为标签加附注
git checkout tagname               #切换到 tag
git tag -d v0.1.2                  #删除标签
git push origin :v0.1.2            #删除远程标签
git tag -a v0.1.1 9fvc3d1          #给指定commit加tag
git push origin v0.1.2             #将v0.1.2 tag提交到远程服务器
git push origin --tags             #将本地tag全部提交到远程服务器
```

### git merge 分支合并

```sh
git checkout deepzz                #切换到deepzz分支
git merge master                   #将master分支合并到当前分支(deepzz)

#压合合并(squashed commits)，将一条分支上的若干提交压合成一条提交，提交到另一条分支
git merge —squash master           #master上的所有提交已合并到当前工作暂存区，等待提交
git commit -m 'merge from master'  #提交

#捡选合并(cherry-picking)，捡选另一条分支的某个提交改动到当前分支
git cherry-pick 321d76f            #捡选commit_id到当前工作暂存
git cherry-pick -n 321d76f 324dcj5 #捡选多条

#冲突处理
<<<<<<< HEAD
test in master
=======
test in deeps
>>>>>>> deepzz 
说明：
    <<<<<<<当前分支内容开始
    ======当前分支结束，以后是merge过来的代码
    >>>>>>>
```

### git rebase 查看修改

```sh
git checkout deepzz    #切换到deppzz分支
git rebase master      #把master分支合并到当前分支。
原理：
    rebase时，会将deepzz所有的提交(commit)取消掉，并且把它们保存为补丁(patch)(保存在 .git/rebase 目录中)。
之后，将最新的 master 分支更新到当前分支(相当于 merge 了一份最新代码到一个新的分支)。然后，再将这些补丁应用到当前分支，当然这可能会有冲突。
```

![[devops/GitLab/assets/bf95a8526436ba95288c6e9cafa3f951_MD5.png|750]]

### git fetch 取回本地

```sh
git fetch origin master   #取回master分支更新，丢弃改动
```

### git stash 保存工作现场

```sh
git stash list                #查看 stash 队列
git stash                     #保存工作现场
git stash save -a "message"   #保存工作现场，并加上message
git stash pop                 #恢复最近 stash 
git stash pop stash@{num}     #恢复工作现场，num为编号，会从stash list删除
git stash clear               #清空stash队列
git stash drop                #删除进度
```

### git config 配置

```sh
git config --global user.name "your_name"    #配置全局的用户名和邮箱
git config --global user.email  "your_email"

git config user.name "your_name"             #为项目单独配置用户
git config user.email "your_email"
```

### FAQ

**git fork后的项目如何更新？**

现在有项目A，其地址是A_REPOSITORY_URL。fork到自己仓库B，其地址B_REPOSITORY_URL。现在A进行了commit更新，那么B如何同步更新呢？

```sh
git clone B_REPOSITORY_URL                        #先把B clone到本地
git remote add upstream A_REPOSITORY_URL          #再cd到本地B的目录，把A作为一个remote加到本地的B中（一般命名为upstream）
git pull upstream master                          #pull另一个A的remote（upstream）的相应分支（比如master）就可以
git push origin master                            #最后push回github的B_REPOSITORY
> 摘自知乎：https://www.zhihu.com/question/20171506/answer/15674190
```

**github 如何提交pull request？**


1. fork 项目 A 到自己的仓库 B。
2. clone 项目 B 到本地。
3. 修改代码并提交到项目 B。
4. 到项目 B 主页，点击 New pull request。



**为项目设置用户名**

```sh
# 设置全局用户
git config –global user.name "github’s Name"
git config –global user.email "github@xx.com"

# 为项目单独设置
git config user.name "gitlab’s Name"
git config user.email "gitlab@xx.com"
```

### 示意图

![[devops/GitLab/assets/d986b68808b003063090d4f1058483fa_MD5.png]]

### gitlab 推荐流程

下面这张图是 gitlab 上的分支操作流程图。
![[devops/GitLab/assets/b8e6dfb07a36453c94e0c519f49fb58c_MD5.png]]

