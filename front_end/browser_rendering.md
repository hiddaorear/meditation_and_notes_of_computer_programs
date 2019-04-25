# Browser rendering

## GPU/CPU of frame per second

### frame per second

显示器刷新频率限制了浏览器的最高刷新频率，一般情况下只能每秒60帧(frame per second, 简称FPS)。显示器的刷新频率，即显示器上渲染的元素（如图片）每秒出现的次数，一般电脑是60Hz。也就是，当什么也不做的时候，或者操作电脑的时候，显示器以这个频率渲染，不断更新屏幕上的图像。

利用浏览器做动画，要求以连续的、平滑的线性方式实现，这样视觉上才不会卡顿。即不能丢帧。

浏览器的渲染，受系统（GPU或CPU）和显示器刷新频率，两者的影响。显示器一般16.7ms（1000/60ms）来绘制每一帧，而GPU刷新频率则不确定。因此渲染不是连续的，而是离散的，是浏览器渲染的很多问题的根源，特别是动画的渲染问题。

GPU的频率可以大于显示器的刷新频率。就可能出现，GPU渲染在显示器的一个时钟周期渲染多次，实际上只有一次能在显示器上呈现。PC游戏中解决这个问题办法是使用`v-sync`。GPU妥协，必须在显示器两次刷新中间渲染。代价是降低了GPU输出频率，即降低渲染的帧数。

![browser_rendering](./browser_rendering.png)

由于渲染是离散的，渲染的时机，和渲染的耗时，会影响渲染效果。

#### 1. 时机的影响：

```
               15.6ms     15.6ms    15.6ms
clock:     |----------|----------|----------|
                  frame1  frame2 frame3
animation: ------|------|------|------|------

```

animation的frame(`<15.6ms`)以相同的周期触发了三次渲染，中间的frame2没来得及渲染，就触发frame3，导致frame3丢帧了。如果能控制frame2的触发时机，比如在第三个时钟周期触发，就可以避免这个问题。requestAnimationFrame可以解决这个问题，其功能是能找到合适的时间点执行动画。


#### 2. 渲染耗时的影响：

```
               15.6ms     15.6ms    15.6ms
clock:     |----------|----------|----------|
                         frame1
animation: ------|-------------------|--------

```

animation的frame(`<15.6*2ms`)，第一个、第二个时钟周期都没来及渲染，导致动画看起来不流畅。这种情况，一般来说是重绘和重排等大量耗时操作导致。低优先级的任务，requestIdleCallback可以缓解这个问题，其功能是选择浏览器的idle时间，来执行任务。也可以利用这个API实现，把一个大任务，分片执行，如React Fiber和React Scheduler。


### setTimeout和setInterval的问题

- tab已不可见，以及触发频率高于显示器渲染频率(见上文情况1)，这两种情况下的过度渲染问题
- 由于硬件或浏览器不同，性能不一样，如何确定确定合适的动画的时间间隔（见上文情况2）
- 依赖浏览器的内置时钟，其更新频率会导致毫秒的不精确

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


## requestIdleCallback

``` JavaScript

class nonEssentialWork {
    constructor(task, timeout) {
        this.tasks = task || [];
        this.timeout = timeout || 0;
    }

    getTasks = () => {
        return this.tasks;
    }

    push = (task) => {
        this.tasks.push(task);
    }

    clear = () => {
        this.tasks = [];
    }

    main = () => {
        let timeout = this.timeout;
        requestIdleCallback((deadline) => {
            while((deadline.timeRemaining() > 0 || deadline.didTimeout) && this.tasks.length > 0) {
               this.tasks.pop()();
            }
            if (this.tasks.length > 0) {
                requestIdleCallback(this.main, {timeout});
            }
        }, {timeout});
    }

};

```

## requestAnimationFrame



## React Fiber and React Scheduler

Fiber是一种调度算法，使用requestIdleCallback实现，React用requestAnimationFrame模拟实现。解决无多线程操作带来的问题。

DOM的树形结构，以及其包含的大量数据，保证其顺序执行，且不影响主线程的UI渲染。从Root开始，遍历tree结构，到达叶子节点，则回到父节点，以链表的形式链接起来(或者队列？)，如下图：

![Fiber](./Fiber.png)

优点：

- 不用递归处理DOM树，循环即可。相比递归的栈，只需多了额外内存保存信息
- 有了此层的抽象，可以将Diff任务以及创建DOM的任务，分片执行之。异步渲染，虽然持续时间长，但zhzhzhzh只有最后变更的时候，一次性插入DOM

本质上React的Fiber是将任务分片为小任务，在16ms中的渲染的空闲时间执行。

### 与协程的Fiber有差异

有栈协程的Fiber。协程的任务一直会占用线程，直到用户返回。在事件循环和异步IO模型中，协程性能较好，且可以使用Future模式（Promise），把异步编程带来的问题消除。

浏览器的无栈协程：generator, Promise和async+await

### webAssembly与Fiber

来自Hacker News的讨论：

crudbug:
> Is there plan to implement the react-core in C or other native language ?
I can see that being compiled to webassembly for browsers and react-native can have multiple language support ?

danabramov:
> think my talk paints a relatively convincing picture why DOM nodes aren’t a sufficient primitive if you care about the features I described, as you’d need something like React to orchestrate those updates
>


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

- [Is there plan to implement the react-core in C or other native language ?](https://news.ycombinator.com/item?id=16494314)



## change log

- 2019/4/24 create doc
- 2019/4/25 半夜，写初稿
