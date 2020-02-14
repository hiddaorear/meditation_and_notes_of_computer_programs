# nginx

## 典型的配置

指令以分号结束

``` conf

user  nobody; # 配置用户，默认为nobody
worker_processes  8; # 允许生成的进程数

pid         log/nginx.pid; # nginx进程PID记录文件，记录主进程PID

error_log log/error.log debug; # 错误日志路径

# events 模块
# 工作模式，连接数上限
events {
    accept_mutex on; # 设置网路连接序列化，防止惊群现象发生，默认为on
    multi_accept on; # 设置一个进程是否同时接受多个网络连接，默认为off
    use epoll; # 事件驱动模型
    worker_connections  100000; # 单个work进程允许的最大连接数，默认为512
}

worker_rlimit_nofile 100000; # worker进程的最大打开文件数限制。没设置，则为操作系统的限制。设置之后，避免"too many open files"问题

http {
    include       mime.types;
    #文件扩展名与文件类型映射表。设定mime类型(邮件支持类型),类型由mime.types文件定义
    #include /usr/local/etc/nginx/conf/mime.types;

    # 默认文件类型text/plain
    default_type  application/octet-stream;

    server_tokens off; # 默认值是on，表示版本信息。设置off，则隐藏nginx版本信息。避免人对此版本的漏洞攻击

    server_names_hash_bucket_size 128;
    client_header_buffer_size 32k;
    large_client_header_buffers 4 32k;
    client_max_body_size 1800m;

    sendfile on; # 配置允许使用sendfile方式传输。sendfile实际上是 Linux2.0+以后的推出的一个系统调用
    # 打开 sendfile on 选项能提高 web server性能。详情见下文
    tcp_nopush        on; # tcp_nopush 配置和 tcp_nodelay "互斥"。它可以配置一次发送数据的包大小。也就是说，它不是按时间累计  0.2 秒后发送包，而是当包累计到一定大小后就发送。tcp_nopush 必须和 sendfile 搭配使用
    tcp_nodelay       on;



    # 详细技术背景，见下文
    fastcgi_connect_timeout 30;
    fastcgi_send_timeout 30;
    fastcgi_read_timeout 30;
    fastcgi_buffer_size 64k;
    fastcgi_buffers 4 64k;
    fastcgi_busy_buffers_size 128k;
    fastcgi_temp_file_write_size 128k;

    keepalive_timeout  75;  # 连接超时时间，默认为75s，可以在http，server，location块

    client_header_timeout 60;
    client_body_timeout 60;
    send_timeout 60;

    #proxy_connect_timeout 90; # nginx跟后端服务器连接超时时间(代理连接超时)
    #proxy_send_timeout 90; # 后端服务器数据回传时间(代理发送超时)
    #proxy_read_timeout 90; # 连接成功后，后端服务器响应时间(代理接收超时)

    gzip              on; # gzip压缩开关
    gzip_min_length   1k;
    gzip_buffers      4 16k;
    gzip_http_version 1.0;
    gzip_comp_level   2;
    gzip_types        text/plain application/x-javascript text/css application/xml text/javascript;
    gzip_vary         on;

    charset      utf-8;

    log_not_found off; # 是否在error_log中记录不存在的错误
    #取消服务访问日志
    #access_log off;
    #自定义日志格式
    log_format myFormat '$remote_addr–$remote_user [$time_local] $request $status $body_bytes_sent $http_referer $http_user_agent $http_x_forwarded_for';
    access_log log/access.log myFormat; #设置访问日志路径和格式。"log/"该路径为nginx日志的相对路径，mac下是/usr/local/var/log/。combined为日志格式的默认值
    rewrite_log on; rewrite log 是记录在 error log 文件中，而不是access log中

    error_page   400 403 405 408 /40x.html ;
    error_page   500 502 503 504 /50x.html ;


    server{
        listen          80; # 监听HTTP端口
        server_name     xxx.xxx.com; # 主机名或ip。可以有多个，支持通配符和正则表达式

        # 注意 path 最后有斜杆和没斜杆的区别
        # 配置代理
        location /path/ {
            proxy_send_timeout 90; #后端服务器数据回传时间(代理发送超时)
            proxy_read_timeout 90; #连接成功后，后端服务器响应时间(代理接收超时)
            proxy_read_timeout 150;
            proxy_pass http://xxx.xx.xx.xx:8080/path; # 代理服务器地址，可以是主机名，IP地址加端口号
        }

        # 跨域的处理
        server {
            listen       9113;
            server_name  wx.simplesay.xin;

            # 备忘，需要核实的结论：Nginx的add_header指令并不能在HTTP返回码为50X的时候起作用，由于服务器处理逻辑出错，导致了Nginx返回内部服务器错误（500）
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS, PUT';
            add_header Access-Control-Allow-Headers 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization,X-Token';

            if ($request_method = 'OPTIONS') {
                return 204;
            }
        }

        location / {
            proxy_set_header   Host             $host; # in this order of precedence: host name from the request line, or host name from the “Host” request header field, or the server name matching a request
            proxy_set_header   X-Real-IP        $remote_addr;
            proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:8080;
            proxy_next_upstream off;
            gzip on;
        }
    }
}

```

## 调试办法

### ping

`ping ip`，看看是否能解析到设置的url。

### 访问日志

`tail -f log`

## 背景技术

### fastcgi

wiki文档：

> CGI使外部程序与Web服务器之间交互成为可能。CGI程序运行在独立的进程中，并对每个Web请求创建一个进程，这种方法非常容易实现，但效率很差，难以扩展。面对大量请求，进程的大量创建和消亡使操作系统性能大大下降。此外，由于地址空间无法共享，也限制了资源重用。

> 为每个请求创建一个新的进程不同，FastCGI使用持续的进程来处理一连串的请求。这些进程由FastCGI服务器管理，而不是web服务器。 当进来一个请求时，web服务器把环境变量和这个页面请求通过一个socket比如FastCGI进程与web服务器（都位于本地）或者一个TCP connection（FastCGI进程在远端的server farm）传递给FastCGI进程。

其他文档的总结：

Nginx只是内容的分发者。如，请求`index.html`，则Nginx去找这个静态资源，发送给浏览器。

如果请求的是`index.php`，Nginx知道这个不是静态文件，去找PHP解析器处理，即把这个请求交给PHP解析处理。CGI就是规定要以什么格式传什么数据给PHP解析器的协议。

Nginx收到`index.php`请求就去启动PHP的CGI程序，即PHP解析器，PHP解析器处理之后，再以CGI规定的格式返回结果，退出进程。Nginx把结果返回给浏览器。

CGI这样来一个处理一个，有性能瓶颈，CGI对每一个http请求都要fork一个新进程，处理完之后fork的进程退出。

FastCGI为了避免这个问题，先fork一个master，解析配置，初始化环境，再fork多个worker。请求过来之后，master传递给worker，在接受下一个请求，worker不够，预先启动多个worker。空闲worker太多，则停掉。这样提高了性能，也节约了资源。FastCGI管理这些进程。


### sendfile 系统调用提升性能的原因

#### 不用 sendfile的传统网络传输过程

`read(file,tmp_buf, len);`

`write(socket,tmp_buf, len);`

`硬盘 >> kernel buffer >> user buffer>> kernel socket buffer >>协议栈`

一般来说一个网络应用是通过读硬盘数据，然后写数据到socket 来完成网络传输的。上面2行用代码解释了这一点，不过上面2行简单的代码掩盖了底层的很多操作。来看看底层是怎么执行上面2行代码的：

1、系统调用 read()产生一个上下文切换：从 user mode 切换到 kernel mode，然后 DMA 执行拷贝，把文件数据从硬盘读到一个 kernel buffer 里。

2、数据从 kernel buffer拷贝到 user buffer，然后系统调用 read() 返回，这时又产生一个上下文切换：从kernel mode 切换到 user mode。

3、系统调用write()产生一个上下文切换：从 user mode切换到 kernel mode，然后把步骤2读到 user buffer的数据拷贝到 kernel buffer（数据第2次拷贝到 kernel buffer），不过这次是个不同的 kernel buffer，这个 buffer和 socket相关联。

4、系统调用 write()返回，产生一个上下文切换：从 kernel mode 切换到 user mode（第4次切换了），然后 DMA 从 kernel buffer拷贝数据到协议栈（第4次拷贝了）。

上面4个步骤有4次上下文切换，有4次拷贝，我们发现如果能减少切换次数和拷贝次数将会有效提升性能。在kernel2.0+ 版本中，系统调用 sendfile() 就是用来简化上面步骤提升性能的。sendfile() 不但能减少切换次数而且还能减少拷贝次数。


#### 用 sendfile的传统网络传输过程

`sendfile(socket,file, len);`

`硬盘 >> kernel buffer (快速拷贝到kernelsocket buffer) >>协议栈`

1、系统调用sendfile()通过 DMA把硬盘数据拷贝到 kernel buffer，然后数据被 kernel直接拷贝到另外一个与 socket相关的 kernel buffer。这里没有 user mode和 kernel mode之间的切换，在 kernel中直接完成了从一个 buffer到另一个 buffer的拷贝。

2、DMA 把数据从 kernelbuffer 直接拷贝给协议栈，没有切换，也不需要数据从 user mode 拷贝到 kernel mode，因为数据就在 kernel 里。

步骤减少了，切换减少了，拷贝减少了，自然性能就提升了。这就是为什么说在Nginx 配置文件里打开 sendfile on 选项能提高 web server性能的原因。

### $remote_addr和$proxy_add_x_forwarded_for;

#### remote_addr

nginx的 $remote_addr代表客户端的访问 ip，把它设到 http 请求的头部X-Real-IP；然后程序取出并存入数据库，统计访问次数。可以用于限流。

remote_addr 基本上不能被伪造，因为是直接从 TCP 连接信息中获取的，也就是 netstat 的Foreign Address那栏。

#### x_forwarded_for

你使用了代理时，web服务器就不知道你的真实IP了，为了避免这个情况，代理服务器通常会增加一个叫做x_forwarded_for的头信息，把连接它的客户端IP（即你的上网机器IP）加到这个头信息里，这样就能保证网站的web服务器能获取到真实IP

### 惊群问题

todo

### 事件驱动模型

todo

## 异步日志

todo

## 反向代理注意的问题

URI即URL中不包含主机名的部分，如`/foo/bar.html`。URL是否包含URI，Nginx的处理不同：

- 不包含，不会改变原来地址的URI
- 包含，使用新URI替代原来的URI

proxy_passs变量末尾是否有`/`问题。被坑过，千万要注意。

``` conf
server {
    listen 80;
    server_name www.test.name;

location /server/ {
    # 配置1
    proxy_pass htpp://192.168.1.1; # 不包含uri，Nginx服务不改变原来的URI。客户访问`http://www.test.name/server/index.html`，结果为：`http://192.168.1.1/server/index.html`
    # 配置2
    proxy_pass htpp://192.168.1.1/; # 含uri，Nginx服务会将原来的URI替换为`/`。客户访问`http://www.test.name/server/index.html`，结果为：`http://192.168.1.1/index.html`。原来url中的uri，即`server`被替换为`/`
}
    }
```

## 负载均衡

todo

## 感悟

计算机体系结构之类的理论课程，结合一下服务器的使用，应该可以变得有趣。或者，带着服务器的技术问题，去都计算机理论的书，应该比较有趣。

## change log

- 2020/2/14 created document
