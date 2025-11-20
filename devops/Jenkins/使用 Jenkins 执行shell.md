
1. 新建任务
2. 输入任务名称【01-test-streestyle-shell】
3. 选择【构建一个自由风格的软件项目】，保存，下一步
4. 描述
	[[devops/Jenkins/assets/954781db3c69d78634d99f2fc59bacb2_MD5.jpg|Open: Pasted image 20251120193945.png]]
![[devops/Jenkins/assets/954781db3c69d78634d99f2fc59bacb2_MD5.jpg|525]]
5. 丢弃旧的构建
	[[devops/Jenkins/assets/f8793ca57e2cb8f349fcc3f43d216687_MD5.jpg|Open: Pasted image 20251120194014.png]]
![[devops/Jenkins/assets/f8793ca57e2cb8f349fcc3f43d216687_MD5.jpg|500]]
6. 参数化构建过程
	[[devops/Jenkins/assets/9701777f23a9549cdc9520fa78d74e5b_MD5.jpg|Open: Pasted image 20251120194113.png]]
![[devops/Jenkins/assets/9701777f23a9549cdc9520fa78d74e5b_MD5.jpg|500]]
7. 构建设置
	[[devops/Jenkins/assets/26a86bda5a6f3871b5cdbe8d33d2cc42_MD5.jpg|Open: Pasted image 20251120194200.png]]
![[devops/Jenkins/assets/26a86bda5a6f3871b5cdbe8d33d2cc42_MD5.jpg|500]]
```bash
echo "当前目录是："
pwd
case "$choice" in
	dev) echo "部署到测试环境" ;;
    prod) echo "部署到生产环境" ;;
    *) echo "error，请输入dev & prod" ;;
esac
```
8. 保存
9. build with parameters
	[[devops/Jenkins/assets/dfd75fef5920f9c8ae4d5da9135667ed_MD5.jpg|Open: Pasted image 20251120194320.png]]
![[devops/Jenkins/assets/dfd75fef5920f9c8ae4d5da9135667ed_MD5.jpg|525]]

[[devops/Jenkins/assets/39aa7e45708882b4fc66615be3b34dd2_MD5.jpg|Open: Pasted image 20251120194338.png]]
![[devops/Jenkins/assets/39aa7e45708882b4fc66615be3b34dd2_MD5.jpg|650]]