# ubuntu

## gnome使用

### 打开应用

- 按Super(Win)键，输入应用名。类似Mac的Alfred。
- `Super-a`进入应用程序界面


### 切换工作区

- `Ctrl-Alt-上下箭头`或者`Super-上下箭头`
- `Alt-Tab`正向切换窗口
- `Super-Home`回到第一个工作区
- `Super`或`Alt-F1`显示所有工作区

### 窗口管理

- `Super-h`隐藏窗口
- `Super-向上箭头`最大化当前窗口
- `Super-向下箭头`还原当前窗口
- `Alt-F8`调整当前窗口大小
- `Ctrl-Alt-Shift-向上下箭头`将应用移到上一个或下一个工作区


### 全屏

`F11`开启或关闭全屏

### 打开终端

`Ctrl-Alt-T`

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
