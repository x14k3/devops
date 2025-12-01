

**zip命令** 可以用来解压缩文件，或者对文件进行打包操作。zip是个使用广泛的压缩程序，文件经它压缩后会另外产生具有“.zip”扩展名的压缩文件。
# zip

```shell
zip(选项)(参数)
zip [-选项] [-b 路径] [-t 日期] [-n 后缀名] [压缩文件列表] [-xi 列表]
```

```shell
-f: 刷新：仅更改的文件
-u: 更新：仅更改或新文件
-d: 删除 zip 文件中的条目
-m: 移至 zip 文件（删除操作系统文件）
-r: 递归到目录
-j: 垃圾（不记录）目录名
-0: 仅存储
-l: 将 LF 转换为 CR LF (-ll CR LF 到 LF)
-1: 压缩速度更快
-9: 压缩得更好
-v: 详细操作/打印版本信息
-q: 安静运行
-c: 添加一行注释
-z: 添加 zip 文件注释
-@: 从标准输入读取名称
-o: 使 zip 文件与最新条目一样旧
-x: 排除以下名称
-i: 仅包含以下名称
-F: 修复 zip 文件（-FF 更加努力）
-D: 不添加目录条目
-A: 调整自解压exe
-D: 不添加目录条目
-T: 测试 zip 文件的完整性
-X: 排除额外的文件属性
-n: 不压缩这些后缀
-e: 加密
-y: 将符号链接存储为链接而不是引用的文件
-h2: 显示更多帮助
```

‍

压缩单个文件，这会将 `file.txt`​ 文件压缩到名为 `compressed.zip`​ 的归档文件中

```shell
zip compressed.zip file.txt
```

压缩多个文件，下面这个命令会把 `file1.txt`​，`file2.txt`​，和 `file3.txt`​ 压缩到一个叫做 `compressed.zip`​ 的归档文件中。

```shell
zip compressed.zip file1.txt file2.txt file3.txt
```

压缩整个目录，下面这个命令 `-r`​ 参数表示递归压缩，该命令将压缩 `folder`​ 目录及其所有子目录和文件

```shell
zip -r compressed.zip folder/
```

使用最大压缩比压缩文件，下面这个命令 `-9`​ 参数指定了最大压缩比，尽管可能需要更长的处理时间

```shell
zip -9 compressed.zip file.txt
```

创建密码保护的 zip 文件，下面这个命令 `-e`​ 参数会提示用户输入密码以创建加密的 zip 文件。

```shell
zip -e secure.zip file.txt
```

只压缩新文件或已更改的文件，如果 `compressed.zip`​ 已存在，`-u`​ 参数会更新归档中的 `file.txt`​ 或将其添加至归档中（如果它是新的）

```shell
zip -u compressed.zip file.txt
```

压缩文件但不保留目录结构，`-j`​ 参数将不保留 `file.txt`​ 的父目录 `folder`​，文件在 zip 中的位置将是在根目录下

```shell
zip -j compressed.zip folder/file.txt
```

将`/home/Blinux/html/`​这个目录下所有文件和文件夹打包为当前目录下的 `html.zip`​：

```shell
zip -q -r html.zip /home/Blinux/html
```

上面的命令操作是将绝对地址的文件及文件夹进行压缩，以下给出压缩相对路径目录，比如目前在Bliux这个目录下，执行以下操作可以达到以上同样的效果：

```shell
zip -q -r html.zip html
```

比如现在我的html目录下，我操作的zip压缩命令是：

```shell
zip -q -r html.zip *
```

压缩 `example/basic/`​ 目录内容到 `basic.zip`​ 压缩包中 `-x`​ 指定排除目录，注意没有双引号将不起作用。

```shell
zip -r basic.zip example/basic/ -x "example/basic/node_modules/*" -x "example/basic/build/*" -x "example/basic/coverage/*"
```

上面压缩解压出来，内容存放在 `example/basic/`​， 如果想存放到根目录，进入目录进行压缩，目前没有找到一个合适的参数来解决此问题。

```bash
cd example/basic/ && zip -r basic.zip . -x "node_modules/*" -x "build/*" -x "coverage/*"
```

压缩效率选择:

```bash
zip -9 # 1-9 faster->better
```

创建 `public_html`​ 目录下忽略所有文件和文件夹，排除包括文本 `backup`​ 的所有文件。

```bash
$ zip -r public_html.zip public_html -x *backup*
```

​`httpdocs`​ 目录忽略 `.svn`​ 文件或 `git`​ 的文件和目录下创建所有文件的归档。

```shell
$ zip -r httpdocs.zip httpdocs --exclude *.svn* --exclude *.git*
```

​`httpdocs`​ 目录忽略的所有文件，并与 `.log`​ 结尾的目录下创建所有文件的归档。

```shell
$ zip -r httpdocs.zip httpdocs --exclude "*.log"
```

**应用场景：** 某些文件太大不能直接上传为邮箱附件或者直接上传网盘，需要压缩，压缩之后大小仍然超过限制，那就分割压缩包（分卷压缩）；将多个分割的压缩包下载后，需要合并成一个压缩包再解压（合并解压）。

```bash
# ----- 分卷压缩 -----
 
# 将文件或者文件件打包为zip压缩包，book.zip大小为38.8M
zip -r book.zip ./input.pdf
# 将book.zip分割，每个压缩包不超过20M，生成两个压缩包subbook.zip（17.8M）和subbook.z01（21M）
zip -s 20m book.zip --out subbook.zip
 
 
# ----- 合并解压 -----
 
# 将上述两个压缩包合并为一个压缩文件single.zip
zip subbook.zip -s=0 --out single.zip
# 解压single.zip

```

‍

# zunip

**unzip命令** 用于解压缩由zip命令压缩的“.zip”压缩包。

```shell
unzip(选项)(参数)
```

```shell
-c：将解压缩的结果显示到屏幕上，并对字符做适当的转换；
-f：更新现有的文件；
-l：显示压缩文件内所包含的文件；
-p：与-c参数类似，会将解压缩的结果显示到屏幕上，但不会执行任何的转换；
-t：检查压缩文件是否正确；
-u：与-f参数类似，但是除了更新现有的文件外，也会将压缩文件中的其他文件解压缩到目录中；
-v：执行时显示详细的信息；
-z：仅显示压缩文件的备注文字；
-a：对文本文件进行必要的字符转换；
-b：不要对文本文件进行字符转换；
-C：压缩文件中的文件名称区分大小写；
-j：不处理压缩文件中原有的目录路径；
-L：将压缩文件中的全部文件名改为小写；
-M：将输出结果送到more程序处理；
-n：解压缩时不要覆盖原有的文件；
-o：不必先询问用户，unzip执行后覆盖原有的文件；
-P<密码>：使用zip的密码选项；
-q：执行时不显示任何信息；
-s：将文件名中的空白字符转换为底线字符；
-V：保留VMS的文件版本信息；
-X：解压缩时同时回存文件原来的UID/GID；
-d<目录>：指定文件解压缩后所要存储的目录；
-x<文件>：指定不要处理.zip压缩文件中的哪些文件；
-Z：unzip-Z等于执行zipinfo指令。
```

‍

将压缩文件text.zip在当前目录下解压缩。

```shell
unzip test.zip
```

将压缩文件text.zip在指定目录`/tmp`​下解压缩，如果已有相同的文件存在，要求unzip命令不覆盖原先的文件。

```shell
unzip -n test.zip -d /tmp
```

查看压缩文件目录，但不解压。

```shell
unzip -v test.zip
```

将压缩文件test.zip在指定目录`/tmp`​下解压缩，如果已有相同的文件存在，要求unzip命令覆盖原先的文件。

```shell
unzip -o test.zip -d tmp/
```

解压指定文件，\* 用作通配符。

```shell
unzip test.zip "*.jpg"
```
