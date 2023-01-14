

Redis与Memcached的相似之处：
- Redis和Memcached都是内存数据存储系统，都用作内存中的键值数据存储。
- Redis和Memcached都属于NoSQL系列数据管理解决方案，两者都基于键值数据模型。
- Redis和Memcached都将所有数据保存在RAM中，这当然使它们作为缓存层非常有用。

Redis与Memcached的区别：

-  类型
Redis是一个开源的内存数据结构存储系统，用作数据库，缓存和消息代理。
Memcached是一个免费的开源高性能分布式内存对象缓存系统，它通过减少数据库负载来加速动态Web应用程序。

- 数据结构
Redis支持字符串，散列，列表，集合，有序集，位图，超级日志和空间索引；而Memcached支持字符串和整数。

- 执行速度
Memcached的读写速度高于Redis。

- 复制
Memcached不支持复制。而，Redis支持主从复制，允许从属Redis服务器成为主服务器的精确副本；来自任何Redis服务器的数据都可以复制到任意数量的从属服务器。

- 密钥长度
Redis的密钥长度最大为2GB，而Memcached的密钥长度最大为250字节。

- 线程
Redis是单线程的；而，Memcached是多线程的
