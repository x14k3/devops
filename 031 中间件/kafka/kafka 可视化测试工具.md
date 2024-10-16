# kafka 可视化测试工具

```docker
#下载镜像：
docker pull provectuslabs/kafka-ui:latest


#拉起docker：
docker run --name=kafka-ui -d \
-e KAFKA_CLUSTERS_0_NAME=local-kafka \
-e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=192.168.133.11:9092 -p 8080:8080 \
provectuslabs/kafka-ui:latest
```

　　‍
