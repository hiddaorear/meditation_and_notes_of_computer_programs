# Computer Memory

印象深刻的话：
> 计算机底层技术，这些底层优化的技巧，只要弄通一次了，就是自己的了。而且十几年不会变。

## 基础

### 计算机内存的拓扑结构

人物：王安

可以抽象为一个二位矩阵，很多存储的优化，都可以用这个结构来解释。

### 典型的场景

#### 二维矩阵的求和

行优先和列优先效率的差异，差异的来源是？以及怎么磨平差异？

#### 二维矩阵的转置


## 优化

### 上层缓存的命中率

#### 减少不必要的分支

1. 消除条件分支

``` c

int r;
if (a < b) {
    r = c;
} else {
    r = d;
}

```

消除`if`的方法：

``` c

int mask = (a - b) >> 31;
r = d + mask & (c - d);

```

原理：如果`a < b`，则 `a - b < 0`， `a - b`的最高位为1，则`mask = 0xFFFFFFFF`
`mask & (c - d) = c - d`，`r = d + c - d = c`

2. 拆开`for`循环

``` c

for (i = 0; i < N; ++i) {
    if (i % 2 == 0) {
        FuncA(i);
    } else {
        FuncB(i);
    }
}

```

可以拆为：

``` c

for (i = 0; i < N; ++i) {
    if (i % 2 == 0) {
        FuncA(i);
    }
}

for (i = 0; i < N; ++i) {
    if (i % 2 != 0) {
        FuncB(i);
    }
}

```


### 提高并行度

#### SIMD(单指令多数据)指令及变种

json解析库：

- [simdjson(当前最快，用simd实现)](https://github.com/lemire/simdjson)

- [zzzjson](https://github.com/dacez/zzzjson)

- [rapidjson](https://github.com/Tencent/rapidjson)

#### 循环展开

``` c
for (j = 0; j < N; ++j) {
    sum += matrix[j];
}
```

初步展开：

``` c
for (j = 0; j < N; j += 8) {
    sum += matrix[j];
    sum += matrix[j + 1];
    sum += matrix[j + 2];
    sum += matrix[j + 3];
    sum += matrix[j + 4];
    sum += matrix[j + 5];
    sum += matrix[j + 6];
    sum += matrix[j + 7];
}
```

没有充分利用缓存，优化一下：

``` c
for (j = 0; j < N; j += 8) {
    sum0 += matrix[j];
    sum1 += matrix[j + 1];
    sum2 += matrix[j + 2];
    sum3 += matrix[j + 3];
    sum4 += matrix[j + 4];
    sum5 += matrix[j + 5];
    sum6 += matrix[j + 6];
    sum7 += matrix[j + 7];
    sum = sum0 + sum1 + sum2 + sum3 + sum4 + sum5 + sum6 + sum7;
}
```

### 避免重复计算

#### 避免不必要的函数调用

``` c
int CaseConvert(const char *src, char *dst)
{
    int i;
    for (i = 0; i < strlen(src); ++i)
    {
        if (src[i] >= 'A' &&
            src[i] <= 'Z')
        {
            dst[i] = src[i] + ('a' - 'A');
        }
        else
        {
            dst[i] = src[i];
        }

    }
}
```

其中`strlen(src)`每次循环都要调用一次。

优化一下：

``` c
int CaseConvert(const char *src, char *dst)
{
    int i;
    int j = strlen(src);
    for (i = 0; i < j; ++i)
    {
        if (src[i] >= 'A' &&
            src[i] <= 'Z')
        {
            dst[i] = src[i] + ('a' - 'A');
        }
        else
        {
            dst[i] = src[i];
        }

    }
}
```

如果src的类型为`std::string`，那么`for(...; i < src.length(); ...)`会怎样？

答案：和优化版本性能差不多。`std::string()`函数的调用，直接返回长度的常量了，而函数被内联了，调用开销小。

#### 避免不必要的内存操作以及系统调用

用户态内存操作：

- `memset&memcpy`

- 参数传递：用引用，还是复制

- 变量声明：在顶层全部一次性声明了，还是用的时候再声明

系统态内存操作：

- `sendfile`

- `writev`

- `readv`

- `mmap`

- `splice`

- `tee`

举例：在用网络放送文件操作的时候，推荐用`sendfile`，有1次系统调用，3次内存拷贝。如果用`read&write`，有2次系统调用，4次内存调用。

### 其他优化点

- float，double比int慢

- 乘除，取模，比加减和位移慢

- 函数参数尽量少（寄存器 vs 栈）

- 字节对齐（跨cacheline）

- 内存分配和释放（`sbrk/mmap` vs `tcmalloc/jemalloc`）

- 预分配（reserve，resize，各种池）

- 批量操作（批量写文件，批量读写接口）

- 空间换时间（查表法）

- 数据结构优化（map vs `unordered_map`， vector vs list）

- 算法优化

- 惰性（惰性求值，CopyOnWrite）

- 用指针或引用代替对象传递

### 多核

#### 选择合适的锁

- 首选mutex，有了瓶颈在考虑spinlock CAS rwlock等

- 对于临界区很轻量的情况，慎用spinlock或CAS

- 对于多读少写的多线程，慎用rwlock

- 对于临界区较重的请求，请用mutex

- 其他情况，首选mutex

#### SMP NUMA

## 分析的工具

| 现象        | 工具           |
| ------------- |:-------------:|
| 系统调用消耗大| strace  |
| 磁盘IO较重    | iotop, iostat |
| 网络          | sar, tcpdump, ss |
| swap free很少 | vmstat, swapon/off  |
| 某线程CPU利用率高  | pstack |
| 其他          | latencytop, lsof, tnm2 |

## 其他优化的思路

### 需求优化

- 是否要返回全量结果

- 有一定的误差行不行？

### 架构优化

- 缓存

- 异步、并发

- 分层减少计算量（广告，推荐领域的召回，精排）

- 压缩（减少磁盘，网络等负载）

- 部署（同城，同机房，同机架部署）

- 其他（协议，服务拆分，技术选型等，如降级，熔断，容灾，CAP，sharding，冷热/读写分离）

## 经典书籍

### 深入理解计算机技术

### 计算机系统结构

### 支撑处理器的技术

### 性能之巅

### 图解性能优化

## change log

- 2020/1/7 create document

- 2020/1/8 半夜完成初稿，后续读相关书籍，进一步补充
