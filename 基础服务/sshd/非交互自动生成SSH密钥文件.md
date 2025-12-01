

```bash
#-t指定SSH密钥的算法为RSA算法，-P设置密码，-f指定生成的密钥文件存放位置
read -p "`echo -e "\n\e[1;36m  Please enter the remote host ip : \e[0m"`" remoteHost
read -p "`echo -e "\n\e[1;36m  Please enter the remote host Root Password : \e[0m"`" remotePassword

echo -e "\n\e[1;33m  SSH password-free configuration is in progress, please enter according to the prompts. \e[0m"
rm -rf ~/.ssh/{known_hosts,id_rsa*}
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
yum install -y expect
    expect << EOF
        spawn ssh-copy-id root@${remoteHost}
        expect "connecting (yes/no)? " {send "yes\r"}
        expect "password: " {send "$remotePassword\r"}
        expect "#" {send "exit\r"}
  
EOF
echo -e "\n\e[1;36m  SSH password-free configuration completed. \e[0m"

```
