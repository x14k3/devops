
```bash
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
```

### 常用Homebrew命令

安装Homebrew后，你可以使用以下常用命令来管理软件包：

```sh
brew install <package-name>
brew uninstall <package-name>

brew search <package-name>
brew upgrade <package-name>

# 查看已安装的软件列表
brew list
# 更新Homebrew本身
brew update
# 清理所有包的旧版本
brew cleanup
# 清理指定包的旧版本
brew cleanup <package-name>
```

‍

管理服务

```sh
brew install stunnel
brew install openvpn

brew services start stunnel
brew services start openvpn
brew services start v2ray
brew services info openvpn
```
