
我们知道使用一个 `Dockerfile` 模板文件，可以让用户很方便的定义一个单独的应用容器。然而，在日常工作中，经常会碰到需要多个容器相互配合来完成某项任务的情况。例如要实现一个 Web 项目，除了 Web 服务容器本身，往往还需要再加上后端的数据库服务容器，甚至还包括负载均衡容器等。

`Compose` 恰好满足了这样的需求。它允许用户通过一个单独的 `docker-compose.yml` 模板文件（YAML 格式）来定义一组相关联的应用容器为一个项目（project）。

**​`Compose`​**​ ** 中有两个重要的概念：**
- 服务 (`service`)：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例。
- 项目 (`project`)：由一组关联的应用容器组成的一个完整业务单元，在 `docker-compose.yml` 文件中定义。

`Compose` 的默认管理对象是项目，通过子命令对项目中的一组容器进行便捷地生命周期管理。
`Compose` 项目由 Python 编写，实现上调用了 Docker 服务提供的 API 来对容器进行管理。因此，只要所操作的平台支持 Docker API，就可以在其上利用 `Compose` 来进行编排管理。

**Compose v2**

目前 Docker 官方用 GO 语言 重写了 Docker Compose，并将其作为了 docker cli 的子命令，称为 `Compose V2`。你可以参照官方文档安装，然后将熟悉的 `docker-compose` 命令替换为 `docker compose`，即可使用 Docker Compose。

---

docker compose 学习博客「推荐」：  
https://tuonioooo-notebook.gitbook.io/docker/docker-compose
## 部署 docker-compose

`Compose` 支持 Linux、macOS、Windows 10 三大平台。
`Compose` 可以通过 Python 的包管理工具 `pip` 进行安装，也可以直接下载编译好的二进制文件使用，甚至能够直接在 Docker 容器中运行。
`Docker Desktop for Mac/Windows` 自带 `docker-compose` 二进制文件，安装 Docker 之后可以直接使用。

```bash
docker-compose --version
docker-compose version 1.27.4, build 40524192
```

Linux 系统请使用以下介绍的方法安装。  
从 官方 [GitHub Release](https://github.com/docker/compose/releases) 处直接下载编译好的二进制文件即可。

## docker compose 命令

### docker-compose

```sh
docker-compose [-f <arg>...] [options] [COMMAND] [ARGS...]
```

命令选项如下：

- -f，–file FILE指定Compose模板文件，默认为docker-compose.yml，可以多次指定。
- -p，–project-name NAME指定项目名称，默认将使用所在目录名称作为项目名。
- -x-network-driver 使用Docker的可拔插网络后端特性（需要Docker 1.9+版本） -x-network-driver DRIVER指定网络后端的驱动，默认为bridge（需要Docker 1.9+版本）
- -verbose输出更多调试信息
- -v，–version打印版本并退出

```bash
docker-compose 命令 --help                     获得一个命令的帮助
docker-compose up -d nginx                     构建启动nignx容器
docker-compose exec nginx bash                 登录到nginx容器中
docker-compose down                            此命令将会停止 up 命令所启动的容器，并移除网络
docker-compose ps                              列出项目中目前的所有容器
docker-compose restart nginx                   重新启动nginx容器
docker-compose build nginx                     构建镜像 
docker-compose build --no-cache nginx          不带缓存的构建
docker-compose top                             查看各个服务容器内运行的进程 
docker-compose logs -f nginx                   查看nginx的实时日志
docker-compose images                          列出 Compose 文件包含的镜像
docker-compose config                          验证文件配置，当配置正确时，不输出任何内容，当文件配置错误，输出错误信息。 
docker-compose events --json nginx             以json的形式输出nginx的docker日志
docker-compose pause nginx                     暂停nignx容器
docker-compose unpause nginx                   恢复ningx容器
docker-compose rm nginx                        删除容器（删除前必须关闭容器，执行stop）
docker-compose stop nginx                      停止nignx容器
docker-compose start nginx                     启动nignx容器
docker-compose restart nginx                   重启项目中的nignx容器
docker-compose run --no-deps --rm php-fpm php -v   在php-fpm中不启动关联容器，并容器执行php -v 执行完成后删除容器

```

‍
### docker-compose up

这个命令一定要记住，每次启动都要用到，只要学会使用的人记住这个就好了

```sh
docker-compose up [options] [--scale SERVICE=NUM...] [SERVICE...]
```

选项包括：

```bash
-d                  # 在后台运行服务容器
–no-color           # 不使用颜色来区分不同的服务的控制输出
–no-deps            # 不启动服务所链接的容器
–force-recreate     # 强制重新创建容器，不能与–no-recreate同时使用 –no-recreate 如果容器已经存在，则不重新创建，不能与–force-recreate同时使用
–no-build           # 不自动构建缺失的服务镜像
–build              # 在启动容器前构建服务镜像
–abort-on-container-exit # 停止所有容器，如果任何一个容器被停止，不能与-d同时使用
-t, –timeout        # TIMEOUT 停止容器时候的超时（默认为10秒）
–remove-orphans     # 删除服务中没有在compose文件中定义的容器
–scale SERVICE=NUM  # 设置服务运行容器的个数，将覆盖在compose中通过scale指定的参数  
-f                  # 指定使用的Compose模板文件，默认为docker-compose.yml，可以多次指定。  
```

