# 观察者模式和发布订阅模式

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
