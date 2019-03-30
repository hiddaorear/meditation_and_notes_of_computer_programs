# 按位操作符

## `>>>`

`var len = this.length >>> 0;`其中，`>>>`用途：

1. 所有非负值转换为0；
2. 所有大于等于0，去整数部分；

此处的用途是，借用右移位运算符，用零填充len左边的空位，好处是如果length未定义，就取0。比`var len = this.length || 0`好处，在遇到意外的this，不会返回`{} []`等意外值。

可讨论的点：
- `||`的意图是取默认值，不是转型，如果是去默认值，而非转型（`>>>`是转型），那么此时`||`可能更好。虽然他也有自身的问题。
- `>>>`不一定就使得代码更鲁棒。此时，是强行忽略了类型不匹配，不如assert语句。


## 资料

[`this.length >>> 0`表示什么？](https://www.zhihu.com/question/20693429)

[ECMAScript 5 — Improve the Safety of JavaScript](http://johnhax.net/2011/es5_safety/#9)

[聊聊JavaScript中的二进制数](https://yanhaijing.com/javascript/2016/07/20/binary-in-js/)

[位运算符在JS中的妙用](https://juejin.im/post/5a98ea2f6fb9a028bb186f34)

[为什么不要在 JavaScript 中使用位操作符？](https://jerryzou.com/posts/do-you-really-want-use-bit-operators-in-JavaScript/)

[我们要不要在 JS 使用二进制位运算？](https://juejin.im/entry/57317b2679df540060d5d6c2)
