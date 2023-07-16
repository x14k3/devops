# mysql 优化

## 32GB内存的mysql配置参数

```bash
#缓冲池字节大小,配置为系统内存的50%至75%，默认为128M,
innodb_buffer_pool_size=16G
innodb_log_file_size = 2G
innodb_log_buffer_size=16M

key_buffer_size = 256M
max_allowed_packet = 32M
table_open_cache = 16384
sort_buffer_size = 32M
net_buffer_length = 16384
read_buffer_size= 16M
read_rnd_buffer_size = 32M
myisam_sort_buffer_size = 128M
thread_cache_size = 64
tmp_table_size = 128M
max_connections = 100000
open_files_limit = 500000

```
