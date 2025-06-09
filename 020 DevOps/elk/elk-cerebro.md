# elk-cerebro

- 下载地址

  [https://github.com/lmenezes/cerebro/releases](https://github.com/lmenezes/cerebro/releases "https://github.com/lmenezes/cerebro/releases")
- 下载zip解压

  `unzip  -qd  /data/  cerebro-0.9.4.zip`
- 修改配置

  `vim /data/cerebro-0.9.4/conf/application.conf `

  ```bash
  # elasticsearch节点
  hosts = [
    {
      host = "http://localhost:9200"
    }
  ]
  ```
- 启动

  ```bash
  nohup /data/cerebro-0.9.4/bin/cerebro >> /data/logs/cerebor.log 2>&1 &
  ```
- 访问

  [http://192.168.10.142:9000/](http://192.168.10.142:9000/ "http://192.168.10.142:9000/")
