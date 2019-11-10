# 计算机程序的沉思和笔记

> 如果翻译器对程序进行了彻底的分析而非某种机械的变换，而且生成的中间程序与源程序之间已经没有很强的相似性，我们就认为这个语言是编译的。 彻底的分析和非平凡的变换，是编译方式的标志性特征。

> 如果你对知识进行了彻底的分析而非某种机械的套弄，在你脑中生成的概念与生硬的文字之间已经没有很强的相似性，我们就认为这个概念是被理解的。 彻底的分析和非凡的变换，是获得真知的标志性特征。

## 技术跟踪

- TS
- nestjs
- rabbitMQ
- Swagger


## 文档

## PL

- [The Racket Guide](./PL/Racket/the_Racket_guide.md)

### algebraic_and_programming

- [todo Algebraic Effects](./algebraic_and_programming/Algebraic_Effects.md)

- [todo Algebraic Data Types ](./algebraic_and_programming/Algebraic_Data_Types.md)

- [todo Object Algebras ](./algebraic_and_programming/Object_Algebras.md)

### Lisp

- [todo mathematics](./Lisp/mathematics.md)

- [todo OO and FP](./Lisp/OO_and_FP.md)

- [todo lexical scope](./Lisp/lexical_scope.md)

- [todo type](./Lisp/type.md)

- [todo monad](./Lisp/monad.md)

- [todo comonad](./Lisp/comonad.md)

### C

- [todo thread](./C/thread.md)

### C++

### backend development

- [todo koa](./backend_development/koa.md)

### database

- [todo SQL](./database/SQL.md)

### concurrency

- [lock](./concurrency/lock.md)


### React

- [todo Redux](./React/Redux.md)

- [todo Hooks](./React/Hooks.md)

- [todo React design patterns and best practices](./React/React_design_patterns_and_best_practices.md)

### IDE

- [IntelliJ](./IDE/IntelliJ.md)

### front end

- [bigpipe](./front_end/bigpipe.md)

- [iframe](./front_end/iframe.md)

- [analytics](./front_end/analytics.md)

- [todo shadow DOM](./front_end/shadow_dom.md)

- [todo 前端表单校验的设计](./front_end/form_validation.md)

- [todo ](./front_end/analytics.md)

### design patterns

- [MVC](./design_patterns/MVC.md)

- [observer and pub sub pattern](./design_patterns/observer_and_pub_sub_pattern.md)

- [reactor](./design_patterns/reactor.org)

- [todo visitor](./design_patterns/visitor.md)

- [todo interpreter](./design_patterns/interpreter.md)

### OCaml

- [elementary](./OCaml/elementary.md)

### mathematics

- [todo Gaussian Blur](./mathematics/Gaussian_Blur.md)

### engineering

- [代码圈复杂度](./engineering/cyclomatic_complexity.md)


## 技术主题

### 数据结构

- hashmap的实现

### 计算机基础

- 多进程
- 多线程
- 状态同步

### 日常经验

- 后台如何生成唯一id
- 如何生成不递增的唯一id



## 摘录SICP

> 我认为，在计算机科学中保持计算中的趣味性是特别重要的事情。我认为，我们的责任是去拓展这一领域，将其发展到新的方向，并在自己家里保持趣味性。我希望，我们不要变成传道士，不要认为你是兜售圣经的人。你所掌握的，也是我认为并希望的，也就是智慧：那种看到这一机器比你第一次站在他面前能做得更多的能力。这样你才能将他向前推进。
Alan J. Perlis

> 一个计算机语言并不仅仅是让计算机执行操作的一种方式，更重要的是，他是一种表述有关方法学的思想的新颖的形式化媒介。因此，程序必须写得能供人们阅读，
偶尔地去供计算机执行。其次，我们相信，在这一层次的课程里，最基本的材料并不是特定计算机设计语言的语法，不是高效计算某种功能的巧妙算法，也不是算法的数学分析或计算的本质基础，而是一些能够控制大型软件系统的智力复杂性的技术。

> 掌握了控制大型系统中的复杂性的主要技术。应该知道，在什么时候那些东西不需要去读，那些东西不需要去理解。

> (有关Lisp)，可以做过程抽象和数据抽象，可以通过高阶函数抓住公共的使用模式，可以用赋值和数据操作去模拟局部状态，可以利用流和延时求值连接起一个程序的各个部分。

> 当我们描述一个语言的时，需要将注意力放在这一语言所提供的，能够将简单的认识组合起来形成更复杂认识的方法方面。每一种强有力的语言都为此提供了三种机制：
> - 基本表达形式。最简单个体
> - 组合的方法。简单个体构造复合元素
> - 抽象的方法。通过这个抽象的方法，为复合对象命名，并将它当做单元去操作

## change log

- 2019/4/21 新增todolist，尽量保持关注的连续性，不可东一榔头，西一棒槌

- 2019/4/29 更新文章列表

- 2019/5/10 更新文章列表

- 2019/8/20 新增技术主题

- 2019/8/28 新增并发文档

- 2019/9/22 新增设计模式

- 2019/10/18 更新目录

- 2019/11/10 新增Racket语言写的interpreter
