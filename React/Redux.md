# Redux


作者：Wang Namelos
链接：https://www.zhihu.com/question/59871249/answer/170400954

JavaScript函数式编程的现状和未来？实话说各种编程开发应用函数式编程的其实比较少。实际上能看到函数式架构的项目除了某些银行内部的高端项目基本就没见过太多，不然就是大数据处理这些和Web直接关联比较小的。React Redux带起这波节奏反而让函数式编程在前端领域里占有相当的一席之地了。

不要小看Redux这么几行代码——基本上就是后端喊了很多年都没搞起来的CQRS + Event Sourcing的优雅实现，甚至你能看到很罕见的Haskell真实项目基本也都只能用这个架构。前端没有性能压力，没有持久化，没有向后兼容版本问题，和这种模式天然亲和，避免了这种模式的所有缺点，只获得了好处。

除此之外(State, Action) => State这种纯函数状态表示，之前也仅在Haskell和Scala里面常用到。加上React本身的UI = View(State)这种幂等渲染的模式，基本已经算是相当函数式的架构了。（当然很多组件一大堆方法，内部状态，老从Promise获取然后赋值等等的项目不算……对Redux利用率比较高的项目才算）。

再往未来展望的话就是Observable这种流式结构和现在Redux这种Plain函数式风格的较量了。特别像Scala现在到底是用Akka这种纯Actor API还是用Akka Stream这种流式API好的赶脚——Redux比较像Actor，Observable就是Stream。

## 参考资料

- [前端开发js函数式编程真实用途体现在哪里？](https://www.zhihu.com/question/59871249)

- [函数式编程在Redux/React中的应用](https://tech.meituan.com/2017/10/12/functional-programming-in-redux.html)

- [一些前端框架的比较（下）——Ember.js 和 React](http://www.raychase.net/4111)

- [理解数据驱动视图](https://github.com/f2e-journey/treasure/blob/master/data-driven-view.md)

- [如何理解Stream processing, Event sourcing, Reactive, CEP?](https://www.jdon.com/artichect/making-sense-of-stream-processing.html)

- [幂等性浅谈](https://www.jianshu.com/p/475589f5cd7b)

- [Rematch: 重新设计 Redux](https://zhuanlan.zhihu.com/p/34199586)



## change log

- 2019/5/4 created doc
