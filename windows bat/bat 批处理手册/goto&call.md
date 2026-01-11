

goto很单纯，直接go to 到了某地方，而call则有点调用的意味，调用了，还要返回原位置。
call 从批处理程序调用另一个批处理程序

### goto命令

```
@ echo off
goto label
echo 1
echo 2
:label
echo 3
echo 4
```

输出结果为：

```powershell
3
4
```

### call命令

#### 调用本批处理中的一个标签

```powershell
@ echo off
call :label
echo 1
echo 2
:label
echo 3
echo 4
```

首先，我们看到，用call的时候，label前面的:不能丢掉，否则错误（当然，对于goto而言，你也可以加上:）。
另外，结果也不同，用call的时候结果为：

```powershell
3
4
1
2
3
4
```

#### 调用另一个批处理调用另一个批处理

call的另外一个应用，设test2.bat中的内容为：

```
@ echo off
call test.bat
echo 2
```

test.bat中的内容为：

```
@ echo off
echo 1
```

运行test2.bat, 结果为：

```powershell
1
2
```

如果在被调用的批处理里面有参数，调用的时候需要在后面加上参数。

如：a.bat内容：

```powershell
@echo off
echo %0 %1
b.bat内容：
@echo off
call a.bat hello
dir c:\
pause
```

那么，在执行b.bat的时候，会将hello赋值给%1，而%0代表a.bat自己。

（在批处理中，可以使用%\*代表所有参数%1-%9代表9个参数，%0代表批处理自己，其扩展用法见call /?，在讲for的时候也会讲到）

在这里讲下goto :eof的用法，如：

a.bat内容：

```powershell
@echo off
echo %0 %1
goto :eof
b.bat内容：
@echo off
call a.bat hello
dir c:\
pause
```

这里，在显示完hello后，会执行dir c:\\并暂停，如果将goto :eof改成exit，在显示完hello后就会自动退出。因为goto :eof后会转到a.bat结尾，即只退出a.bat然后会继续执行dir；由于call a.bat，在执行a.bat和b.bat是一个CMD窗口，exit的话就会直接退出这个窗口，这就是goto :eof和exit区别。

#### 调用一个命令

如：call ping 127.1，这和直接ping 127.1看似是一样的，但还是有区别的。主要用法就是call set，在后面讲延迟环境变量的时候慢慢体会。

#### 调用一个应用程序

如：call notepad.exe。call可以这么用，但一般在调用应用程序的时候会使用start，很少用call。

**call和start的区别**
简单来说:call的用处是调用另一个批处理程序，并且终止父批处理程序，只有该批处理执行完才会往下走

而start 是另开 一个窗口(/b状态不弹框)，并且不终止父批处理程序。
注:start严格来说是新增加一个进程。
