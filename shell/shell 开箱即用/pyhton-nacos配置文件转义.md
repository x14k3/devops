

‍

```bash
#!/bin/python
import sys
import os
import urllib
nacosFilePath='/tmp/nacos'
nacosFiles = os.listdir(nacosFilePath)
for fileName in nacosFiles:
    with open(nacosFilePath + '/' + fileName,'r+w') as f:
        text = f.read()
        urltext = urllib.quote(text.decode(sys.stdin.encoding).encode('utf8'))
        f.seek(0)
        f.write(urltext)
  
-------------------------------------------------------------------------------------------------------------
gener_bs_nacosFiles(){
  if [[ -f ${SUB_SCRIPT}/bs_nacos_alter_mysql.sh ]]; then
    sh ${SUB_SCRIPT}/bs_nacos_alter_mysql.sh
    mkdir -p ${MIC_LOG_PATH}/{appService,bank,account,gateway,gds,listeners,payService,master,internal-bank,cash,derivatives,budget,ecd,custom,tss,task-admin,task-execute}
  python -V
  if [ $? == 0 ];then
mkdir -p /tmp/nacos
cp ${MIC_CONFIG_PATH_MYSQL}/* /tmp/nacos/
sed -i "/^nacosFilePath/cnacosFilePath='/tmp/nacos'" ${SUB_SCRIPT}/setNacosFile.py
/usr/bin/python ${SUB_SCRIPT}/setNacosFile.py
sleep 5
TMP_NACOS_account=`cat /tmp/nacos/account`
TMP_NACOS_appService=`cat /tmp/nacos/appService`
TMP_NACOS_bank=`cat /tmp/nacos/bank`
TMP_NACOS_budget=`cat /tmp/nacos/budget`
TMP_NACOS_cash=`cat /tmp/nacos/cash`
TMP_NACOS_custom=`cat /tmp/nacos/custom`
TMP_NACOS_derivatives=`cat /tmp/nacos/derivatives`
TMP_NACOS_ecd=`cat /tmp/nacos/ecd`
TMP_NACOS_gateway=`cat /tmp/nacos/gateway`
TMP_NACOS_gds=`cat /tmp/nacos/gds`
TMP_NACOS_internalBank=`cat /tmp/nacos/internalBank`
TMP_NACOS_listeners=`cat /tmp/nacos/listeners`
TMP_NACOS_master=`cat /tmp/nacos/master`
TMP_NACOS_payService=`cat /tmp/nacos/payService`
TMP_NACOS_task_admin=`cat /tmp/nacos/task-admin`
TMP_NACOS_task_execute=`cat /tmp/nacos/task-execute`
TMP_NACOS_tss=`cat /tmp/nacos/tss`

# 创建空间
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/console/namespaces" -d "customNamespaceId=${NACOS_SPACE}&namespaceName=${NACOS_SPACE}&namespaceDesc=${NACOS_SPACE}"
# 导入配置
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=account&group=DEFAULT_GROUP&content=${TMP_NACOS_account}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=appService&group=DEFAULT_GROUP&content=${TMP_NACOS_appService}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=bank&group=DEFAULT_GROUP&content=${TMP_NACOS_bank}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=budget&group=DEFAULT_GROUP&content=${TMP_NACOS_budget}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=cash&group=DEFAULT_GROUP&content=${TMP_NACOS_cash}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=custom&group=DEFAULT_GROUP&content=${TMP_NACOS_custom}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=derivatives&group=DEFAULT_GROUP&content=${TMP_NACOS_derivatives}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=ecd&group=DEFAULT_GROUP&content=${TMP_NACOS_ecd}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=gateway&group=DEFAULT_GROUP&content=${TMP_NACOS_gateway}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=gds&group=DEFAULT_GROUP&content=${TMP_NACOS_gds}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=internalBank&group=DEFAULT_GROUP&content=${TMP_NACOS_internalBank}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=listeners&group=DEFAULT_GROUP&content=${TMP_NACOS_listeners}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=master&group=DEFAULT_GROUP&content=${TMP_NACOS_master}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=payService&group=DEFAULT_GROUP&content=${TMP_NACOS_payService}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=task-admin&group=DEFAULT_GROUP&content=${TMP_NACOS_task_admin}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=task-execute&group=DEFAULT_GROUP&content=${TMP_NACOS_task_execute}"
curl -X POST "http://${NACOS_IP}:${NACOS_PORT}/nacos/v1/cs/configs?tenant=${NACOS_SPACE}&dataId=tss&group=DEFAULT_GROUP&content=${TMP_NACOS_tss}"
rm -rf /tmp/nacos
    echo -e "\n\e[1;36m naocs 配置完成 \n \e[0m"
    sleep 2
```
