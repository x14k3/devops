
1. gitlab新建项目：新建一个项目，并上传代码
2. 插件（gitlab）：Jenkins 安装 Gitlab 插件
3. 创建任务：Jenkins 创建 freestyle项目，然后配置gitlab仓库对应的地址
	3.1 在 jenkins上面创建密钥对：公钥添加到 gitlab项目对应的用户
	[[devops/Jenkins/Jenkins 使用/assets/608400a8082f7b59d94942c27e87582b_MD5.jpg|gitlab public key]]
![[devops/Jenkins/Jenkins 使用/assets/608400a8082f7b59d94942c27e87582b_MD5.jpg|575]]
	3.2 私钥添加到 jenkins 凭证页面
[[devops/Jenkins/Jenkins 使用/assets/95ddb166f3c8eb0e3a01d2e6644b99da_MD5.jpg|jenkins priv key]]
![[devops/Jenkins/Jenkins 使用/assets/95ddb166f3c8eb0e3a01d2e6644b99da_MD5.jpg|575]]
	3.3 配置gitlab仓库对应的地址、分支、选择之前导入的凭证
[[devops/Jenkins/Jenkins 使用/assets/00e21c45fc6f8b092ec75e378c97f8a4_MD5.jpg|Open: Pasted image 20251121222840.png]]
![[devops/Jenkins/Jenkins 使用/assets/00e21c45fc6f8b092ec75e378c97f8a4_MD5.jpg|600]]
[[devops/Jenkins/Jenkins 使用/assets/f49b50252709fac9988f10065ac44b8c_MD5.jpg|Open: Pasted image 20251121223440.png]]
![[devops/Jenkins/Jenkins 使用/assets/f49b50252709fac9988f10065ac44b8c_MD5.jpg|600]]
4. web：jenkins 构建
[[devops/Jenkins/Jenkins 使用/assets/3301201e2de25d1403474e10a905cb79_MD5.jpg|Open: Pasted image 20251121223459.png]]
![[devops/Jenkins/Jenkins 使用/assets/3301201e2de25d1403474e10a905cb79_MD5.jpg|650]]


## 使用ssh方法拉取（重点）

使用ssh的方法拉取的话先在本地生成公钥和私钥，注意，公钥（id_rsa.pub）保存到gitlab中，私钥（id_rsa）保存到jenkins中

注意：这里要强调一点，有些同学刚开不知道这个公钥和私钥要建在那个服务器上，这个很简单，就是你想在那台服务器上从gitlab中拉取代码，那么你就建在那个服务器上，而我这里是使用Jenkins从gitlab拉取代码，而jenkins又是以docker容器的方式运行的，那么我就在jenkins这个容器中来产生秘钥。