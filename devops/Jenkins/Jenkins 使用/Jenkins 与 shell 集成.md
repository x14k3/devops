
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
[[devops/Jenkins/Jenkins 使用/assets/c241e5fff494aef85d11b1801c386d38_MD5.jpg|Open: Pasted image 20251120200540.png]]
![[devops/Jenkins/Jenkins 使用/assets/c241e5fff494aef85d11b1801c386d38_MD5.jpg|525]]

7. 构建设置
[[devops/Jenkins/Jenkins 使用/assets/14560075f12e2edd86c03f32fbfabb82_MD5.jpg|Open: Pasted image 20251120200520.png]]
![[devops/Jenkins/Jenkins 使用/assets/14560075f12e2edd86c03f32fbfabb82_MD5.jpg|575]]

```bash
echo "当前目录是："
pwd
case "$choice" in
	dev) echo "部署到测试环境" ;;
    prod) echo "部署到生产环境" ;;
    *) echo "error，请输入dev & prod" ;;
esac
echo "$record"
```
8. 保存
9. build with parameters
	[[devops/Jenkins/assets/dfd75fef5920f9c8ae4d5da9135667ed_MD5.jpg|Open: Pasted image 20251120194320.png]]
![[devops/Jenkins/assets/dfd75fef5920f9c8ae4d5da9135667ed_MD5.jpg|525]]

[[devops/Jenkins/Jenkins 使用/assets/3ec4573b474a5a51a9572e73197ba57e_MD5.jpg|Open: Pasted image 20251120200332.png]]
![[devops/Jenkins/Jenkins 使用/assets/3ec4573b474a5a51a9572e73197ba57e_MD5.jpg|575]]