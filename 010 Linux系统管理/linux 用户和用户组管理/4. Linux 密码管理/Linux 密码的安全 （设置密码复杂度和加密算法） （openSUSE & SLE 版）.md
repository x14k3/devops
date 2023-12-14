# Linux 密码的安全 （设置密码复杂度和加密算法） （openSUSE & SLE 版）

### 步骤一：修改 /etc/pam.d/common-password-pc 配置文件

```
# vim /etc/pam.d/common-password-pc
```

将以下内容：

```
......
passwordrequisitepam_cracklib.so ......
......
```

修改为：

```
......
password        requisite       pam_cracklib.so try_first_pass local_users_only enforce-for-root minlen=15 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 maxrepeat=5 retry=3 difok=3 remember=5
......
```

并添加以下内容：

```
......
password    requisite     pam_pwhistory.so try_first_pass local_users_only enforce-for-root remember=5 use_authtok
password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok remember=24 use_authtok
```

（
补充：这里以

1. pam_cracklib.so 模块使用前 1 个模块从用户那里得到的密码 （try_first_pass）
2. 只作用于本地用户 （local_users_only）
3. 也作用于 root 用户 （enforce-for-root）
4. 密码最小长度为 15 个字符 （minlen=15）
5. 密码必须包含数字的个数 （dcredit=-1）
6. 密码必须包含大写字母的个数 （ucredit=-1）
7. 密码必须包含小写字母的个数 （lcredit=-1）
8. 密码必须包含特殊字符的个数 （ocredit=-1）
9. 最多只允许 5 个连续字符 （maxrepeat=5，如果是 0 则禁用该选项）
10. 3 次尝试错误密码后产生错误提示 （retry=3）
11. 新密码最多可以有 3 个字符和旧密码相同 （difok=3）
12. 新密码不能和最近用过的 24 个密码相同 （remember=24）
13. 使用 sha512 加密方法加密 （sha512）
     为例
     ）

### 步骤二：修改 /etc/security/pwquality.conf 配置文件

```
# vim /etc/security/pwquality.conf
```

将部分内容修改如下：

```
......
minlen = 15
......
dcredit = -1
......
ucredit = -1
......
lcredit = -1
......
ocredit = -1
......
dictcheck = 1
......
usercheck = 1
......
maxrepeat = 5
......
retry = 3
......
difok = 3
......
```

（
补充：这里以

1. 密码最小长度为 15 个字符 （minlen = 15）
2. 密码必须包含数字的个数 （dcredit = -1）
3. 密码必须包含大写字母的个数 （ucredit = -1）
4. 密码必须包含小写字母的个数 （lcredit = -1）
5. 密码必须包含特殊字符的个数 （ocredit = -1）
6. 密码不能包含字典 （dictcheck = 1）
7. 密码不能包含用户 （usercheck = 1）
8. 新密码不能和前 5 个老密码重复 （maxrepeat=5）
9. 3 次尝试错误密码后产生错误提示 （retry=3）
10. 新密码最多可以有 3 个字符和旧密码相同 （difok=3）
     为例
     ）

### 步骤三：修改 /etc/login.defs 配置文件

```
# vim /etc/login.defs
```

将以下内容：

```
......
ENCRYPT_METHOD ......
......
```

修改为：

```
......
ENCRYPT_METHOD SHA512
......
```

（补充：这里以使用 SHA512 哈希算法加密密码为例）
