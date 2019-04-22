# Bigpipe

## 原理

浏览器和服务器并发执行，实现页面的异步加载。目的是提高，访问速度。


## 要点

把页面，依照功能或位置等其他维度，将页面分成模块，即所谓的pageLet，分解的模块有唯一的标识。然后通过浏览器和web服务器之间建立的管道(减少请求数)，进行分段输出。

## 关键技术

HTTP1.1支持分块传输。HTTP的Transfer-Encoding消息头值为chunked。消息体由数量未定的块组成，并以最后大小为0的块结束。这个机制，可以允许页面内容分成多个内容块。

## 解决的问题

- 常规渲染问题：同步加载首屏模块，客户端渲染依赖服务器最后一个内容的生成时间。关键问题：同步。
- 滚动异步加载：页面框架先直出，显示loading，模块异步请求数据，渲染。关键问题：多个模块，多个请求，耗时。
- BigPipe：一次请求，服务端并行处理，直接给客户端渲染。解决以上两个问题。

## 原型实现

前端：

``` html
<!DOCTYPE html>
<html>
<head>
  <script>
    let BigPipe = {
      view: function(selector,temp) {
        document.querySelector(selector).innerHTML= temp;
      }
    }
  </script>
</head>
<body>
    <div id="moduleA"></div>
    <div id="moduleB"></div>
    <div id="moduleC"></div
```

后台：
``` JavaScript
let express = require('express');
let app = express();
let fs = require('fs');

app.get('/', function(req, res) {
    let layoutHtml = fs.readFileSync(__dirname + '/layout.html').toString();
    res.write(layoutHtml);

    // setIimeout模拟异步
    setTimeout(function() {
        res.write('<script>BigPipe.view("#moduleA", "moduleA content")<script>');
    }, 300);

    // setIimeout模拟异步
    setTimeout(function() {
        res.write('<script>BigPipe.view("#moduleB", "moduleB content")<script>');
    }, 300);

    // setIimeout模拟异步
    setTimeout(function() {
        res.write('<script>BigPipe.view("#moduleC", "moduleC content")<script>');
        res.write('</body></html>');
    }, 300);

    // 如果只是 res.write 数据，没有指示 res.end ，那么这个响应就没有结束，浏览器会保持这个请求。在没有调用 res.end 之前，我们完全可以通过 res.write 来 flush 内容
    res.end();

});

app.listen(3000);

```

显著特征：

- 页面不再是一次性输出，而是分片段输出。
- 同时，即使是分片的输出，也不是每一个片段是一个请求，而是复用一个请求。
-服务端可以是并行异步处理。

## 参考资料

- [新版卖家中心 Bigpipe 实践（二）](http://taobaofed.org/blog/2016/03/25/seller-bigpipe-coding/)
- [浏览器的渲染原理简介](https://coolshell.cn/articles/9666.html)

## change log

- 2019/4/22 created doc
