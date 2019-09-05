# ubuntu

## 问题

### 开机进入tty

#### 表象

突然开机进入tty，按`Alt Ctrl F1-F7`都无法进入桌面。命令行输入`startx`，也无法进入桌面。

#### 解决办法

``` shell

sudo apt install ubuntu-desktop

```

#### 可能原因

显卡驱动问题。


## change log

- 2019/9/4 新建ubuntu文档
