# SQL

## join

JOIN将两个或多个表组合，生成的集合，可以保存为表，或者当作表来使用。

ANSI标准SQL一共五种：内连接 INNER，全外连接 FULL OUTER，左连接 LEFT OUTER，右连接 RIGHT OUTER，交叉连接 CROSS。

### cross join 交叉连接(笛卡尔连接 cartesian join 或叉乘 Product)

笛卡尔积是所有内连接的基础。

显示：

``` sql

SELECT * FROM table1 CROSS JOIN table2;

```

隐式：

``` sql

SELECT * FROM table1, table2;

```

### inner join

内连接基于连接谓词，将两张表的列组合在一起，产生新的结果表。

连接产生的结果，可以定位为首先对两张表做笛卡尔积，把表A和表B中每一行进行组合，返回满足谓词的记录。实际实现可能不是这样，笛卡尔积运算效率低。

显式：

``` sql

SELECT * FROM table1 INNER JOIN table2 ON table1.id = table2.id

```

隐式：

``` sql

SELECT * FROM table1, table2 WHERE table1.id = table2.id

```

### outer

外连接不要求两个表单每一行记录在对方表中都有一条匹配的记录。要保留所有记录的表称为保留表。因此，外连
接可以分为：左外连接，右外连接和全连接。

#### right outer join and left outer join

right join从右表(table2)返回所有的行，即使左表(table1)中没有匹配。如果左表没有匹配，则为NULL。left join则相反。

``` sql

SELECT column_name FROM table1 RIGHT OUTER JOIN table2 ON table.column_name=table2.column_name;

```

#### 内存不够怎么办？


#### 数据太大怎么办？冗余数据？

### 实现算法

#### 嵌套循环(loop join)

类似C语言的双重循环。适用于外层循环的表数据少，内层循环表创建了索引的情况。

#### 合并连接(merge join)

类似有序数组的合并。如果预先建立好索引，合并连接的复杂度是线性的。

#### 哈希连接(hash join)

哈希连接选择行数较小的表生成输入，对连接的列应用哈希函数，把其行放入哈希桶中。



## 参考资料

- [Say NO to Venn Diagrams When Explaining JOINs](https://blog.jooq.org/2016/07/05/say-no-to-venn-diagrams-when-explaining-joins/)

- [SQL JOIN](https://zh.wikipedia.org/wiki/%E8%BF%9E%E6%8E%A5)

- [分布式数据库下子查询和join等复杂sql如何实现？](https://www.zhihu.com/question/38038257)

## change log

- 2019/5/10 created doc
- 2019/9/6 补充join文档
