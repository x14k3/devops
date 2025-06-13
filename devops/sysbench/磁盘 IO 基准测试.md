

```bash
[root@localhost src]# ./sysbench fileio help
sysbench 1.1.0-de18a03 (using bundled LuaJIT 2.1.0-beta3)

fileio options:
  --file-num=N                  number of files to create [128]
  --file-block-size=N           block size to use in all IO operations [16384]
  --file-total-size=SIZE        total size of files to create [2G]
  --file-test-mode=STRING       test mode {seqwr, seqrewr, seqrd, rndrd, rndwr, rndrw}
  --file-io-mode=STRING         file operations mode {sync,async,mmap} [sync]
  --file-extra-flags=[LIST,...] list of additional flags to use to open files {sync,dsync,direct} []
  --file-fsync-freq=N           do fsync() after this number of requests (0 - don't use fsync()) [100]
  --file-fsync-all[=on|off]     do fsync() after each write operation [off]
  --file-fsync-end[=on|off]     do fsync() at the end of test [on]
  --file-fsync-mode=STRING      which method to use for synchronization {fsync, fdatasync} [fsync]
  --file-merged-requests=N      merge at most this number of IO requests if possible (0 - don't merge) [0]
  --file-rw-ratio=N             reads/writes ratio for combined test [1.5]

```

### 第1步创建测试文件

这个命令会在当前工作目录下创建测试文件，后续的运行阶段将通过读写这些文件进行测试。

```sql
sysbench --test=fileio --file-total-size=50G prepare

sysbench 0.4.12:  multi-threaded system evaluation benchmark
128 files, 409600Kb each, 51200Mb total
Creating files for the test...
```

### 第2步就是运行

针对不同的`IO`​类型有不同的测试选项：

- ​`seqwr`​ 顺序写入
- ​`seqrewr`​ 顺序重写
- ​`seqrd`​ 顺序读取
- ​`rndrd`​ 随机读取
- ​`rndwr`​ 随机写入
- ​`rndrw`​ 混合随机读/写

例如，混合随机读/写测试：

```yaml
sysbench --test=fileio --file-total-size=50G --file-test-mode=rndrw --time=60 run

sysbench 0.4.12:  multi-threaded system evaluation benchmark
Running the test with following options:
Number of threads: 1
Initializing random number generator from timer.

Extra file open flags: 0
128 files, 400Mb each
50Gb total file size
Block size 16Kb
Number of random requests for random IO: 0
Read/Write ratio for combined random IO test: 1.50
Periodic FSYNC enabled, calling fsync() each 100 requests.
Calling fsync() at the end of test, Enabled.
Using synchronous I/O mode
Doing random r/w test
Threads started!
Time limit exceeded, exiting...
Done.

Operations performed: 81653 Read, 54435 Write, 174080 Other = 310168 Total
Read 1.2459Gb  Written 850.55Mb Total transferred 2.0765Gb  (7.0879Mb/sec)
 453.63 Requests/sec executed

Test execution summary:
    total time:                         300.0008s
    total number of events:              136088
    total time taken by event execution: 291.4656
    per-request statistics:
         min:                                  0.01ms
         avg:                                 2.14ms
         max:                                519.93ms
         approx.  95 percentile:               6.46ms

Threads fairness:
    events (avg/stddev):           136088.0000/0.00
    execution time (avg/stddev):   291.4656/0.00
```

输出结果中包含了大量的信息，这些数据对于评估磁盘性能十分有用：

- 每秒请求数 `453.63 Requests/sec`​
- 吞吐量 `7.0879Mb/sec`​
- 时间分布 `95 percentile: 6.46ms`​

测试完成以后，运行清除操作删除第一步生成的测试文件：

```bash
sysbench --test=fileio --file-total-size=50G cleanup
sysbench 0.4.12:  multi-threaded system evaluation benchmark

Removing test files...
```

‍
