# nginx 添加新模块

```bash
# 当前适用于nginx已经在安装过了，如果没安装过，直接在编译时候添加模块即可。
# echo模块可以输出文字，下载解压即可
wget https://github.com/openresty/echo-nginx-module/archive/v0.60.tar.gz

# 建立一个模块仓库，因为添加模块后，那个文件夹要位置固定，不能删除的
mkdir /usr/local/nginx/module ;mv echo-nginx-mdule-0.60 /usr/local/nginx/module/

# 查询当前nginx编译模块
nginx -V

# 找到nginx源码包目录，将原来的都填写上，最后–add-module是添加模块，指定模块文件夹位置即可
./configure --prefix=/usr/local/nginx --user=nginx --group=nginx  --with-http_ssl_module --with-http_spdy_module  --with-http_stub_status_module --with-pcre  --add-module=/usr/local/nginx/module/echo-nginx-module-0.60/

# 编译，不要install，不然覆盖了，注意看状态，最后没有error就行了
make

# 替换 make后将在当前nginx源码文件夹下有个objs文件夹，里面有个nginx这个文件，这个就是nginx -V时用的命令
# 备份命令
cp /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.bak
cp objs/nginx /usr/local/nginx/sbin

# 检查配置文件是否显示ok
cd /usr/local/nginx/sbin
nginx -t
# 重新加载
nginx -s reload
# 检查是否编译进去，和原来的做对比
nginx -V
```
