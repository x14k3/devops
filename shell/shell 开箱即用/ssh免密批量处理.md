

```bash
#!/usr/bin/expect -f
#author:eryajf
#time:2018-8
foreach ip {
10.0.0.21
10.0.0.22
10.0.0.23
10.0.0.20
} {
set timeout 15
spawn ssh-copy-id -i .ssh/id_rsa.pub $ip
expect {
    "yes/no" {send "yes\r";}
    "password:" {send "123456\r";}
}
sleep 1
}
===========================================
expect  xxxx.sh
```

‍
