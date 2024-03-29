# shell echo

echo命令的功能是在显示器上显示一段文字，一般起到一个提示的作用。 功能说明:显示文字。

## 语法

```bash
echo [-ne][字符串]

#OPTIONS：
-n	不要在最后自动换行
-e	若字符串中出现以下字符，则特别加以处理，而不会将它当成一般文字输出:

-–help	显示帮助
-–version显示版本信息
```

补充说明

1、echo会将输入的字符串送往标准输出。  
2、输出的字符串间以空白字符隔开,并在最后加上换行号。

‍

### 转义字符

```bash
\a	发出警告声;
\b	删除前一个字符;
\t	插入tab;
\n	换行且光标移至行首;

\c	最后不加上换行符号;
\f	换行但光标仍旧停留在原来的位置;
\r	光标移至行首，但不换行;
\v	与\f相同;
\		插入\字符;
\0nnn	打印nnn(八进制)所代表的ASCII字符;  备注：数字0  不要理解成字母o
\xNN  打印NN(十六进制)所代表的ASCII字符;

#你的进制转换过关吗？
[root@zutuanxue ~]# echo -e "\0123"   #ot(123) = 83  对应ascii表的S
S
[root@zutuanxue ~]# echo -e "\x61"   #ox(61) = 97  对应ascii表的a
a
```

## 输出颜色字体

脚本中echo显示内容带颜色显示,echo显示带颜色，**需要使用参数-e**

格式如下：

```
echo -e "\033[字背景颜色；文字颜色m 字符串\033[0m" 
echo -e "\033[1;36;41m Something here \033[0m"
```

* ​`\033`​ 代表键盘的 `Ctl`​ 键或 `Esc`​ 键
* 1 代表字体行为(高亮，闪烁，下划线等)；
* 36 代表字体的颜色
* 41 的位置代表背景色

### 文字和背景颜色搭配

字体颜色范围是 `30~37`​

```
echo -e "\033[30m 黑色字 \033[0m"
echo -e "\033[31m 红色字 \033[0m"
echo -e "\033[32m 绿色字 \033[0m"
echo -e "\033[33m 黄色字 \033[0m"
echo -e "\033[34m 蓝色字 \033[0m"
echo -e "\033[35m 紫色字 \033[0m"
echo -e "\033[36m 天蓝字 \033[0m"
echo -e "\033[37m 白色字 \033[0m"
```

字体背景颜色范围是 `40~47`​

```bash
echo -e "\033[40;37m 黑底白字 \033[0m" 
echo -e "\033[41;37m 红底白字 \033[0m" 
echo -e "\033[42;37m 绿底白字 \033[0m" 
echo -e "\033[43;37m 黄底白字 \033[0m" 
echo -e "\033[44;37m 蓝底白字 \033[0m" 
echo -e "\033[45;37m 紫底白字 \033[0m" 
echo -e "\033[46;37m 天蓝底白字 \033[0m" 
echo -e "\033[47;30m 白底黑字 \033[0m"
```
