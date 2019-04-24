# Browser rendering

## GPU/CPU of frame per second

资料主要来源：by 李光毅， from InfoQ

### frame per second


浏览器渲染刷新，由系统（GPU或CPU）绘制。显示器刷新频率限制了浏览器的最高刷新频率，一般情况下只能每秒60帧(frame per second, 简称FPS)。前端只有16.7毫秒（1000/60）来绘制每一帧。渲染不是连续的，而是离散的，是浏览器渲染的很多问题的根源。

### setTimeout和setInterval的问题

#### setTimeout和setInterval的时间精度不够

两者依赖浏览器内置时钟，内置时钟依赖时钟更新频率。
Chrome与IE9+浏览器时钟更新频率为4ms。
IE8及其之前的版本，更新间隔为15.6毫秒。如果我们设置setTimeout延迟为16.7ms，在IE8上执行过程，如下图：

```
                16.7ms
setTimeout: |------------|

                 15.6ms  15.6ms
clock:      |----------|----------|

```

15.6 * 2 - 16.7 = 14.5ms，会被延迟了14.5ms。



#### 任务队列问题



![browser_rendering](./browser_rendering.png)

## requestIdleCallback

## requestAnimationFrame


## React Fiber and React Scheduler


## 参考资料

- [Javascript 高性能动画与页面渲染](https://www.infoq.cn/article/javascript-high-performance-animation-and-page-rendering)

- [从 event loop 规范探究 javaScript 异步及浏览器更新渲染时机](https://juejin.im/entry/59082301a22b9d0065f1a186)

- [你应该知道的requestIdleCallback](https://juejin.im/post/5ad71f39f265da239f07e862)

- [Using requestIdleCallback ](https://developers.google.com/web/updates/2015/08/using-requestidlecallback)

- [【译】使用requestIdleCallback](https://div.io/topic/1370)

- [浅谈React Scheduler任务管理](https://zhuanlan.zhihu.com/p/48254036)

- [网页性能管理详解](http://www.ruanyifeng.com/blog/2015/09/web-page-performance-in-depth.html)

- [浏览器的渲染原理简介](https://coolshell.cn/articles/9666.html)

- [深入剖析 React Concurrent](https://zhuanlan.zhihu.com/p/60307571)


## change log

- 2019/4/24 create doc
