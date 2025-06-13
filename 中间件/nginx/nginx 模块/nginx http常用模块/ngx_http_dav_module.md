# ngx_http_dav_module

​`ngx_http_dav_module`​ 模块用于通过 WebDAV 协议进行文件管理自动化。该模块处理 HTTP 和 WebDAV 的 PUT、DELETE、MKCOL、COPY 和 MOVE 方法。

该模块不是默认构的，您可以在构建时使用 `--with-http_dav_module`​ 配置参数启用。

> 需要其他 WebDAV 方法进行操作的 WebDAV 客户端将无法使用此模块。

## 示例配置

```
location / {
    root                  /data/www;

    client_body_temp_path /data/client_temp;

    dav_methods PUT DELETE MKCOL COPY MOVE;

    create_full_put_path  on;
    dav_access            group:rw  all:r;

    limit_except GET {
        allow 192.168.1.0/32;
        deny  all;
    }
}
```

## 指令

### dav\_access

|-|说明|
| ---| -------------------------|
|**语法**|**dav_access** `users:permissions ...`​;|
|**默认**|dav\_access user:rw;|
|**上下文**|http、server、location|

设置新创建的文件和目录的访问权限，例如：

```
dav_access user:rw group:rw all:r;
```

如果指定了任何 `group`​ （组）或所有访问权限，则可以省略 `user`​ 权限：

```
dav_access group:rw all:r;
```

### dav\_methods

|-|说明|
| ---| ------------------------|
|**语法**|**dav_methods** `off`​\|`method ...`​;|
|**默认**|dav\_methods off;|
|**上下文**|http、server、location|

允许指定的 HTTP 方法和 WebDAV 方法。参数 `off`​ 将拒绝本模块处理的所有方法。支持以下方法：PUT、DELETE、MKCOL、COPY 和 MOVE。

使用 PUT 方法上传的文件首先需要写入一个临时文件，然后重命名该文件。从 0.8.9 版本开始，临时文件和持久存储可以放在不同的文件系统上。但是，请注意，在这种情况下，文件复制需要跨越两个文件系统，而不是简单的重命名操作。因此，建议通过 [client_body_temp_path](https://docshome.gitbook.io/nginx-docs/he-xin-gong-neng/http/ngx_http_core_module#client_body_temp_path) 指令对临时文件设置存放目录，与保存文件的目录设置在同一文件系统上。

当使用 PUT 方法创建文件时，可以通过在 **Date** 头域中传递日期来指定修改日期。

### create\_full\_put\_path

|-|说明|
| ---| ---------------------------------------|
|**语法**|**create_full_put_path** `on`​\|`off`​;|
|**默认**|create\_full\_put\_path off;|
|**上下文**|http、server、location|

WebDAV 规范仅允许在已存在的目录中创建文件。开启该指令允许创建所有需要的中间目录。

### min\_delete\_depth

|-|说明|
| ---| -----------------------------|
|**语法**|**min_delete_depth** `number`​;|
|**默认**|min\_delete\_depth 0;|
|**上下文**|http、server、location|

允许 DELETE 方法删除文件，只要请求路径中的元素数不少于指定的数字。例如，指令：

```
min_delete_depth 4;
```

允许删除请求中的文件

```
/users/00/00/name
/users/00/00/name/pic.jpg
/users/00/00/page.html
```

拒绝删除的文件

```
/users/00/00
```
