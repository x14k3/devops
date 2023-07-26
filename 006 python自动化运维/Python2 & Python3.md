# Python2 & Python3

###  编码

- Python2的默认编码是ASCII码，这是导致Python2中经常遇到编码问题的主要原因之一，至于原因，在于Python这门语言出现的时候，还没有Unicode！
- Python3默认编码是Unicode，因此，不必再文件顶部写# codeing=utf-8了。

```python
# 查看默认编码
# Python2：
import sys
>>>sys.getdefaultencoding()
'ascii'

# Python3:
import sys
>>>sys.getdefaultencoding()
'utf-8'
```

### 字符串

- Python2中，字符串有两种类型，Unicode和str，前者表示文本字符串，后者表示字节序列，但在Python2中并没有严格的界限，所以容易出错。
- Python3中，str表示字符串，byte表示字节序列，任何需要写入文本或者网络传输的数据都只接收字节序列，这就从源头上阻止编码错误的问题。

### True和False

- Python2中true和false是两个全局变量，在数值上对应1和0
- Python3则把true和false指定为关键字，永远指向两个固定的对象，不能被重新赋值

```python
# Python2：
>>> True = False
>>> True
False
>>> True = 1
>>> True
1
>>> False = 'x'
>>> False
'x'

# Python3：
>>> True = False
  File "<stdin>", line 1
SyntaxError: can't assign to keyword
>>> True = 1
  File "<stdin>", line 1
SyntaxError: can't assign to keyword

>>> import keyword
>>> keyword.iskeyword('True')
True
>>> keyword.kwlist
['False', 'None', 'True', 'and', 'as', 'assert', 'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while', 'with', 'yield']
```

### nonlocal

- Python2中无法给嵌套函数中的变量声明为非局部变量，只能使用global关键字声明某个变量为全局变量
- Python3中新增关键字nonlocal，可以解决这一问题

```python
a = 3
def func1():
    a = 1
    def foo():
        a = 2
    foo()
    print(a)  # 1
func1()
def func2():

    a = 1
    def foo():
        nonlocal a
        a = 2
    foo()
    print(a)  # 2
func2()
```

nonlocal

### 语法

- 去除了 <> ，全部使用 !=  # python2两个都可以，python3则只能用 !=
- 去除 '' ，新增repr()
- 新增关键字：as,with,True,False,None
- 整形除法返回浮点数，如想要得到整形结果，使用 //
- 去除print语句，变为print()函数实现相同功能，同样的还有exec语句，改为exec()函数
- 改变了顺序操作符的行为，例如，x > y，当x和y类型不同时则抛出TypeError，而不是返回bool值
- 输入函数由raw\_input改为input
- 去除元组参数解包，不能再def(a,(b,c)):pass这样定义函数
- 新的super()，可以不用传递参数

```python
#Python2
>>> 6 / 2
3
>>> 6 //2
3
>>> 1 <> 2
True
>>> 1 != 2
True
>>> 'a' < 1
False
>>> 'a' < 1
False
>>> 'a' > 1
True

#Python3
>>> 6 / 2
3.0
>>> 6 //2
3
>>> 1 <> 2
  File "<stdin>", line 1
    1 <> 2
       ^
SyntaxError: invalid syntax
>>> 1 != 2
True
>>> 'a' < 1
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: '<' not supported between instances of 'str' and 'int'
```

### 异常

- 异常都继承BaseException
- 用 raise Exception(args)代替 raise Exception, args语法
- 捕获异常的语法改变，引入了as关键字来标识异常实例

### 模块

- 移除cPickle模块，可以使用pickle模块代替
- 移除imageop模块
- 移除bsddb模块
- 移除new模块
- os.tmpnam()和os.tmpfile()函数被移动到tmpfile模块下
- tokenize模块现在使用bytes工作。主要的入口点不再是generate\_tokens，而是 tokenize.tokenize()

### 其它

- xrange()改为range()，要想使用range()获得一个list，必须显示调用：list(range(100))
- bytes对象不能hash，也不支持 b.lower()、b.strip()和b.split()方法，但对于后两者可以使用 b.strip(b’  
  \\n\\t\\r \\f’)和b.split(b’ ‘)来达到相同目的
- zip()、map()和filter()都返回迭代器。而apply()、 callable()、coerce()、 execfile()、reduce()和reload 
  ()函数都被去除了
- Python3中file类被废弃

```python
#Python2
>>> file
<type 'file'>

# Python3
>>> file
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'file' is not defined
```
