## 编译
1. 当前工作目录下有3个文件10_0.c csapp.h csapp.c
2. 编译csapp.c文件，命令为gcc -c csapp.c，生成目标文件csapp.o
3. 编译10_0.c文件，命令为gcc -c 10_0.c，生成目标文件10_0.o
4. 链接目标文件csapp.o、10_0.o（由于csapp.c文件中有关于线程中部分，gcc编译的时候必须带 -lpthread,否则会出错的），命令为gcc -o main csapp.o 10_0.o -lpthread,生成可执行文件main,运行即可
