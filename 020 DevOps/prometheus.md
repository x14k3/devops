# prometheus

* 📑 [1. Prometheus基础](prometheus/1.%20Prometheus基础.md)

  * 📄 [1.1 prometheus简介](prometheus/1.%20Prometheus基础/1.1%20prometheus简介.md)
  * 📄 [1.2 prometheus部署](prometheus/1.%20Prometheus基础/1.2%20prometheus部署.md)
  * 📄 [1.3 Grafana部署](prometheus/1.%20Prometheus基础/1.3%20Grafana部署.md)
  * 📄 [1.4 prometheus配置](prometheus/1.%20Prometheus基础/1.4%20prometheus配置.md)
  * 📄 [1.5 任务和实例](prometheus/1.%20Prometheus基础/1.5%20任务和实例.md)
  * 📄 [1.6 使用PromQL查询监控数据](prometheus/1.%20Prometheus基础/1.6%20使用PromQL查询监控数据.md)
* 📑 [2. PromQL使用](prometheus/2.%20PromQL使用.md)

  * 📄 [2.1 理解时间序列](prometheus/2.%20PromQL使用/2.1%20理解时间序列.md)
  * 📄 [2.2 Metric类型](prometheus/2.%20PromQL使用/2.2%20Metric类型.md)
  * 📄 [2.3 初识PromQL](prometheus/2.%20PromQL使用/2.3%20初识PromQL.md)
  * 📄 [2.4 PromQL操作符](prometheus/2.%20PromQL使用/2.4%20PromQL操作符.md)
  * 📄 [2.5 PromQL聚合操作](prometheus/2.%20PromQL使用/2.5%20PromQL聚合操作.md)
  * 📄 [2.6 PromQL内置函数](prometheus/2.%20PromQL使用/2.6%20PromQL内置函数.md)
  * 📄 [2.7 在HTTP API中使用PromQL](prometheus/2.%20PromQL使用/2.7%20在HTTP%20API中使用PromQL.md)
  * 📄 [2.8 最佳实践：4个黄金指标和USE方法](prometheus/2.%20PromQL使用/2.8%20最佳实践：4个黄金指标和USE方法.md)
* 📑 [3. Prometheus告警处理](prometheus/3.%20Prometheus告警处理.md)

  * 📄 [3.1 Prometheus告警简介](prometheus/3.%20Prometheus告警处理/3.1%20Prometheus告警简介.md)
  * 📄 [3.2 自定义Prometheus告警规则](prometheus/3.%20Prometheus告警处理/3.2%20自定义Prometheus告警规则.md)
  * 📄 [3.3 部署Alertmanager](prometheus/3.%20Prometheus告警处理/3.3%20部署Alertmanager.md)
  * 📄 [3.4 Alertmanager配置概述](prometheus/3.%20Prometheus告警处理/3.4%20Alertmanager配置概述.md)
  * 📄 [3.5 基于标签的告警路由](prometheus/3.%20Prometheus告警处理/3.5%20基于标签的告警路由.md)
  * 📄 [3.6 内置告警接收器Receiver](prometheus/3.%20Prometheus告警处理/3.6%20内置告警接收器Receiver.md)
  * 📄 [3.7 告警模板详解](prometheus/3.%20Prometheus告警处理/3.7%20告警模板详解.md)
  * 📄 [3.8 屏蔽告警通知](prometheus/3.%20Prometheus告警处理/3.8%20屏蔽告警通知.md)
  * 📄 [3.9 使用Recoding Rules优化性能](prometheus/3.%20Prometheus告警处理/3.9%20使用Recoding%20Rules优化性能.md)
* 📑 [4. Exporter详解](prometheus/4.%20exporter详解.md)

  * 📄 [4.1 exporter是什么](prometheus/4.%20exporter详解/4.1%20exporter是什么.md)
  * 📑 [4.2 常用Exporter](prometheus/4.%20exporter详解/4.2%20常用%20exporter.md)

    * 📄 [容器监控：cAdvisor](prometheus/4.%20exporter详解/4.2%20常用%20exporter/cAdvisor_exporter.md)
    * 📄 [监控MySQL运行状态：MySQLD Exporter](prometheus/4.%20exporter详解/4.2%20常用%20exporter/mysql_exporter.md)
    * 📄 [监控Redis运行状态：Redis Exporter](prometheus/4.%20exporter详解/4.2%20常用%20exporter/redis_exporter.md)
    * 📄 ((20231110105237-y3p3ksg "监控域名与证书过期"))
    * 📄 [网络探测：Blackbox Exporter](prometheus/4.%20exporter详解/4.2%20常用%20exporter/blackbox_exporter.md)
  * 📄 ((20231110105237-m8lwlh2 "4.3 Java自定义Exporter"))
* 📑 [5. 集群与高可用](prometheus/5.%20集群与高可用.md)

  * 📄 [5.1 Prometheus本地存储机制](prometheus/5.%20集群与高可用/5.1%20Prometheus本地存储机制.md)
  * 📄 [5.2 Prometheus远程存储机制](prometheus/5.%20集群与高可用/5.2%20Prometheus远程存储机制.md)
  * 📄 [5.3 Prometheus联邦集群](prometheus/5.%20集群与高可用/5.3%20Prometheus联邦集群.md)
  * 📄 [5.4 Prometheus高可用部署架构](prometheus/5.%20集群与高可用/5.4%20Prometheus高可用部署架构.md)
  * 📄 [5.5 Alertmanager高可用部署架构](prometheus/5.%20集群与高可用/5.5%20Alertmanager高可用部署架构.md)
* 📑 [6. Prometheus服务发现](prometheus/6.%20Prometheus服务发现.md)

  * 📄 [6.1 基于文件的服务发现](prometheus/6.%20Prometheus服务发现/6.1%20基于文件的服务发现.md)
  * 📄 [6.2 基于Consul的服务发现](prometheus/6.%20Prometheus服务发现/6.2%20基于Consul的服务发现.md)
  * 📄 [6.3 服务发现与Relabeling](prometheus/6.%20Prometheus服务发现/6.3%20服务发现与Relabeling.md)
* 📄 [7. 监控Kubernetes](prometheus/7.%20监控Kubernetes.md)

‍
