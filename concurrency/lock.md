# lock

## concurrency and parallelism

![concurrency and parallelism](./concurrency_and_parallelism.jpg)

### cuncurrency

并发是同时处理很多事情（dealing with lots of things at once）

### parallelism

同时执行很多事情（doing lots of things at once）。并行更关注程序的执行(execution)

> Different concurrency designs enable different ways to parallelism.

### 区别

并行是指物理上同时执行，并发是指能够让多个任务在逻辑上交织执行的程序设计。即：并发设计让并发执行成为可能，而并行是并发执行的一种模式。

## lock

- 自旋锁
- 乐观锁
- 悲观锁



## change log

- 2019/9/7 新建文档
- 2019/9/8 新增lock
