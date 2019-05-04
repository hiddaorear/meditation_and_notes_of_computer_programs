# Monad

#### 2019/4/6

## 直观感觉

Monad是一个抽象的数学概念，不容易给出直观的准确描述。类似的有量子力学里的波粒二象性，本质上要通过数学去感知，很难找到既是粒子也是波的可感知的物品。王垠对Lisp的评判的文章《函数式语言的宗教》中的例子：用随机数生成函数，说明无“状态”或“全局变量”的缺点，不能轻松表达random这样的“不纯函数”。很形象地描述了Monad在编程的本质。

> 为了达到“纯函数”的目标，我们需要做很多“管道工”的工作，这增加了程序的复杂性和工作量。如果我们可以把种子存放在一个全局变量里，到需要的时候才去取，那就根本不需要把它传来传去的。除 random() 之外的代码，都不需要知道种子的存在。

> 为了减轻视觉负担和维护这些进进出出的“状态”，Haskell 引入了一种叫 monad 的概念。它的本质是使用类型系统的“重载”（overloading），把这些多出来的参数和返回值，掩盖在类型里面。

王垠的例子：

``` c
int random()
{
  static int seed = 0;
  seed = next_random(seed);
  return seed;
}
```

在Haskell中`（旧种子）---> （新随机数，新种子）`。由于Haskell中不允许赋值语句`seed = next_random(seed)`，想办法把种子`seed`放在函数的参数里，这样来接受输入。进一步，Monad在这个情形中，可以认为是用函数的参数实现了赋值语句的能力，赋值被Monad隐藏了。

从编程的角度，Monad有两个接口：return/unit和bind。实现这个两个操作的类型，就可以称之为Monad。就像光有些情况下，如光电效应实验，粒子性显著一些，另一些情况下，如干涉和衍射实验，波的性质显著一些。光的粒子性和波动性，依赖实验设备。同样，Monad一些情况下可以看做容器，如Maybe Monad，return一个数据到Monad，用bind从Monad取出来。另一些情况看作有状态的函数，如State Monad。Monad不仅仅是用来处理副作用，典型的处理副作用的Monad：IO Monad.

但这样去理解Monad，会有偏差。维特根斯坦说： a definition of logical form as opposite to logical matter"“(对逻辑形式，而非逻辑内容的定义)。不能用monad的应用来定义monad，而只能依靠monad的形式。

## todo

编程中经常遇到CPS(可以理解为计算中的延续)，是Monad中的一种，适合IoC(Inversion of Control，控制反转，也是DI:Dependency Injection)场景。
IoC 的核心思想是 “Don’t call me, I’ll call you”，也被叫作”好莱坞原则"，据说是好莱坞经纪人的口头禅。 IoC在编程中的典型例子：回调函数。`sync(param,cb)`，`sync`执行结束，才执行`cb`。从写法上看，似乎sync和cb是并行执行的。

## todo
综上，Monad的效果：赋值表面上是看不见的，顺序计算表面上是并行的。

回调函数的使用会导致很多问题(callback hell，和回调函数的信任问题)。在JavaScript中，用Promise可以处理回调函数带来的问题。形式上，把横向的函数调用变成竖直的，解决callback hell。Promise本身的状态只有三种，而且只会处于其中一种，解决了回调函数的信任问题。我们从Monad的层面来分析一下Promise。

## Monad典型种类与JavaScript实现

### 最简单的Monad: Identity Monad

仅仅是wrap一个值。

``` JavaScript
function Identity(value) {
    this.value = value;
}

Identity.prototype.bind = function (transform) { return transform(this.value)};
new Identity(5).bind(a => new Identity(6).bind(b => console.log(a + b)));
```

### Maybe Monad

除了像Identity Monad存储值，还可以表征缺少值。如果计算遇到Nothing，则随后的计算停止，直接返回Nothing。

``` JavaScript

function Just(value) {
    this.value = value;
}

Just.prototype.bind = function (transform) { return transform(this.value)};

let Nothing = {
    bind: function() {
        return this;
    }
};

let result = new Just(5).bind(value =>
                 Nothing.bind(value2 =>
                      new Just(value + value2)));

```

#### 可以用于避免因为null而产生的错误：

``` JavaScript

function getUser() {
    return {
        getAvatar: function() {
            return null; // no avatar
        }
    };
}

```
1. 捕获异常

``` JavaScript
try {
    let url = getUser().getAvatar().url;
    console.log(url); // this never happens
} catch (e) {
    console.log('Error: ' + e);
}

```

2. 或者做null检测

``` JavaScript
let user = getUser();
if (user !== null) {
    let avatar = user.getAvatar();
    if (avatar !== null) {
        url = avatar.url;
    }
}

```
3. 使用Maybe Monad

``` JavaScript
function getUser(){
    return new Just({
        getAvatar: function(avatar) {
            if (avatar) { // has avatar?
                return new Just(avatar);
            } else {
                return Nothing; // no avatar
            }
        }
    })};

let url = getUser()
        .bind(user => user.getAvatar())
        .bind(avatar => avatar.url);

if (url instanceof Just) {
    console.log('URL has value: ' + url.value);
} else {
    console.log('URL is empty.');
}

```

## Promise(Continuation Monad)

### 初略验证Promise是Monad

Promise即Cont Monad处理异步很有用。

unit funciton，warp数据返回Promise：`Promise.resolve(value)`
bind funciton，变换数据并返回Promise： `Promise.prototype.then(value => Promise)`

证明单位元：e + a = a

``` JavaScript
Promise.resolve(3).then(result => console.log(result));
// 3

Promise.resolve(Promise.resolve(3)).then(result => console.log(result));
// 3
```

证明结合律： (a + b) + c = a + (b + c)

``` JavaScript

// (a + b) + c
Promise
    .resolve(5)
    .then(value => Promise
                    .resolve(6)
                    .then(value2 => (value + value2)))
    .then(value => Promise
                    .resolve(7)
                    .then(value3 => (value + value3)))
    .then(result => console.log(result));

// a + (b + c)
Promise
    .resolve(5)
    .then(value => value)
    .then(value1 => Promise.resolve(6)
                        .then(value2 => Promise
                                            .resolve(7)
                                            .then(value3 => (0 + value1 + value2 + value3))))
    .then(result => console.log(result));

```

### 由CPS实现Promise

#### 组合函数

``` JavaScript
const add1 = x => x + 1;
const mul3 = x => x * 3;
const compose = (fn1, fn2) => x => fn1(fn2(x));
const addOneThenMul3 = compose(mul3, add1)
console.log(addOneThenMul3(4)) // 打印 15

```

`addOneThenMul3`由`add1`和`mul3`组合而成。

更复杂一点的例子，由两个Ajax请求，前一个请求返回后一个请求的url。

1. 假设请求syncAjax是同步请求：

``` JavaScript
const sync = url => {return syncAjax(url);};
const compose = (fn1, fn2) => x => fn1(fn2(x));
const result = compose(syncAjax, syncAjax)(urlString);
```

2. CPS处理异步请求ajax

``` JavaScript
const async = (url, cb) => ajax(url, cb);
const composeCPS = (fn1, fn2) => (x, cb) => fn1(x, x1 => fn2(x1, cb));
composeCPS(async, async)(urlString, reslut => console.log(result));
```

3. 柯里化

``` JavaScript
const async = url => cb => ajax(url, cb);
const composeCPS = (fn1, fn2) => x => cb => fn1(x)(x1 => fn2(x1)(cb));
composeCPS(async, async)(urlString)(reslut => console.log(result));
```

4. 添加done

``` JavaScript
const async = url => {
    return {
        done: cb => ajax(url, cb)
    };
};
const composeCPS = (fn1, fn2) => x => {
    return {
        done: cb => fn1(x).done(x1 => (fn2(x1).done(cb)))
    };
}

composeCPS(async, async)(urlString)
    .done(reslut => console.log(result));
```

5. 构造unit(Promise的resolve，或then，then也会返回Promise，这为了方便起见，只构造then)

a. 组合对象从函数，修改为doneObj

``` JavaScript
const createDoneObj = done  => ({done});

const async = url => {
    return createDoneObj(cb => ajax(url, cb)) ;
};

// 较大的修改，把第一个参数修改为doneObj
const bindDone = (doneObj, fn2) => {
    return createdDoneObj(cb => doneObj.done(x => (fn2(x).done(cb))));
};

bindDone(async(urlSting), async)
    .done(reslut => console.log(result));

```


b. bindDone放入createThenObj

``` JavaScript
const createThenObj = done => ({
    done,
    then(fn) {
        return fn.done ? fn.done : createThenObj(cb => this.done(x => (fn(x).done(cb))));
    }
});

const async = url => {
  return createThenObj(cb => {
    ajax(url, cb)
  })
};

async('urlString')
    .then(async)
    .done(result => console.log(reslut));
```


## React Hooks

pure functon 中利用 effects 去管理状态。

### 问题

#### Hooks为了解决三个问题(Sophie Alpert)：

>1. Reusing logic.目前的解决方案是HOCs和Render props，这两种方式会造成Components的不断嵌套，代码很难维护。 Giant components.
>2. react component中的有许多的lifecycle，在不同的lifecycle里面做不同的事情，开发人员需要将注意力分散到不同的lifecycle中去。
>3. Confusing classes. 基于class的component让初学者难以理解，同时runtime优化也很难做到。

#### this指针

class中用bind或箭头函数。

#### 复用

复用业务代码很麻烦。拆组件，然后要么render props，或render children，要么HoC，最不济props。修改组件就很麻烦。如果设计得要更灵活，就导致props或组件增加很多

写法上组件有wrapper hell问题，嵌套太深，性能也不好。

组件化有适用范围，只有基础的东西才值得组件化。

生命周期容易被滥用。容易出现面向对象的lifecycle写法。

### 抽象理解

- `useState(State Monad)`
- `useEffect(_->Algebraic Effect)` 注入Algebraic Effect。

Algebraic Effect简单来说是generator without yield。直观理解，如果render函数是一个generator，可以适当的时候yield出执行权(useState)，让框架做点事情(如记录state到VDOM)，然后框架再把render需要的数据返回到yield处(如上次的state和setState函数)

### 直观感受

useState隐藏了状态，但由于有this这种用来匹配状态和存储位置的指针的存在，也可能导致问题。

### 典型用法

shouldComponentUpdate对应的是React.memo

#### useReducer

``` JavaScript
const initialState = {count: 0};

function reducer(state, action) {
  switch (action.type) {
    case 'increment':
      return {count: state.count + 1};
    case 'decrement':
      return {count: state.count - 1};
    default:
      throw new Error();
  }
}

function Counter({initialState}) {
  const [state, dispatch] = useReducer(reducer, initialState);
  return (
    <>
      Count: {state.count}
      <button onClick={() => dispatch({type: 'increment'})}>+</button>
      <button onClick={() => dispatch({type: 'decrement'})}>-</button>
    </>
  );
}
```


## 赋值和局部状态

我们设计一个过程rand，每次调用会返回一个随机选出的整数。

假定我们有一个计算函数rand-update，同一个输入，会产生同一个输出。这个函数的性质是，如果从一个给定的数X1开始，执行下面的操作：
- x2 = (rand-update x1)
- x3 = (rand-update x2)
得到的序列x1,x2,x3,...将具有我们所希望的性质。

如果随机是序列中每一个数与前一个数无关，那么rand-update生成的数列肯定不是随机的。真正的随机序列与伪随机序列的关系很复杂。


如果允许赋值，我们可以把rand实现为：

``` scheme

(define rand
    (let ((x random-init))
        (lambda ()
            (set! x (rand-update x))
            x)))
```

可以看到我们使用了赋值语句`(set! x (rand-update x))`，x记录了每一次调用的局部状态，供下一次使用。这里，我们可以看到具有面向对象的想法，把状态封装在内部，实现了模块化的设计。

我们实现一个用随机数实现蒙特卡罗模拟：从一个大集合里随机选择样本，对试验的统计估计的基础上做出推断。6/(pi)^2是随机选择两个整数之间没有公因子（最大公因子GCD是1）的概率，利用这个特性来估计pi的值。

### 允许赋值的实现

``` scheme
(define (estimate-pi trials)
    (sqrt (/ 6 (monte-carlo trials cesaro-test))))

(define (cesaro-test)
    (= (gcd (rand) (rand)) 1))

(define (monte-carlo trials experiment)
    (define (iter trials-remaining trials-passed)
        (cont ((= trials-remaining 0)
                (/ trials-passed trials))
            ((experiment)
                (iter (- trials-remaining 1) (+ trials-passed 1)))
            (else (iter (- trials-remaining 1) trials-passed))))
    (iter trials 0))

```

### 不允许赋值的实现

``` scheme
(define (estimate-pi trials)
    (sqrt (/ 6 (random-gcd-test trials random-init))))

(define (random-gcd-test trials initial-x)
    (define (iter trials-remaining trials-passed x)
        (let ((x1 (rand-update x)))
            (let ((x2 (rand-update x1)))
                (cont ((= trials-remaining 0)
                        (/ trials-passed trials))
                    ((= (gcd x1 x2) 1)
                        (iter (- trials-remaining 1)
                            (+ trials-passed 1)
                            x2))
                    (else
                        (iter (- trials-remaining 1)
                            trials-passed
                            x2))))))
    (iter trials 0 initial-x))

```

在不允许赋值的情况下，random-gcd-test必须显示地操作随机数x1和x2，并把x2传递给rand-update作为新的输入。随机数的显式处理(rand-update)，和累积结果的检查(trials-remianing等代码)，交织在一起。同时导致了，上层调用estimate-pi也需要提供随机数的初始值，无法将蒙特卡罗方法独立出来。

蒙特卡罗方法的例子，显示了一种普遍的现象：假如一个复杂过程，包含A、B、C、D...，从A的视角看，其他部分B、C、D...，在随时间不断变化，但他们隐藏了自己随时间变化的状态。用局部状态去模拟系统状态，用变量的赋值如模拟状态变化。

与所有状态必须显式的操作和传递参数的不能赋值的方法相比，使用赋值和将状态隐藏在局部变量中的方法，设计构造的系统更加模块化。不用使用任何赋值的程序设计，称之为函数式程序设计，可以使用代换模型简洁的解释。代换模型中，符号（变量）只不过是作为值得名称。同一个东西可以互换，替换不会改变表达式的值，称之为这个语言有引用透明性。

而引入赋值之后，符号不能再作为值的名称。变量索引了一个环境中可以保存值的位置，存储在那里的值可以改变。使用赋值的程序设计，称之为命令式程序设计。会导致计算模型复杂，同时会导致一些不容易出现函数式编程中的错误。赋值与时间顺序显式的相关，那么一个变量放在另一个之前，还是之后，就很不易处理。


#### 不允许赋值的monte-carlo流的实现

``` scheme
; 随机数流
; rand-update的定义见上文
(define random-numbers
    (cons-stream random-init
        (stream-map rand-update random-numbers)))

; cesaro实验流
(define cesaro-stream
    (map-successive-pairs (lambda (r1 r2) (= (gcd r1 r2) 1))
        random-numbers))

(define (map-successive-pairs f s )
    (cons-stream
        (f (stream-car s) (stream-car (stream-cdr s)))
        (map-successive-pairs f (stream-cdr s))))

; cesaro-stream溃入monte-carlo过程，生成一个可能估计值的流，再变换，得到估计pi值的流。无需参数告知要实验多少次
(define (monte-carlo experiment-stream passed failed)
    (define (next passed failed)
        (cons-stream
            (/ passed (+ passed failed))
            (monte-carlo
                (stream-car experiment-stream) passed failed)))
    (if (stream-car experiment-stream)
        (next (+ passed 1) failed)
        (next passed (+ failed 1))))

(define pi
    (steam-map (lambda (p) (sqrt (/ 6 p)))
    (monte-carlo cesaro-stream 0 0)))
```

通过流，也构造了一个模块化的monte-carlo过程，无赋值，无状态。

## Monad缺点

Dijkstra语录：

> 程序的优雅性不是可以或缺的奢侈品，而是决定成功还是失败的一个要素。优雅并不是一个美学的问题，也不是一个时尚品味的问题，优雅能够被翻译成可行的技术。牛津字典对 elegant 的解释是：pleasingly ingenious and simple。如果你的程序真的优雅，那么它就会容易管理。第一是因为它比其它的方案都要短，第二是因为它的组件都可以被换成另外的方案而不会影响其它的部分。很奇怪的是，最优雅的程序往往也是最高效的。

> 我的母亲是一个优秀的数学家。有一次我问她几何难不难，她说一点也不难，只要你用“心”来理解所有的公式。如果你需要超过5行公式，那么你就走错路了。

> 为什么这么少的人追求优雅？这就是现实。如果说优雅也有缺点的话，那就是你需要艰巨的工作才能得到它，需要良好的教育才能欣赏它。

## 资料

### todo

- [Monad入门](https://thzt.github.io/2015/03/07/monad/)

### done

- [函数式语言的宗教](http://www.yinwang.org/blog-cn/2013/03/31/purely-functional)

- [A Schemer's Introduction to Monads](http://www.ccs.neu.edu/home/dherman/research/tutorials/monads-for-schemers.txt)

- [陈年译稿——一个面向Scheme程序员的monad介绍](http://www.cnblogs.com/fzwudc/archive/2011/04/19/2020982.html)

- [从函数式编程到Promise](https://blog.fundebug.com/2017/06/21/write-monad-in-js/)

- [Monads in JavaScript](https://curiosity-driven.org/monads-in-javascript#)

## change log

- 2019/4/5 重读SICP第3章
- 2019/4/6 收集资料
- 2019/4/7 半夜，范畴论wiki整理完毕
- 2019/4/7 1点多，证明Promise是Monad
- 2019/4/7 深夜，思考Promise的工程化的逐步实现，导致失眠，我是一年失眠不会超过两次的人
- 2019/4/7 Promise构造，初步完毕。代码是当数学符号在写，未验证，以后要验证一下
- 2019/4/7 下午，摘录SICP上讨论流的实现，例子是蒙特卡罗方法求pi
- 2019/4/7 晚上，整理React Hooks资料
- 2019/4/11 半夜，整理Generators资料
- 2019/4/11 上午，移除范畴论，新建数学文档
- 2019/4/29 上午，修改代码，以及语言组织
- 2019/4/29 上午，删除有关流的章节，新建文档描述流
