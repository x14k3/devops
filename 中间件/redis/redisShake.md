[RedisShake ](https://tair-opensource.github.io/RedisShake/zh/)是一个用于处理和迁移 Redis 数据的工具，它提供以下特性：

1. **Redis 兼容性**：RedisShake 兼容从 2.8 到 7.2 的 Redis 版本，并支持各种部署方式，包括单机，主从，哨兵和集群。
2. **云服务兼容性**：RedisShake 与主流云服务提供商提供的流行 Redis-like 数据库无缝工作，包括但不限于： 
    - [阿里云-云数据库 Redis 版](https://www.aliyun.com/product/redis)
    - [阿里云-云原生内存数据库Tair](https://www.aliyun.com/product/apsaradb/kvstore/tair)
    - [AWS - ElastiCache](https://aws.amazon.com/elasticache/)
    - [AWS - MemoryDB](https://aws.amazon.com/memorydb/)
3. **Module 兼容**：RedisShake 与 [TairString](https://github.com/tair-opensource/TairString)，[TairZSet](https://github.com/tair-opensource/TairZset) 和 [TairHash](https://github.com/tair-opensource/TairHash) 模块兼容。
4. **多种导出模式**：RedisShake 支持 PSync，RDB 和 Scan 导出模式。
5. **数据处理**：RedisShake 通过自定义脚本实现数据过滤和转换。