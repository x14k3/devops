# envsubst

```bash
# 主要用来替换配置文件的值 应用场景：docker run 自动修改jdbc配置文件
# 1.现在命令行中设定环境变量
export MY_NAME=sds
# 2.模块文件config.template
--------------------------
user_name="${MY_NAME}"
--------------------------
# 3.执行命令
envsubst < config.template > config.yaml
# 4.则会生成文件config.yaml
--------------------------------
user_name=sds
--------------------------------
```
