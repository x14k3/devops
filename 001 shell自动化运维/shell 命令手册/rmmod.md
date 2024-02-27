# rmmod

rmmod[命令](https://www.linuxcool.com/ "命令")来自英文词组“remove module”的缩写，其功能是用于移除内核模块。[Linux](https://www.linuxprobe.com/ "Linux")操作[系统](https://www.linuxdown.com/ "系统")的内核具有模块化的特点，运维人员可以使用rmmod命令移除不需要的内核模块，待有需要时再重新加载回来它们。

**语法格式：** rmmod \[参数\] 模块名

**常用参数：**

```bash
-a 删除所有目前不需要的模块 
-f 强制移除模块而不询问 
-s 将信息写入至日志服务中 
-v 显示执行过程详细信息 
-V 显示版本信息 
-w 确认模块能被删除时再操作
```

**参考示例**

移除指定内核模块并显示过程信息：

```
[root@linuxcool ~]# <strong>rmmod -v bridge</strong>
```

移除指定内核模块并将错误信息写入日志：

```
[root@linuxcool ~]# <strong>rmmod -s bridge</strong>
```

等待模块能够被移除时，然后再进行移除操作：

```
[root@linuxcool ~]# <strong>rmmod -w bridge</strong>
```

强制移除指定内核模块：

```
[root@linuxcool ~]# <strong>rmmod -f bridge</strong>
```

### 与该功能相关的Linux命令：

lsmod

insmod

modprobe
