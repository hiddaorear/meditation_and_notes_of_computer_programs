# PHP 安全问题

## XSS

1. php 前后端不分离，模板引擎没有特殊字符 escape

## SQL 注入

1. 很少用 ORM 框架，长时间没有 prepared statement (parameterized statement?)支持，escape 函数在多字节集上是 broken

## web shell

1. 不常驻内存，需要文件系统写文件来暂存数据，语言上不支持流式处理上传附件

2. 往网站目录里写文件，能当脚本执行

3. 小白多，没有配置数据目录和脚本目录权限隔离

## change log

- 2020/3/10 created document
