# 文件编码转换utf-8

　　‍

　　‍

```bash
codeConv(){
for SQLFILE in `ls $1`
do
  if [ -d ${1}/${SQLFILE} ] ; then
    codeConv ${1}/${SQLFILE}
  else
    file ${1}/${SQLFILE} | grep ISO-8859 > /dev/null
    if [ $? -eq 0 ] ;then
      mv ${1}/${SQLFILE} ${1}/${SQLFILE}.tmp
      echo "开始转换编码: ${1}/${SQLFILE}"
      iconv -f GB2312 -t UTF8 -o ${1}/${SQLFILE} ${1}/${SQLFILE}.tmp
      sleep 1
      rm -rf ${1}/${SQLFILE}.tmp
      echo ""
    else
      echo "无需转换编码: ${1}/${SQLFILE}"
      sleep 1
      echo ""
    fi
  fi
done

}
```
