### 配置要求

对于本教程，您将需要：

- 安装有macOS，Linux或Windows操作系统的机器，并拥有以下配置：
    - 最小256MB内存, 推荐512MB以上。
    - 10GB硬盘空间， 用于安装Jenkins，您的Docker镜像和容器。
    
- 安装有以下软件:

    - [Docker](https://www.docker.com/) - 在[安装Jenkins](https://www.jenkins.io/doc/book/installing/)页面的[安装Docker](https://www.jenkins.io/doc/book/installing/#installing-docker)章节阅读更多信息。  
        **注意:** 如果您使用Linux，本教程假定您没有以root用户的身份运行Docker命令，而是使用单个用户帐户访问本教程中使用的其他工具。
    - [Git](https://git-scm.com/downloads)和[GitHub Desktop](https://desktop.github.com/).
### 在 Docker中运行Jenkins

在本教程中, 将Jenkins作为 Docker 容器并从 [`jenkinsci/blueocean`](https://hub.docker.com/r/jenkinsci/blueocean/) Docker 镜像中运行。

要在 Docker中运行Jenkins, 请遵循下面的[macOS 和 Linux](https://www.jenkins.io/zh/doc/tutorials/build-a-java-app-with-maven/#on-macos-and-linux) 或 [Windows](https://www.jenkins.io/zh/doc/tutorials/build-a-java-app-with-maven/#on-windows)相关文档说明进行操作。 .

你可以在 [Docker](https://www.jenkins.io/zh/doc/book/installing#docker)和 [Installing Jenkins](https://www.jenkins.io/zh/doc/book/installing) 页面的 [Downloading and running Jenkins in Docker](https://www.jenkins.io/zh/doc/book/installing#downloading-and-running-jenkins-in-docker)部分阅读更多有关Docker容器和镜像概念的信息。

#### 在 macOS 和 Linux 系统上

1. 打开终端窗口
2. 使用下面的 [`docker run`](https://docs.docker.com/engine/reference/commandline/run/) 命令运行 `jenkinsci/blueocean` 镜像作为Docker中的一个容器(记住，如果本地没有镜像，这个命令会自动下载):
    ```
    docker run \
      --rm \
      -u root \
      -p 8080:8080 \
      -v jenkins-data:/var/jenkins_home \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "$HOME":/home \
      jenkinsci/blueocean
    ```
    
3. 继续 [安装向导](https://www.jenkins.io/zh/doc/tutorials/build-a-java-app-with-maven/#setup-wizard)。
    

#### 在 Windows 系统

1. 打开命令提示窗口。
    
2. 使用下面的 [`docker run`](https://docs.docker.com/engine/reference/commandline/run/) 命令运行 `jenkinsci/blueocean` 镜像作为Docker中的一个容器(记住，如果本地没有镜像，这个命令会自动下载):
    
    docker run ^
      --rm ^
      -u root ^
      -p 8080:8080 ^
      -v jenkins-data:/var/jenkins_home ^
      -v /var/run/docker.sock:/var/run/docker.sock ^
      -v "%HOMEPATH%":/home ^
      jenkinsci/blueocean
    
    对这些选项的解释, 请参考上面的 [macOS 和 Linux](https://www.jenkins.io/zh/doc/tutorials/build-a-java-app-with-maven/#on-macos-and-linux) 说明。
    
3. 继续[安装向导](https://www.jenkins.io/zh/doc/tutorials/build-a-java-app-with-maven/#setup-wizard)。
    

#### 访问 Jenkins/Blue Ocean Docker 容器

如果你有一些使用 Docker 的经验，希望或需要使用 [`docker exec`](https://docs.docker.com/engine/reference/commandline/exec/) 命令通过一个终端/命令提示符来访问 Jenkins/Blue Ocean Docker 容器, 你可以添加如 `--name jenkins-tutorials` 选项(与上面的 [`docker run`](https://docs.docker.com/engine/reference/commandline/run/) ), 这将会给Jenkins/Blue Ocean Docker容器一个名字 "jenkins-tutorials"。

这意味着你可以通过 `docker exec` 命令访问Jenkins/Blue Ocean 容器(通过一个单独的终端 /命令提示窗口) ，例如:

`docker exec -it jenkins-tutorials bash`

#### 安装向导

在你访问 Jenkins之前, 你需要执行一些快速的 "一次性" 步骤。

##### 解锁 Jenkins

当你第一次访问一个新的 Jenkins 实例时, 要求你使用自动生成的密码对其进行解锁。

1. 当在终端/命令提示窗口出现两组星号时, 浏览 `http://localhost:8080` 并等待 **Unlock Jenkins** 页面出现。
    
    ![[devops/Jenkins/assets/16394b5b4cf2885d03733b0ed4839a3c_MD5.jpg]]
    
2. 再次从终端/命令提示窗口, 复制自动生成的字母数字密码(在两组星号之间)。![[devops/Jenkins/assets/792fb98a26823751529c0de7abee3a53_MD5.png]]
    
3. 在 **Unlock Jenkins** 页面, 粘贴该密码到 **Administrator password** 字段并点击 **Continue**。
    

##### 使用插件自定义 Jenkins

在 [解锁 Jenkins](https://www.jenkins.io/zh/doc/tutorials/build-a-java-app-with-maven/#unlocking-jenkins)后, **Customize Jenkins** 页面出现。

在该页面，点击 **Install suggested plugins**。
安装向导显示了正在配置的Jenkins的进程，以及建议安装的插件。这个过程肯需要几分钟。

##### 创建第一个管理员用户

最后, Jenkins 要求创建你的第一个管理员用户。

1. 当 **Create First Admin User** 页面出现, 在相应的字段中指定你的详细消息并点击 **Save and Finish**。
2. 当 **Jenkins is ready** 页面出现, 点击 **Start using Jenkins**。  
    **Notes:**
    - 该页面可能表明 **Jenkins is almost ready!** 如果相反, 点击 **Restart**.
    - 如果该页面在一分钟后没有自动刷新, 使用你的web浏览器手动刷新。
3. 如果需要,登录 Jenkins ， 你就可以开始使用 Jenkins了!


### Fork 和 clone GitHub示例仓库

通过将应用程序源代码所在的示例仓库fork到你自己的Github账号中， 并clone到本地，你就可以获取一个"Hello world!"简单Java应用程序。

1. 请确保你登陆了你的GitHub账户。如果你还没有Github账户，你可以在 [GitHub网站](https://github.com/) 免费注册一个账户。
2. 将示例仓库 [`simple-java-maven-app`](https://github.com/jenkins-docs/simple-java-maven-app) fork到你的账户的Github仓库中。在此过程中，如果你需要帮助，请参考 [Fork A Repo](https://help.github.com/articles/fork-a-repo/) 文档。
3. 将你的GitHub账户中的 `simple-java-maven-app` 仓库clone到你的本地机器。 根据你的情况完成以下步骤之一(其中 `<your-username>` 是你的操作系统用户账户名称)：
    - 如果你的机器安装了Github Desktop：
        1. 在GitHub网站上，点击绿色的 **Clone or download** 按钮，再点击 **Open in Desktop**.
        2. 在Github桌面版中，在点击 **Clone a Repository** 对话框上的 **Clone** 按钮之前，确保 **Local Path** 的配置为：
            - macOS 系统配置为 `/Users/<your-username>/Documents/GitHub/simple-java-maven-app`
            - Linux 系统配置为 `/home/<your-username>/GitHub/simple-java-maven-app`

            - Windows 系统配置为 `C:\Users\<your-username>\Documents\GitHub\simple-java-maven-app`

    - 其他情况:
        1. 打开一个终端/命令提示符，并且 `cd` 进入正确的目录路径：
            - macOS 系统路径为 `/Users/<your-username>/Documents/GitHub/`
            - Linux 系统路径为 `/home/<your-username>/GitHub/`
            - Windows 系统路径为 `C:\Users\<your-username>\Documents\GitHub\` （推荐使用Git bash命令行，而不是通常的Microsoft命令提示符）
            
        2. 运行以下命令完成仓库的clone：  
            `git clone https://github.com/YOUR-GITHUB-ACCOUNT-NAME/simple-java-maven-app`  
            其中 `YOUR-GITHUB-ACCOUNT-NAME` 是你的Github账户的名称。

### 在Jenkins中创建你的流水线项目

1. 回到Jenkins，如果有必要的话重新登录，点击 **Welcome to Jenkins!** 下方的 **create new jobs**  
    **注意:** 如果你无法看见以上内容，点击左上方的 **New Item** 。
2. 在 **Enter an item name** 域中，为新的流水线项目指定名称（例如 `simple-java-maven-app`）。
3. 向下滚动并单击 **Pipeline**，然后单击页面末尾的 **OK** 。
4. （ _可选_ ） 在下一页中，在 **Description** 字段中填写流水线的简要描述 （例如 `一个演示如何使用Jenkins构建Maven管理的简单Java应用程序的入门级流水线。`）
5. 点击页面顶部的 **Pipeline** 选项卡，向下滚动到 **Pipeline** 部分。
6. 在 **Definition** 域中，选择 **Pipeline script from SCM** 选项。此选项指示Jenkins从源代码管理（SCM）仓库获取你的流水线， 这里的仓库就是你clone到本地的Git仓库。
7. 在 **SCM** 域中，选择 **Git**。
8. 在 **Repository URL** 域中，填写你本地仓库的 [目录路径](https://www.jenkins.io/zh/doc/tutorials/build-a-java-app-with-maven/#fork-sample-repository)， 这是从你主机上的用户账户home目录映射到Jenkins容器的 `/home`目录：
    - MacOS系统 - `/home/Documents/GitHub/simple-java-maven-app`
    - Linux系统 - `/home/GitHub/simple-java-maven-app`
    - Windows系统 - `/home/Documents/GitHub/simple-java-maven-app`
9. 点击 **Save** 保存你的流水线项目。你现在可以开始创建你的 `Jenkinsfile`，这些文件会被添加到你的本地仓库。

### 将你的初始流水线创建为Jenkinsfile

现在你已准备好创建你的流水线，它将使用Jenkins中的Maven自动构建你的Java应用程序。 你的流水线将被创建为 `Jenkinsfile`，它将被提交到你本地的Git仓库（`simple-java-maven-app`）。

这是 "Pipeline-as-Code" 的基础，它将持续交付流水线作为应用程序的一部分，与其他代码一样进行版本控制和审查。 阅读更多关于 [流水线](https://www.jenkins.io/doc/book/pipeline) 的信息，以及用户手册中的 [使用Jenkinsfile](https://www.jenkins.io/doc/book/pipeline/jenkinsfile) 章节。

首先，创建一个初始流水线来下载Maven Docker镜像，并将其作为Docker容器运行（这将构建你的简单Java应用）。 同时添加一个“构建”阶段到流水线中，用于协调整个过程。
1. 使用你最称手的文本编辑器或者IDE，在你本地的 `simple-java-maven-app` Git仓库的根目录创建并保存一个名为 `Jenkinsfile` 的文本文件。
2. 复制以下声明式流水线代码并粘贴到 `Jenkinsfile` 文件中：
    ```
    pipeline {
        agent {
            docker {
                image 'maven:3-alpine' 
                args '-v /root/.m2:/root/.m2' 
            }
        }
        stages {
            stage('Build') { 
                steps {
                    sh 'mvn -B -DskipTests clean package' 
                }
            }
        }
    }
    ```
    
    这里的 `image` 参数（参考 [`agent`](https://www.jenkins.io/doc/book/pipeline/syntax#agent) 章节的 `docker` 参数） 是用来下载 [`maven:3-apline` Docker镜像](https://hub.docker.com/_/maven/) （如果你的机器还没下载过它）并将该镜像作为单独的容器运行。这意味着：<br><br>- 你将在Docker中本地运行相互独立的Jenkins和Maven容器。<br>    <br>- Maven容器成为了Jenkins用来运行你的流水线项目的 [agent](https://www.jenkins.io/doc/book/glossary/#agent)。 这个容器寿命很短——它的寿命只是你的流水线的执行时间。
    这里的 `args` 参数在暂时部署的Maven Docker容器的 `/root/.m2` （即Maven仓库）目录 和Docker主机文件系统的对应目录之间创建了一个相互映射。这背后的实现细节超出了本教程的范围，在此不做解释。 但是，这样做的主要原因是，在Maven容器的生命周期结束后，构建Java应用程序所需的工件 （Maven在流水线执行时进行下载）能够保留在Maven存储库中。这避免了在后续的流水线执行过程中， Maven反复下载相同的工件。请注意，不同于你为 [`jenkins-data`](https://www.jenkins.io/zh/doc/tutorials/build-a-java-app-with-maven/#download-and-run-jenkins-in-docker) 创建的Docker数据卷，Docker主机的文件系统在每次重启Docker时都会被清除。 这意味着每次Docker重新启动时，都会丢失下载的Maven仓库工件。
    定义了一个名为 `Build` 的 [`stage`](https://www.jenkins.io/doc/book/pipeline/syntax/#stage)，之后会出现在Jenkins UI上。
    这里的 [`sh`](https://www.jenkins.io/doc/pipeline/steps/workflow-durable-task-step/#code-sh-code-shell-script) step（参考 [`steps`](https://www.jenkins.io/doc/book/pipeline/syntax/#steps) 章节）运行Maven命令干净地构建你的Java应用（不运行任何tests）。
    
3. 保存对 `Jenkinsfile` 的修改并且将其提交到你本地的 `simple-java-maven-app` Git仓库。例如，在 `simple-java-maven-app` 目录下，运行以下命令：  
    `git add .`  
    继续运行  
    `git commit -m "Add initial Jenkinsfile"`
    
4. 再次回到Jenkins，如果有必要的话重新登录，点击左侧的 **Open Blue Ocean** 进入Jenkins的Blue Ocean界面。
    
5. 在 **This job has not been run** 消息框中，点击 **Run**，然后快速点击右下角出现的 **OPEN** 链接， 观察Jenkins运行你的流水线项目。如果你不能点击 **OPEN** 链接，点击Blue Ocean主界面的一行来使用这一特性。  
    **注意：** 你可能需要几分钟时间等待第一次运行完成。在clone了你的本地 `simple-java-maven-app` Git仓库后， Jenkins接下来做了以下动作：
    
    1. 将项目排入队列等待在agent上运行。
        
    2. 下载Maven Docker镜像，并且将其运行在Docker中的一个容器中。
        
        ![[devops/Jenkins/assets/c167ef3f4ec7798592ef36096bf5a309_MD5.png]]
        
    3. 在Maven容器中运行 `Build` 阶段 （`Jenkinsfile` 中所定义的）。在这期间，Maven会下载构建你的Java应用所需的工件， 这些工件最终会被保存在Jenkins的本地Maven仓库中（Docker的主机文件系统）。
        
        ![[devops/Jenkins/assets/dc22c5dd8ff1a2a0c0a1c5cd2344b8ea_MD5.png]]
        
    
    若Jenkins成功构建了你的Java应用，Blue Ocean界面会变为绿色。
    
    ![[devops/Jenkins/assets/f011b57df55f0f337a83d7fe97a23c4f_MD5.png]]
    
6. 点击右上方的 **X** 回到Blue Ocean主界面。
    
    ![[devops/Jenkins/assets/3ce3e078bc36def3c81194c95ca893a7_MD5.png]]
    

### [](https://www.jenkins.io/zh/doc/tutorials/build-a-java-app-with-maven/#%E4%B8%BA%E4%BD%A0%E7%9A%84%E6%B5%81%E6%B0%B4%E7%BA%BF%E5%A2%9E%E5%8A%A0test%E9%98%B6%E6%AE%B5)为你的流水线增加test阶段[](https://www.jenkins.io/zh/doc/tutorials/build-a-java-app-with-maven/#%E4%B8%BA%E4%BD%A0%E7%9A%84%E6%B5%81%E6%B0%B4%E7%BA%BF%E5%A2%9E%E5%8A%A0test%E9%98%B6%E6%AE%B5)

1. 回到你的文本编辑器/IDE，打开你的 `Jenkinsfile`。
    
2. 复制以下声明式流水线代码，并粘贴到 `Jenkinsfile` 中 `Build` 阶段的下方：
    
    ```
            stage('Test') {
                steps {
                    sh 'mvn test'
                }
                post {
                    always {
                        junit 'target/surefire-reports/*.xml'
                    }
                }
            }
    ```
    
    最终的代码为：
    
    ```
    pipeline {
        agent {
            docker {
                image 'maven:3-alpine'
                args '-v /root/.m2:/root/.m2'
            }
        }
        stages {
            stage('Build') {
                steps {
                    sh 'mvn -B -DskipTests clean package'
                }
            }
            stage('Test') { 
                steps {
                    sh 'mvn test' 
                }
                post {
                    always {
                        junit 'target/surefire-reports/*.xml' 
                    }
                }
            }
        }
    }
    ```
    
    
    定义了一个名为 `Test` 的 [`stage`](https://www.jenkins.io/doc/book/pipeline/syntax/#stage)，之后会出现在Jenkins UI上。
    这里的 [`sh`](https://www.jenkins.io/doc/pipeline/steps/workflow-durable-task-step/#code-sh-code-shell-script) step （参考 [`steps`](https://www.jenkins.io/doc/book/pipeline/syntax/#steps) 章节）执行Maven命令来运行你的Java应用的单元测试。 这个命令还生成一个JUnit XML报告，保存在 `target/surefire-reports` 目录 （位于Jenkins容器中的 `/var/jenkins_home/workspace/simple-java-maven-app` 目录）。|
    这里的 [`junit`](https://www.jenkins.io/doc/pipeline/steps/junit/#code-junit-code-archive-junit-formatted-test-results) step （由 [JUnit Plugin](https://www.jenkins.io/doc/pipeline/steps/junit) 提供）用于归档JUnit XML报告（由上面的 `mvn test` 命令生成） 并通过Jenkins接口公开结果。在Blue Ocean中，可以在流水线运行的 **Tests** 页面获取结果。 [`post`](https://www.jenkins.io/doc/book/pipeline/syntax/#post) 章节的 `always` 条件包含了这个 `junit` step， 保证了这个step _总是_ 在 `Test` 阶段 _结束后_ 执行，不论该阶段的运行结果如何。|
    
3. 保存对 `Jenkinsfile` 的修改并将其提交到你的本地 `simple-java-maven-app` Git仓库。例如，在 `simple-java-maven-app` 目录下，运行以下命令：  
    `git stage .`  
    继续运行  
    `git commit -m "Add 'Test' stage"`
    
4. 再次回到Jenkins，如果有必要的话重新登录，进入Jenkins的Blue Ocean界面。
    
5. 点击左上方的 **Run** 然后快速点击右下方出现的 **OPEN** 链接， 观察Jenkins运行你修改过的流水线项目。 如果你不能点击 **OPEN**链接，点击Blue Ocean主界面的 _top_ 行来使用这一特性。  
    **注意：** 你会发现本次运行Jenkins不再需要下载Maven Docker镜像。Jenkins只需要从之前下载的Maven镜像运行 一个新的容器。另外，如果最近一次运行 [流水线](https://www.jenkins.io/zh/doc/tutorials/build-a-java-app-with-maven/#create-your-initial-pipeline-as-a-jenkinsfile) 后，Docker没有重启， 那么在 "Build" 阶段无需下载Maven工件。因此，你的流水线再次运行时速度会更快。  
    如果你修改过的流水线运行成功，Blue Ocean界面看起来会像下面这样。注意增加的 "Test" 阶段。 你可以点击之前的 "Build" 阶段来获取阶段输出结果。
    
    ![[devops/Jenkins/assets/dfb2cec0b25a151eefc46929ccefe16b_MD5.png]]
    
6. 点击右上方的 **X** 回到Blue Ocean主界面。
    

### 为你的流水线增加deliver阶段

1. 回到你的文本编辑器/IDE，打开你的 `Jenkinsfile`。
    
2. 复制以下声明式流水线代码，并粘贴到 `Jenkinsfile` 中 `Test` 阶段的下方：
    
    ```
            stage('Deliver') {
                steps {
                    sh './jenkins/scripts/deliver.sh'
                }
            }
    ```
    
    最终的代码为：
    
    ```
    pipeline {
        agent {
            docker {
                image 'maven:3-alpine'
                args '-v /root/.m2:/root/.m2'
            }
        }
        stages {
            stage('Build') {
                steps {
                    sh 'mvn -B -DskipTests clean package'
                }
            }
            stage('Test') {
                steps {
                    sh 'mvn test'
                }
                post {
                    always {
                        junit 'target/surefire-reports/*.xml'
                    }
                }
            }
            stage('Deliver') { 
                steps {
                    sh './jenkins/scripts/deliver.sh' 
                }
            }
        }
    }
    ```
    
    定义了一个名为 `Deliver` 的stage，之后会出现在Jenkins UI上。|
    这里的 [`sh`](https://www.jenkins.io/doc/pipeline/steps/workflow-durable-task-step/#code-sh-code-shell-script) step （参考 [`steps`](https://www.jenkins.io/doc/book/pipeline/syntax/#steps) 章节）执行位于 `jenkins/scripts` 目录下的shell脚本 `deliver.sh`， 该目录位于 `simple-java-maven-app` 仓库根目录下。`deliver.sh` 文件所做动作包含在其自身文本内容中。 一般的原则是，尽量保持你的流水线代码（即 `Jenkinsfile`）越简洁越好，将更复杂的构建步骤放在多个独立的shell脚本中 （尤其对于那些包含2个以上steps的stage）。这最终会使得维护你的流水线代码变得更容易，特别是当你的流水线变得越来越复杂的时候。|
    
3. 保存对 `Jenkinsfile` 的修改并将其提交到你的本地 `simple-java-maven-app` Git仓库。例如，在 `simple-java-maven-app` 目录下，运行以下命令：  
    `git stage .`  
    继续运行  
    `git commit -m "Add 'Deliver' stage"`
    
4. 再次回到Jenkins，如果有必要的话重新登录，进入Jenkins的Blue Ocean界面。
    
5. 点击左上方的 **Run** 然后快速点击右下方出现的 **OPEN** 链接， 观察Jenkins运行你修改过的流水线项目。 如果你不能点击 **OPEN**链接，点击Blue Ocean主界面的 _top_ 行来使用这一特性。  
    如果你修改过的流水线运行成功，Blue Ocean界面看起来会像下面这样。注意增加的 "Deliver" 阶段。 你可以点击之前的 "Test" 和 "Build" 阶段来获取阶段输出结果。
    
    ![[devops/Jenkins/assets/eec439c3c88f757d43424b28c54953f1_MD5.png]]
    
    以下是 "Deliver" 阶段的输出应该是什么样子，向你展示最终Java应用程序的执行结果。
    
    ![[devops/Jenkins/assets/904a3343b0817efe90fcd15546d17532_MD5.png]]
    
6. 点击右上方的 **X** 回到Blue Ocean主界面，列表显示流水线历史运行记录，按时间顺序倒序排列。![[devops/Jenkins/assets/c2987db00eaa47cdf21e3a2d439b2bbd_MD5.png]]
