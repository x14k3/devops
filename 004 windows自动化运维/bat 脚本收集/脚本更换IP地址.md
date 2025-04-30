# 脚本更换IP地址

```bat
@echo off & setlocal enabledelayedexpansion
color 0a

::获取管理者权限运行
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit

::获取网卡名称
:Ethernet
echo 获取网卡名称
set m=0
for /f "tokens=1* delims=," %%a in ('Getmac /v /nh /fo csv') do (
set /a m+=1
set "name!m!=%%a"
set "name=%name:~1,-1%"
)
:Select_Card
echo. & echo 1:!name1! & echo 2:!name2! & echo 3:!name3! & echo 4:!name4! & echo 5:!name5! & echo.
set /p "Select_Card=选择网卡[最多五张]:"
if "%Select_Card%" == "1" ( set card=!name1! ) else (
if "%Select_Card%" == "2" ( set card=!name2! ) else (
if "%Select_Card%" == "3" ( set card=!name3! ) else (if "%Select_Card%" == "4" ( set card=!name4! ) else (
if "%Select_Card%" == "5" ( set card=!name5! ) else ( echo. & echo 未键入任何参数! & pause>nul & cls & goto :Select_Card )))))
rem echo. & echo 选择网卡:%card% 
set NAME=%card%

::菜单选择
:menu
echo ==============================
echo        脚本更换IP地址
echo.☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★
echo ★        ★☆菜单☆★                    ☆
echo ☆      1.动态获取IP地址                  ★
echo ★      2.静态IP地址设置                  ☆
echo ☆      3.设置固定IP地址                  ★
echo ☆      4.网卡重新选择                    ★
echo ★      5.退出                            ☆
echo.☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★
set /p ID=请输入选择项目的序号：
if "%ID%"=="1" goto AUTO
if "%ID%"=="2" goto SETUP
if "%ID%"=="3" goto TSGZ
if "%ID%"=="4" goto Ethernet
if "%ID%"=="5" goto EXIT
echo 您没有选择修改方式。
goto menu

::动态获取
:AUTO
netsh interface ip set address name=%NAME% source=dhcp

ipconfig /flushdns
timeout /nobreak /t 5 >nul 2>&1
goto MYIP

::手动设置
:SETUP
set /p IP1=请输入IP地址：
set /p MASK1=请输入MASK地址：
set /p GATEWAY1=请输入GATEWAY地址：
set /p DNS1=请输入DNS1地址：
set /p DNS2=请输入DNS2地址：
if (%GATEWAY1%)==() (
goto NOTGATEWAY
)else (
goto YESGATEWAY
)
::不设置网关
:NOTGATEWAY
for /f "tokens=16" %%i in ('ipconfig ^|find /i "ipv4"') do (
set NEWIP=%%i
goto out
)
:out
netsh interface ip delete address %NAME%  addr=%NEWIP% gateway=all >nul 2>&1
netsh interface ip delete dns %NAME% all >nul 2>&1
netsh interface ip set address name=%NAME% source=static addr=%IP1% mask=%MASK1%
netsh interface ip set dns name=%NAME%  source=static addr=%DNS1% >null register=PRIMARY
netsh interface ip add dns name=%NAME% addr=%DNS2% >null  index=2
ipconfig /flushdns
timeout /nobreak /t 5 >nul 2>&1
goto MYIP
::设置网关
:YESGATEWAY
netsh interface ip delete dns %NAME% all >nul 2>&1
netsh interface ip set address name=%NAME% source=static addr=%IP1% mask=%MASK1% gateway=%GATEWAY1% gwmetric=1
netsh interface ip set dns name=%NAME%  source=static addr=%DNS1% >null register=PRIMARY
netsh interface ip add dns name=%NAME% addr=%DNS2% >null  index=2
ipconfig /flushdns
timeout /nobreak /t 5 >nul 2>&1
goto MYIP

::固定IP
:TSGZ
for /f "tokens=16" %%i in ('ipconfig ^|find /i "ipv4"') do (
set NEWIP=%%i
goto out1
)
:out1
netsh interface ip delete address %NAME%  addr=%NEWIP% gateway=all >nul 2>&1
netsh interface ip set address name=%NAME% source=static addr=192.168.1.1 mask=255.255.255.0 >nul 2>&1
netsh interface ip delete dns %NAME% all >nul 2>&1
timeout /nobreak /t 5 >nul 2>&1
goto MYIP

::退出
:EXIT
timeout /nobreak /t 5
exit

::获取当前IP
:MYIP
for /f "tokens=16" %%i in ('ipconfig ^|find /i "ipv4"') do (set myip=%%i)
for /f "tokens=15" %%m in ('ipconfig ^|findstr "子网掩码"') do (set mymask=%%m)
for /f "tokens=15" %%g in ('ipconfig ^|findstr "默认网关"') do (set mygw=%%g)
echo IP地址：%myip%
echo 子网掩码：%mymask%
echo 默认网关：%mygw%
echo 更改IP地址完成！
goto menu
```
