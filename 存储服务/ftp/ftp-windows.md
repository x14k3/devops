

## 1.下载安装FileZilla Server

下载地址：[https://www.filezilla.cn/download](https://www.filezilla.cn/download "https://www.filezilla.cn/download")

双击安装：下一步>下一步>下一步...

![|575](assets/image-20221127215025754-20230610173810-mchltgb.png)

## 2.进行配置

点击编辑,选择用户

![|575](assets/image-20221127215030284-20230610173810-t11xzxk.png)

![|575](assets/image-20221127215034831-20230610173810-bkbrxjg.png)

## 3.被动模式

![|575](assets/image-20221127215039466-20230610173810-bl0wnqd.png)

```bash
# 一个细节,在使用FTP命令行打开FTP连接进行通讯的时候，有时候会有这样的响应：

 PORT 192,168,150,80,14,178
 227 Entering Passive Mode (192,168,150,90,195,149)

# 这些响应中，那串数子头4个是IP地址，后两位是表示端口，
# 端口的计算是将第5位数乘以256加上第六位数。如192,168,150,90,195,149，则端口为195*256+149=50069。
```
