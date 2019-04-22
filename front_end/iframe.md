# iframe

## iframe定义

HTML内联框架元素 <iframe> 表示嵌套的浏览上下文，有效地将另一个HTML页面嵌入到当前页面中。

## JS相关功能

内联的框架，就像 <frame> 元素一样，会加入 window.frames 伪数组（类数组的对象）中。

通过contentWindow属性，脚本可以访问iframe元素所包含的HTML页面的window对象。contentDocument属性则引用了iframe中的文档元素（等同于使用contentWindow.document），但IE8-不支持。

通过访问window.parent，脚本可以从框架中引用它的父框架的window。

脚本试图访问的框架内容必须遵守同源策略，并且无法访问非同源的window对象的几乎所有属性。同源策略同样适用于子窗体访问父窗体的window对象。跨域通信可以通过window.postMessage来实现。

## 应用

### 低成本沙盒sandbox

- 广告（低成本的沙盒）
- 在线编辑器(contentEditable可以替代之)
- 音乐播放器
- 邮箱

### src发起请求特性(典型，具有src的DOM都可以跨域)

- 纯前端的utf8和gbk编码互转(利用a元素的href属性来encode)
- 移动端从网页调起客户端应用(浏览器收到位置协议的请求，交给系统处理，系统即可呼起APP)
- 跨域(已过时，现在用CORS或JSONP)
- Comet(已过时，现在用WebSocker)
- 无刷新文件上传(已过时，FormData)
- 预加载js，但不执行

## 缺点

### 内存泄漏

在父页面引用iframe页面对象的情况下，如果iframe被删除，父页面的引用依然存在，导致内存泄漏。

处理办法：iframe卸载时，强制页面刷新；或者，手动清除引用（IE下有`CollectGarbage()`方法触发JS垃圾回收）。退一步，把iframe的src属性设置为空白页面`abort:blank`，不能释放所有内存，但可以保持iframe内存占用量不增长，预计是150M左右。

### 阻塞主页面的onload时间

动态创建iframe，利用src异步加载，可以避免。

### 共享主页的连接池，由于浏览器对同域的连接有限制，影响并行加载

解决方案，同上。

### 移动端不友好

- 无法滚动
- meta默认使用最上层meta，内部字节失效
- iOS无故变大
- iframe页面a标签失效（不跨域）

### ?对统计代码不友好

### 相关技术的发展：WebComponent, bigpipe

关联很小，不补充。

## 安全

可用通过`X-Frame-Options`控制页面被嵌套的策略

## Recap

各大功能，归根结底，是使用了iframe创建了上下文无关的功能，和有src元素支持跨域的请求资源的特性。iframe的技巧，都是利用这个两个特性。


## 参考资料

- [MDN web docs iframe](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Element/iframe)

## chagne log

- 2019/4/22 created doc
- 2019/4/22 完成总结
