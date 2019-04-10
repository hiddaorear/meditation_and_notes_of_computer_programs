# shell

## 文本搜索技巧

## shell

### 网络

`curl -v telnet://ip:port`

### 端口
`lsof -i :port`

### ssh登陆

### ps

`ps aux|grep TSW`
`kill -9 30862`

### log

### find

目录下的所有文件中查找字符串,并且只打印出含有该字符串的文件名

`find .| xargs grep -ri "string" -l`

### grep
递归搜索文件，`grep "function" . -R -n`

## change log

- 2019/4/10 org修改为md
