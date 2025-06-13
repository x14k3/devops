

## 键（Key）命令

Redis 是 key-value 型数据库，键（Key）命令是 Redis 中经常使用的命令。常用的键命令如下所示：

|命令|描述|示例|
| :-----| :------------------------------------------------------| ------|
|[DEL](https://redis.com.cn/commands/del.html)|用于删除 key|​`redis 127.0.0.1:6379> DEL KEY_NAME`​|
|[DUMP](https://redis.com.cn/commands/dump.html)|序列化给定 key ，并返回被序列化的值|​`redis 127.0.0.1:6379> DUMP KEY_NAME`​|
|[EXISTS](https://redis.com.cn/commands/exists.html)|检查给定 key 是否存在|​`redis 127.0.0.1:6379> EXISTS KEY_NAME`​|
|[EXPIRE](https://redis.com.cn/commands/expire.html)|为给定 key 设置过期时间|​`redis 127.0.0.1:6379> EXPIRE key seconds`​|
|[EXPIREAT](https://redis.com.cn/commands/expireat.html)|用于为 key 设置过期时间，接受的时间参数是 UNIX 时间戳||
|[PEXPIRE](https://redis.com.cn/commands/pexpire.html)|设置 key 的过期时间，以毫秒计||
|[PEXPIREAT](https://redis.com.cn/commands/pexpireat.html)|设置 key 过期时间的时间戳(unix timestamp)，以毫秒计||
|[KEYS](https://redis.com.cn/commands/keys.html)|查找所有符合给定模式的 key||
|[MOVE](https://redis.com.cn/commands/move.html)|将当前数据库的 key 移动到给定的数据库中||
|[PERSIST](https://redis.com.cn/commands/persist.html)|移除 key 的过期时间，key 将持久保持||
|[PTTL](https://redis.com.cn/commands/pttl.html)|以毫秒为单位返回 key 的剩余的过期时间||
|[TTL](https://redis.com.cn/commands/ttl.html)|以秒为单位，返回给定 key 的剩余生存时间(||
|[RANDOMKEY](https://redis.com.cn/commands/randomkey.html)|从当前数据库中随机返回一个 key||
|[RENAME](https://redis.com.cn/commands/rename.html)|修改 key 的名称||
|[RENAMENX](https://redis.com.cn/commands/renamenx.html)|仅当 newkey 不存在时，将 key 改名为 newkey||
|[TYPE](https://redis.com.cn/commands/type.html)|返回 key 所储存的值的类型||

## String 命令

Strings（字符串）结构是 Redis 的基本数据类型，值value是字符串类型，常用命令：

|命令|描述|
| :-----| :------------------------------------------------------------|
|[SET](https://redis.com.cn/commands/set.html)|设置指定 key 的值|
|[GET](https://redis.com.cn/commands/get.html)|获取指定 key 的值|
|[GETRANGE](https://redis.com.cn/commands/getrange.html)|返回 key 中字符串值的子字符|
|[GETSET](https://redis.com.cn/commands/getset.html)|将给定 key 的值设为 value ，并返回 key 的旧值 ( old value )|
|[GETBIT](https://redis.com.cn/commands/getbit.html)|对 key 所储存的字符串值，获取指定偏移量上的位 ( bit )|
|[MGET](https://redis.com.cn/commands/mget.html)|获取所有(一个或多个)给定 key 的值|
|[SETBIT](https://redis.com.cn/commands/setbit.html)|对 key 所储存的字符串值，设置或清除指定偏移量上的位(bit)|
|[SETEX](https://redis.com.cn/commands/setex.html)|设置 key 的值为 value 同时将过期时间设为 seconds|
|[SETNX](https://redis.com.cn/commands/setnx.html)|只有在 key 不存在时设置 key 的值|
|[SETRANGE](https://redis.com.cn/commands/setrange.html)|从偏移量 offset 开始用 value 覆写给定 key 所储存的字符串值|
|[STRLEN](https://redis.com.cn/commands/strlen.html)|返回 key 所储存的字符串值的长度|
|[MSET](https://redis.com.cn/commands/mset.html)|同时设置一个或多个 key-value 对|
|[MSETNX](https://redis.com.cn/commands/msetnx.html)|同时设置一个或多个 key-value 对|
|[PSETEX](https://redis.com.cn/commands/psetex.html)|以毫秒为单位设置 key 的生存时间|
|[INCR](https://redis.com.cn/commands/incr.html)|将 key 中储存的数字值增一|
|[INCRBY](https://redis.com.cn/commands/incrby.html)|将 key 所储存的值加上给定的增量值 ( increment )|
|[INCRBYFLOAT](https://redis.com.cn/commands/incrbyfloat.html)|将 key 所储存的值加上给定的浮点增量值 ( increment )|
|[DECR](https://redis.com.cn/commands/decr.html)|将 key 中储存的数字值减一|
|[DECRBY](https://redis.com.cn/commands/decrby.html)|将 key 所储存的值减去给定的减量值 ( decrement )|
|[APPEND](https://redis.com.cn/commands/append.html)|将 value 追加到 key 原来的值的末尾|

## Hash 命令

Hash（哈希散列）是 Redis 基本数据类型，值value 中存储的是 hash 表。Hash 特别适合用于存储对象。常用的命令：

|命令|说明|
| ------| -----------------------------------------------|
|[HDEL](https://redis.com.cn/commands/hdel.html)|用于删除哈希表中一个或多个字段|
|[HEXISTS](https://redis.com.cn/commands/hexists.html)|用于判断哈希表中字段是否存在|
|[HGET](https://redis.com.cn/commands/hget.html)|获取存储在哈希表中指定字段的值|
|[HGETALL](https://redis.com.cn/commands/hgetall.html)|获取在哈希表中指定 key 的所有字段和值|
|[HINCRBY](https://redis.com.cn/commands/hincrby.html)|为存储在 key 中的哈希表指定字段做整数增量运算|
|[HKEYS](https://redis.com.cn/commands/hkeys.html)|获取存储在 key 中的哈希表的所有字段|
|[HLEN](https://redis.com.cn/commands/hlen.html)|获取存储在 key 中的哈希表的字段数量|
|[HSET](https://redis.com.cn/commands/hset.html)|用于设置存储在 key 中的哈希表字段的值|
|[HVALS](https://redis.com.cn/commands/hvals.html)|用于获取哈希表中的所有值|

## List 命令

List 是 Redis 中最常用数据类型。值value 中存储的是列表。：

|命令|描述|
| :-----| :---------------------------------------------------------|
|[BLPOP](https://redis.com.cn/commands/blpop.html)|移出并获取列表的第一个元素|
|[BRPOP](https://redis.com.cn/commands/brpop.html)|移出并获取列表的最后一个元素|
|[BRPOPLPUSH](https://redis.com.cn/commands/brpoplpush.html)|从列表中弹出一个值，并将该值插入到另外一个列表中并返回它|
|[LINDEX](https://redis.com.cn/commands/lindex.html)|通过索引获取列表中的元素|
|[LINSERT](https://redis.com.cn/commands/linsert.html)|在列表的元素前或者后插入元素|
|[LLEN](https://redis.com.cn/commands/llen.html)|获取列表长度|
|[LPOP](https://redis.com.cn/commands/lpop.html)|移出并获取列表的第一个元素|
|[LPUSH](https://redis.com.cn/commands/lpush.html)|将一个或多个值插入到列表头部|
|[LPUSHX](https://redis.com.cn/commands/lpushx.html)|将一个值插入到已存在的列表头部|
|[LRANGE](https://redis.com.cn/commands/lrange.html)|获取列表指定范围内的元素|
|[LREM](https://redis.com.cn/commands/lrem.html)|移除列表元素|
|[LSET](https://redis.com.cn/commands/lset.html)|通过索引设置列表元素的值|
|[LTRIM](https://redis.com.cn/commands/ltrim.html)|对一个列表进行修剪(trim)|
|[RPOP](https://redis.com.cn/commands/rpop.html)|移除并获取列表最后一个元素|
|[RPOPLPUSH](https://redis.com.cn/commands/rpoplpush.html)|移除列表的最后一个元素，并将该元素添加到另一个列表并返回|
|[RPUSH](https://redis.com.cn/commands/rpush.html)|在列表中添加一个或多个值|
|[RPUSHX](https://redis.com.cn/commands/rpushx.html)|为已存在的列表添加值|

## Set 命令

|命令|描述|
| :-----| :----------------------------------------------------|
|[SADD](https://redis.com.cn/commands/sadd.html)|向集合添加一个或多个成员|
|[SCARD](https://redis.com.cn/commands/scard.html)|获取集合的成员数|
|[SDIFF](https://redis.com.cn/commands/sdiff.html)|返回给定所有集合的差集|
|[SDIFFSTORE](https://redis.com.cn/commands/sdiffstore.html)|返回给定所有集合的差集并存储在 destination 中|
|[SINTER](https://redis.com.cn/commands/sinter.html)|返回给定所有集合的交集|
|[SINTERSTORE](https://redis.com.cn/commands/sinterstore.html)|返回给定所有集合的交集并存储在 destination 中|
|[SISMEMBER](https://redis.com.cn/commands/sismember.html)|判断 member 元素是否是集合 key 的成员|
|[SMEMBERS](https://redis.com.cn/commands/smembers.html)|返回集合中的所有成员|
|[SMOVE](https://redis.com.cn/commands/smove.html)|将 member 元素从 source 集合移动到 destination 集合|
|[SPOP](https://redis.com.cn/commands/spop.html)|移除并返回集合中的一个随机元素|
|[SRANDMEMBER](https://redis.com.cn/commands/srandmember.html)|返回集合中一个或多个随机数|
|[SREM](https://redis.com.cn/commands/srem.html)|移除集合中一个或多个成员|
|[SUNION](https://redis.com.cn/commands/sunion.html)|返回所有给定集合的并集|
|[SUNIONSTORE](https://redis.com.cn/commands/sunionstore.html)|所有给定集合的并集存储在 destination 集合中|
|[SSCAN](https://redis.com.cn/commands/sscan.html)|迭代集合中的元素|

## Zset 命令

下表列出了 Redis 有序集合的基本命令

|命令|描述|
| :-----| :--------------------------------------------------------------------|
|[ZADD](https://redis.com.cn/commands/zadd.html)|向有序集合添加一个或多个成员，或者更新已存在成员的分数|
|[ZCARD](https://redis.com.cn/commands/zcard.html)|获取有序集合的成员数|
|[ZCOUNT](https://redis.com.cn/commands/zcount.html)|计算在有序集合中指定区间分数的成员数|
|[ZINCRBY](https://redis.com.cn/commands/zincrby.html)|有序集合中对指定成员的分数加上增量 increment|
|[ZINTERSTORE](https://redis.com.cn/commands/zinterstore.html)|计算给定的一个或多个有序集的交集并将结果集存储在新的有序集合 key 中|
|[ZLEXCOUNT](https://redis.com.cn/commands/zlexcount.html)|在有序集合中计算指定字典区间内成员数量|
|[ZRANGE](https://redis.com.cn/commands/zrange.html)|通过索引区间返回有序集合成指定区间内的成员|
|[ZRANGEBYLEX](https://redis.com.cn/commands/zrangebylex.html)|通过字典区间返回有序集合的成员|
|[ZRANGEBYSCORE](https://redis.com.cn/commands/zrangebyscore.html)|通过分数返回有序集合指定区间内的成员|
|[ZRANK](https://redis.com.cn/commands/zrank.html)|返回有序集合中指定成员的索引|
|[ZREM](https://redis.com.cn/commands/zrem.html)|移除有序集合中的一个或多个成员|
|[ZREMRANGEBYLEX](https://redis.com.cn/commands/zremrangebylex.html)|移除有序集合中给定的字典区间的所有成员|
|[ZREMRANGEBYRANK](https://redis.com.cn/commands/zremrangebyrank.html)|移除有序集合中给定的排名区间的所有成员|
|[ZREMRANGEBYSCORE](https://redis.com.cn/commands/zremrangebyscore.html)|移除有序集合中给定的分数区间的所有成员|
|[ZREVRANGE](https://redis.com.cn/commands/zrevrange.html)|返回有序集中指定区间内的成员，通过索引，分数从高到底|
|[ZREVRANGEBYSCORE](https://redis.com.cn/commands/zrevrangebyscore.html)|返回有序集中指定分数区间内的成员，分数从高到低排序|
|[ZREVRANK](https://redis.com.cn/commands/zrevrank.html)|返回有序集合中指定成员的排名，有序集成员按分数值递减(从大到小)排序|
|[ZSCORE](https://redis.com.cn/commands/zscore.html)|返回有序集中，成员的分数值|
|[ZUNIONSTORE](https://redis.com.cn/commands/zunionstore.html)|计算一个或多个有序集的并集，并存储在新的 key 中|
|[ZSCAN](https://redis.com.cn/commands/zscan.html)|迭代有序集合中的元素（包括元素成员和元素分值）|

## Redis 管理 redis 服务相关命令

下表列出了管理 redis 服务相关的命令

|命令|描述|
| :-----| :-------------------------------------------------|
|[BGREWRITEAOF](https://redis.com.cn/commands/bgrewriteaof.html)|异步执行一个 AOF（AppendOnly File） 文件重写操作|
|[BGSAVE](https://redis.com.cn/commands/bgsave.html)|在后台异步保存当前数据库的数据到磁盘|
|[CLIENT](https://redis.com.cn/commands/client-kill.html)|关闭客户端连接|
|[CLIENT LIST](https://redis.com.cn/commands/client-list.html)|获取连接到服务器的客户端连接列表|
|[CLIENT GETNAME](https://redis.com.cn/commands/client-getname.html)|获取连接的名称|
|[CLIENT PAUSE](https://redis.com.cn/commands/client-pause.html)|在指定时间内终止运行来自客户端的命令|
|[CLIENT SETNAME](https://redis.com.cn/commands/client-setname.html)|设置当前连接的名称|
|[CLUSTER SLOTS](https://redis.com.cn/commands/cluster-slots.html)|获取集群节点的映射数组|
|[COMMAND](https://redis.com.cn/commands/command.html)|获取 Redis 命令详情数组|
|[COMMAND COUNT](https://redis.com.cn/commands/command-count.html)|获取 Redis 命令总数|
|[COMMAND GETKEYS](https://redis.com.cn/commands/command-getkeys.html)|获取给定命令的所有键|
|[TIME](https://redis.com.cn/commands/time.html)|返回当前服务器时间|
|[COMMAND INFO](https://redis.com.cn/commands/command-info.html)|获取指定 Redis 命令描述的数组|
|[CONFIG GET](https://redis.com.cn/commands/config-get.html)|获取指定配置参数的值|
|[CONFIG REWRITE](https://redis.com.cn/commands/config-rewrite.html)|修改 redis.conf 配置文件|
|[CONFIG SET](https://redis.com.cn/commands/config-set.html)|修改 redis 配置参数，无需重启|
|[CONFIG RESETSTAT](https://redis.com.cn/commands/config-resetstat.html)|重置 INFO 命令中的某些统计数据|
|[DBSIZE](https://redis.com.cn/commands/dbsize.html)|返回当前数据库的 key 的数量|
|[DEBUG OBJECT](https://redis.com.cn/commands/debug-object.html)|获取 key 的调试信息|
|[DEBUG SEGFAULT](https://redis.com.cn/commands/debug-segfault.html)|让 Redis 服务崩溃|
|[FLUSHALL](https://redis.com.cn/commands/flushall.html)|删除所有数据库的所有 key|
|[FLUSHDB](https://redis.com.cn/commands/flushdb.html)|删除当前数据库的所有 key|
|[INFO](https://redis.com.cn/commands/info.html)|获取 Redis 服务器的各种信息和统计数值|
|[LASTSAVE](https://redis.com.cn/commands/lastsave.html)|返回最近一次 Redis 成功将数据保存到磁盘上的时间|
|[MONITOR](https://redis.com.cn/commands/monitor.html)|实时打印出 Redis 服务器接收到的命令，调试用|
|[ROLE](https://redis.com.cn/commands/role.html)|返回主从实例所属的角色|
|[SAVE](https://redis.com.cn/commands/save.html)|异步保存数据到硬盘|
|[SHUTDOWN](https://redis.com.cn/commands/shutdown.html)|异步保存数据到硬盘，并关闭服务器|
|[SLAVEOF](https://redis.com.cn/commands/slaveof.html)|将当前服务器转变从属服务器(slave server)|
|[SLOWLOG](https://redis.com.cn/commands/showlog.html)|管理 redis 的慢日志|
|[SYNC](https://redis.com.cn/commands/sync.html)|用于复制功能 ( replication ) 的内部命令|

## Redis 发布订阅命令

下表列出了列表相关命令：

|命令|描述|
| :-----| :-----------------------------------|
|[PSUBSCRIBE](https://redis.com.cn/commands/psubscribe.html)|订阅一个或多个符合给定模式的频道。|
|[PUBSUB](https://redis.com.cn/commands/pubsub.html)|查看订阅与发布系统状态。|
|[PUBLISH](https://redis.com.cn/commands/publish.html)|将信息发送到指定的频道。|
|[PUNSUBSCRIBE](https://redis.com.cn/commands/punsubscribe.html)|退订所有给定模式的频道。|
|[SUBSCRIBE](https://redis.com.cn/commands/subscribe.html)|订阅给定的一个或多个频道的信息。|
|[UNSUBSCRIBE](https://redis.com.cn/commands/unsubscribe.html)|指退订给定的频道。|

## Redis 事务命令

下表列出了 Redis 事务的相关命令

|命令|描述|
| :-----| :-------------------------------------|
|[DISCARD](https://redis.com.cn/commands/discard.html)|取消事务，放弃执行事务块内的所有命令|
|[EXEC](https://redis.com.cn/commands/exec.html)|执行所有事务块内的命令|
|[MULTI](https://redis.com.cn/commands/multi.html)|标记一个事务块的开始|
|[UNWATCH](https://redis.com.cn/commands/unwatch.html)|取消 WATCH 命令对所有 key 的监视|
|[WATCH](https://redis.com.cn/commands/watch.html)|监视一个(或多个) key|

## Redis 连接命令

下表列出了用于 Redis 连接相关的命令

|命令|描述|
| :-----| :-------------------|
|[AUTH password](https://redis.com.cn/commands/auth.html)|验证密码是否正确|
|[ECHO message](https://redis.com.cn/commands/echo.html)|打印字符串|
|[PING](https://redis.com.cn/commands/ping.html)|查看服务是否运行|
|[QUIT](https://redis.com.cn/commands/quit.html)|关闭当前连接|
|[SELECT index](https://redis.com.cn/commands/select.html)|切换到指定的数据库|

## Redis 脚本 命令

|命令|描述|
| ------| ----------------------------------------------------------|
|[SCRIPT KILL](https://redis.com.cn/commands/script-kill.html)|杀死当前正在运行的 Lua 脚本。|
|[SCRIPT LOAD](https://redis.com.cn/commands/script-load.html)|将脚本 script 添加到脚本缓存中，但并不立即执行这个脚本。|
|[EVAL](https://redis.com.cn/commands/eval.html)|执行 Lua 脚本。|
|[EVALSHA](https://redis.com.cn/commands/evalsha.html)|执行 Lua 脚本。|
|[SCRIPT EXISTS](https://redis.com.cn/commands/script-exists.html)|查看指定的脚本是否已经被保存在缓存当中。|
|[SCRIPT FLUSH](https://redis.com.cn/commands/script-flush.html)|从脚本缓存中移除所有脚本。|

## Redis HyperLogLog 命令

|命令|描述|
| ------| -------------------------------------------|
|​`PFGMERGE`​|将多个 HyperLogLog 合并为一个 HyperLogLog|
|[PFADD](https://redis.com.cn/commands/pfadd.html)|添加指定元素到 HyperLogLog 中。|
|[PFCOUNT](https://redis.com.cn/commands/pfcount.html)|返回给定 HyperLogLog 的基数估算值。|

## Redis 发布订阅 命令

|命令|描述|
| ------| ------------------------------------|
|[UNSUBSCRIBE](https://redis.com.cn/commands/unsubscribe.html)|指退订给定的频道。|
|[SUBSCRIBE](https://redis.com.cn/commands/subscribe.html)|订阅给定的一个或多个频道的信息。|
|[PUBSUB](https://redis.com.cn/commands/pubsub.html)|查看订阅与发布系统状态。|
|[PUNSUBSCRIBE](https://redis.com.cn/commands/punsubscribe.html)|退订所有给定模式的频道。|
|[PUBLISH](https://redis.com.cn/commands/publish.html)|将信息发送到指定的频道。|
|[PSUBSCRIBE](https://redis.com.cn/commands/psubscribe.html)|订阅一个或多个符合给定模式的频道。|

## Redis 地理位置(geo) 命令

|命令|描述|
| ------| -----------------------------------------------------------|
|[GEOHASH](https://redis.com.cn/commands/geohash.html)|返回一个或多个位置元素的 Geohash 表示|
|[GEOPOS](https://redis.com.cn/commands/geopos.html)|从key里返回所有给定位置元素的位置（经度和纬度）|
|[GEODIST](https://redis.com.cn/commands/geodist.html)|返回两个给定位置之间的距离|
|[GEORADIUS](https://redis.com.cn/commands/georadius.html)|以给定的经纬度为中心， 找出某一半径内的元素|
|[GEOADD](https://redis.com.cn/commands/geoadd.html)|将指定的地理空间位置（纬度、经度、名称）添加到指定的key中|
|[GEORADIUSBYMEMBER](https://redis.com.cn/commands/georadiusbymember.html)|找出位于指定范围内的元素，中心点是由给定的位置元素决定|

‍

‍

‍
