# shutil 模块

可以使用Python内置的shutil模块实现对文件/文件夹的压缩与解压操作。

## **压缩**

```
import shutil

shutil.make_archive(base_name='root', format='zip', root_dir=r'D:\tmp\web\root')
# base_name:压缩文件名
# format：压缩格式，支持"zip", "tar", "gztar", "bztar", or "xztar"
# root_dir：要压缩的的目录或者具体的文件路径
# 生成的压缩文件会保存在跟你Python脚本同级目录
```

## **解压**

```
import shutil

shutil.unpack_archive(filename=r'D:\tmp\web\root.zip', extract_dir=r'D:\tmp\web\new_root', format='zip')
# filename：要解压的压缩包文件
# extract_dir：解压的路径
# format：压缩文件格式
```

压缩指定目录内的指定文件：

```
import os
from zipfile import ZipFile


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
dir_path = os.path.join(BASE_DIR, '联通')
with ZipFile('to.zip', 'w') as myzip:
    for item in os.listdir(dir_path):
        abs_path = os.path.join(dir_path, item)
        print(abs_path)
        if abs_path.endswith('.py'):
            myzip.write(abs_path)

```

‍
