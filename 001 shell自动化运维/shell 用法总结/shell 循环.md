# shell 循环

## for

```bash
#--------------------------------------------------
for package in  bc binutils compat-libcap1 compat-libstdc++ 
do
  yum -y install $package
  # continue命令用于中止本次循环，重新判断循环条件，开始下一次循环。
  # break命令用于跳出循环，使用break可以跳出任何类型的循环
done
# ====================================
array=("bc" "binutils" "compat-libcap1" "compat-libstdc++")
for package in ${array[@]}
```

## while

```bash
while (true)
do
command
# continue命令用于中止本次循环，重新判断循环条件，开始下一次循环。
# break命令用于跳出循环，使用break可以跳出任何类型的循环
done
```
