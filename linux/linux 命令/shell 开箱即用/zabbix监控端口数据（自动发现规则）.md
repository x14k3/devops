
‍

```bash
#!/usr/bin/python
#coding:utf-8  
     
import os, json  
# 声明一个空列表   
port_list=[]# 声明字典（字典是一个个键值对） 
port_dict={"data":None}
# 方式一：被监听的端口（手动设置）
port_active_list=["22","8080","21","8001"]
# 方式二：被监听的端口（自动扫描所有端口）
#cmd='netstat -tnlp|egrep -i "$1"|awk {\'print $4\'}|awk -F\':\' \'{if ($NF~/^[0-9]*$/) print $NF}\'|sort |uniq   2>/dev/null'
# os.popen    打开一个管道或命令。返回值是一个连接到管道的打开的文件对象
# readlines() 读取所有行，并返回列表
# local_ports=os.popen(cmd).readlines()  
     
for port in port_active_list:
# 声明列表中的字典
    pdict={}  
# 赋予字典key和value，将port行尾的换行符去掉
    pdict["{#TCP_PORT}"]=port.replace("\n", "")
# 将多个字典添加到列表  
    port_list.append(pdict)  
# 最后将添加了多个字典的列表再赋值给data字典
# 字典data的值是一个列表[],而列表里面是多个字典{"{#TCP_PORT}": "8001"}   
port_dict["data"]=port_list
# 将python对象编码成Json字符串（字典到json）
# 将数据根据keys的值进行排序
# indent是缩进的意思 
jsonStr = json.dumps(port_dict, sort_keys=True, indent=4)  
     
print jsonStr
```
