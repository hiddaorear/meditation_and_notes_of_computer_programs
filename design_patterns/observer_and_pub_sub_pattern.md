# 观察者模式和发布订阅模式

## 区别

发布订阅有抽象的事件中心。观察者无。观察者事件多数是一对一的关系，用于较简单的场景。

## 缺点

### 订阅事件的代码无法被管理

思考：JavaScript监听浏览器事件，也是可以随意监听的。理论上讲，可以瞎监听很多事件，为啥没有人着重提这个问题？

### 一个事件对应多个监听，执行优先级有问题

思考：这个问题，是否就是监听先后顺序，就是优先级的顺序？如果支持设置优先级，就要管理排序了？JavaScript的引擎V8，对含回调的代码的处理，也是一个简单的队列而已，不过有了Promise之后，有了micro和macro的区分？

再深入思考一下，如果什么地方都可以手动设置优先级，那是否函数调用就不能用函数栈处理了？毕竟栈这种结构，顺序就是固定的。

## 优点

## 本质

## 观察者模式

```` javascript

(function () {
    function Event() {
        this.evtList = {};
        this.onceList = {};
    }
    Event.prototype.on = function (evt, func) {
        if (this.evtList[evt]) {
            this.evtList[evt].push(func);
        } else {
            this.evtList[evt] = [func];
        }
        return this;
    };

    Event.prototype.once = function (evt, func) {
        if (this.onceList[evt]) {
            this.onceList[evt].push(func);
        } else {
            this.onceList[evt] = [func];
        }
        return this;
    };

    Event.prototype.trigger = function (evt) {
        var list = this.evtList[evt], i = 0, len = 0, tmp;
        if (list && list.length > 0) {
            list.forEach(function(item) {
                item.apply(this, Array.prototype.slice.call(arguments, 1));
            });
        }
        list = this.onceList[evt];
        if (list && list.length > 0) {
            len = list.length;
            while (tmp = list.pop()) {
                tmp.apply(this, Array.prototype.slice.call(arguments, 1));
            }
        }
        return this;
    };

    window.Event = Event;
}
````


## 观察者模式和发布订阅模式的区别：

从使用层面讲：
- 观察者模式，多用于单个应用内部
- 发布订阅模式，更多的是一种跨应用的模式，如消息中间件

从表面看：
- 观察者模式，只有两个角色：观察者和被观察者
- 发布订阅模式中，不只有发布者和订阅者，还有事件通道

从深层次看：
- 观察者和被观察者，是松耦合的关系
- 发布者和订阅者，不存在耦合


## 参考资料

[观察者模式 vs 发布订阅模式](https://zhuanlan.zhihu.com/p/51357583)
