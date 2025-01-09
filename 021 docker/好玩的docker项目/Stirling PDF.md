# Stirling PDF

　　这是一个强大的本地托管的基于docker的基于web的PDF操作工具，可以让你对PDF文件进行各种操作，如拆分、合并、转换、重新组织、添加图片、旋转、压缩等等。这个本地托管的web应用程序最初是由100%的ChatGPT制作的应用程序，并已发展成为包含各种功能以满足你所有的PDF需求。

　　Stirling PDF不会进行任何记录或跟踪。

　　所有文件和PDF文件要么仅存在于客户端，仅在任务执行期间驻留在服务器内存中，要么仅暂时驻留在文件中以执行任务。用户下载的任何文件在那时都已从服务器中删除。

　　特点：

　　    支持暗黑模式  
    支持多种语言（包括简体和繁体中文）  
    有自定义下载选项（详情）  
    并行文件处理和下载  
    有与外部脚本集成的API  
    可选的登录和身份验证支持（详情）  
    支持自定义应用程序名称  
    支持自定义口号、图标、图片，甚至自定义HTML（通过文件覆盖）

　　‍

```bash
docker run -d \
  -p 8380:8080 \
  -v /data/stirling-pdf/data/:/usr/share/tesseract-ocr/4.00/tessdata \
  -v /data/stirling-pdf/configs/:/configs \
  -e DOCKER_ENABLE_SECURITY=false \
  --name stirling-pdf \
  frooodle/s-pdf:latest
```

```bash
DOCKER_ENABLE_SECURITY             # 这个默认就好，如果要开启用户登陆模式的话，再改成 true
INSTALL_BOOK_AND_ADVANCED_HTML_OPS # 这个是将calibre下载到stirling-pdf，以实现pdf到书籍和高级html转换用的，需要的可以打开
```

　　‍
