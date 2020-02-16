# Linux 基础

## bin 目录相关支持

- `/bin` 是系统的一些指令。bin为binary的简写主要放置一些系统的必备执行档例如:cat、tar等
- `/sbin` 一般是指超级用户指令。主要放置一些系统管理的必备程式例如:shutdown等
- `/usr/bin`　是你在后期安装的一些软件的运行脚本。主要放置一些应用软体工具的必备执行档例如c++、g++、gcc、wget等
- `/usr/sbin` 放置一些用户安装的系统管理的必备程式例如:dhcpd、httpd、imap、tcpd、tcpdump等

如果新装的系统，运行一些很正常的诸如：shutdown，fdisk的命令时，悍然提示：bash:command not found。那么首先就要考虑root 的$PATH里是否已经包含了这些环境变量。

可以查看PATH，如果是：PATH=$PATH:$HOME/bin则需要添加成如下：PATH=$PATH:$HOME/bin:/sbin:/usr/bin:/usr/sbin

## change log

- 2020/2/16 create document
