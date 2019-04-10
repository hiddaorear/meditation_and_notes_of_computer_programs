# Monad

#### 2019/4/6

## 直观感觉

Monad是一个抽象的数学概念，不容易给出直观的准确描述。类似的有量子力学里的波粒二象性和自旋向上、自旋向下，本质上要通过数学去感知，很难找到既是粒子也是波的可感知的物品，也很难找到一个在三维空间中只有两个方向的可感知的物品。读了很多人对Monad的讲述，我认为，王垠对Lisp的评判的文章《函数式语言的宗教》中的例子：用随机数生成函数，说明无“状态”或“全局变量”的缺点，不能轻松表达random这样的”不纯函数。恰到好处地描述了Monad在编程的本质。

> 为了达到“纯函数”的目标，我们需要做很多“管道工”的工作，这增加了程序的复杂性和工作量。如果我们可以把种子存放在一个全局变量里，到需要的时候才去取，那就根本不需要把它传来传去的。除 random() 之外的代码，都不需要知道种子的存在。

> 为了减轻视觉负担和维护这些进进出出的“状态”，Haskell 引入了一种叫 monad 的概念。它的本质是使用类型系统的“重载”（overloading），把这些多出来的参数和返回值，掩盖在类型里面。

从编程的角度，Monad有两个接口：return/unit和bind。实现这个两个操作的类型，就可以称之为Monad。就像光有些情况下，如光电效应实验，粒子性显著一些，另一些情况下，如干涉和衍射实验，波的性质显著一些。光的粒子性和波动性，依赖实验设备。同样，Monad一些情况下可以看做容器，如Maybe Monad，return一个数据到Monad，用bind从Monad取出来。另一些情况看作有状态的函数，如State Monad。Monad不仅仅是用来处理副作用，典型的处理副作用的Monad：IO Monad.

从王垠的例子：

``` c
int random()
{
  static int seed = 0;
  seed = next_random(seed);
  return seed;
}
```

在Haskell中`（旧种子）---> （新随机数，新种子）`。由于Haskell中不允许赋值语句`seed = next_random(seed)`，想办法把种子`seed`放在函数的参数里，这样来接受输入。进一步，Monad在这个情形中，可以认为是用函数的参数实现了赋值语句的能力，赋值被Monad隐藏了。


但这样去理解Monad，会有偏差。维特根斯坦说： a definition of logical form as opposite to logical matter"“(对逻辑形式，而非逻辑内容的定义)。不能用monad的应用来定义monad，而只能依靠monad的形式。

编程中经常遇到CPS(可以理解为计算中的延续)，是Monad中的一种，适合IoC(Inversion of Control，控制反转，也是DI:Dependency Injection)场景。
IoC 的核心思想是 “Don’t call me, I’ll call you”，也被叫作”好莱坞原则"，据说是好莱坞经纪人的口头禅。 IoC在编程中的典型例子：回调函数。`sync(param,cb)`，`sync`执行结束，才执行`cb`。从写法上看，似乎sync和cb是并行执行的。

综上，Monad的效果：赋值表面上是看不见的，顺序计算表面上是并行的。

回调函数的使用会导致很多问题(callback hell，和回调函数的信任问题)。在JavaScript中，用Promise可以处理回调函数带来的问题。形式上，把横向的函数调用变成竖直的，解决callback hell。Promise本身的状态只有三种，而且只会处于其中一种，解决了回调函数的信任问题。我们从Monad的层面来分析一下Promise。

## Promise(Continuation Monad)

### 初略验证Promise是Monad

Promise即Cont Monad处理异步很有用。

unit funciton，warp数据返回Promise：`Promise.resolve(value)`
bind funciton，变换数据并返回Promise： `Promise.prototype.then(onFullfill: value => Promise)`

证明单位元：e + a = a

``` JavaScript
Promise.resolve(Promise.resolve(3)).then(result => console.log(result));
// 3

Promise.resolve(3).then(result => console.log(result));
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
const createDoneObj = done  => {{done}};

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

## Monad典型种类与JavaScript实现

### 最简单的Monad: Identity Monad

仅仅是wrap一个值。

``` JavaScript
function Identity(value) {
    this.value = value;
}

Identity.prototype.bind = funciton (transform) { return transform(this.value)};
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

可以用于因为null而产生的错误：

``` JavaScript

function getUser() {
    return {
        getAvatar: function() {
            return Nothing; // no avatar
        }
    };
}

// 捕获异常
try {
    var url = getUser().getAvatar().url;
    print(url); // this never happens
} catch (e) {
    print('Error: ' + e);
}

// 或者做null检测
var user = getUser();
if (user !== null) {
    var avatar = user.getAvatar();
    if (avatar !== null) {
        url = avatar.url;
    }
}

// 使用Maybe Monad

function getUser(){
    return new Just({
        getAvatar: function() {
            if (hasAvatar) {
                return new Just(avatar);
            } else {
                return null; // no avatar
            }
        }
    });

url = getUser()
        .bind(user => user.getAvatar())
        .bind(avatar => avatar.url);
}

// 这样写，似乎会导致一个麻烦，不知道哪一步产生了null值。
// 这个写法本质上，消除了赋值语句，而正是赋值语句报错或判空，才知道是哪一步有问题。

if (url instanceof Just) {
    print('URL has value: ' + url.value);
} else {
    print('URL is empty.');
}

```

## React Hooks

### 问题

#### Sophie Alpert，Hooks为了解决三个问题：

>1. Reusing logic.目前的解决方案是HOCs和Render props，这两种方式会造成Components的不断嵌套，代码很难维护。 Giant components.
>2. react component中的有许多的lifecycle，在不同的lifecycle里面做不同的事情，开发人员需要将注意力分散到不同的lifecycle中去。
>3. Confusing classes. 基于class的component让初学者难以理解，同时runtime优化也很难做到。

#### this指针

class中用bind或箭头函数。

#### 复用

复用业务代码很麻烦。拆组件，然后要么render props，或render childrend，要么HoC，最不济props。修改组件就很麻烦。如果设计得要更灵活，就导致props或组件增加很多


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

### 优缺点

## Iterators and Generators(JavaScript)

### Generators and Monad

## scheme的流和Generators

我们设计一个过程rand，每次调用会返回一个随机选出的整数。

假定我们有一个计算函数rand-update，同一个输入，会产生同一个输出。这个函数的性质是，如果从一个给定的数X1开始，执行下面的操作：
- x2 = (rand-update x1)
- x3 = (rand-update x2)
得到的序列x1,x2,x3,...将具有我们所希望的性质。

如果随机是序列中每一个数与前一个数无关，那么rand-update生成的数列肯定不是随机的。真正的随机序列与伪随机序列的关系很复杂。

### 赋值和局部状态

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

### 允许赋值

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

### 不允许赋值

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

### 流

流优点在于，能忽略程序中各个时间的实际发生顺序，这是赋值无法做到的事情，赋值就需要考虑时间和变化。

#### 流的实现

流有构造函数`cons-stream`，和两个选择函数`stream-car`和`stream-cdr`，满足两个条件：

- (stream-car (cons-stream x y)) = x
- (stream-cdr (cons-stream x y)) = y

流基于delay的特殊形式实现，`(delay <exp>)`的求值将不对表达式`<exp>`求值，而是返回一个延时对象，可以看做是未来的某个时间求值`<exp>`的许诺。与之对应，有force，迫使delay完成所许诺的求值。(延时想起了，类似的定义，jQuery中Ajax的deferred)

使用序对来构造流，不过cdr部分放的并非是流的后面的部分，而是存放的可以计算其的许诺。

`(cons-stream <a> <b>)` 等价于 `(cons <a> (delay <b>))`。

delay和force怎么实现呢？delay可以看做一个函数，执行的时候才求值，而force则只需要执行这个函数即可。

cons-stream则可以实现为：

``` scheme
(define (cons-stream exp delay)
    (cons exp (lamdba () (delay))))

; 定义正整数无穷流
(define (integers-startring-from n)
    (const-stream n (integers-startring-from (+ n 1))))
(define integers-stream (integers-startring-from 1))
```

`(delay <exp>)`其实是语法糖`(lambda () <exp>)`。而force不过是无参的调用过程：

``` scheme
(define (force delayed-object)
    (delayed-object))
```


``` scheme

(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))

; map
(define (stream-map proc s)
    (if (stream-null? s)
        the-empty-stream
        (cons-stream (proc (stream-car s))
            (stream-map proc (stream-cdr s)))))

```

#### monte-carlo流的实现

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

#### 流是Monad吗？

unit是什么？
bind是怎么实现？


## 范畴论

> A monad is just a monoid in the category of endofunctors, what's the problem?
-- by James Iry

手头没有范畴论的数学书，摘录wiki。

### 群group

在数学中，群（group）是由一个集合以及一个二元运算所组成的，符合下述四个性质（称为“群公理”）的代数结构。这四个性质是封闭性、结合律、单位元和对于集合中所有元素存在逆元素。很多熟知的数学结构比如数系统都遵从群公理，例如整数配备上加法运算就形成一个群。如果将群公理的公式从具体的群和其运算中抽象出来，就使得人们可以用灵活的方式来处理起源于抽象代数或其他许多数学分支的实体，而同时保留对象的本质结构性质。

群在数学内外各个领域中是无处不在的，这使得它们成为当代数学的组成的中心原理。

群与对称性有密切的联系。例如，对称群描述了几何体的对称性：它是保持物体不变的变换的集合。李群应用于粒子物理的标准模型之中；庞加莱群也是李群，能表达狭义相对论中的对称性；点群能帮助理解分子化学中的对称现象。

#### 定义

群(G,·)是由集合G和二元运算"·"构成的，符合以下四个性质（称“群公理”）的数学结构。其中，二元运算结合任何两个元素a和b而形成另一个元素，记为a·b，符号"·"是具体的运算，比如整数加法。

群公理所述的四个性质为：

1. 封闭性：对于所有G中a, b，运算a·b的结果也在G中。
2. 结合律：对于所有G中的a, b和c，等式 (a·b)·c = a· (b·c)成立。
3. 单位元：存在G中的一个元素e，使得对于所有G中的元素a，总有等式 e·a = a·e = a 成立。
4. 逆元：对于每个G中的a，存在G中的一个元素b使得总有a·b = b·a = e，此处e为单位元。
群运算的次序很重要，把元素a与元素b结合，所得到的结果不一定与把元素b与元素a结合相同；亦即， a·b=b·a （交换律）不一定恒成立。满足交换律的群称为交换群（阿贝尔群，以尼尔斯·阿贝尔命名），不满足交换律的群称为非交换群（非阿贝尔群）。

整数加法群中，对于任何两个整数都有 a + b = b + a （加法的交换律）成立，因此，整数加法群是交换群。但是对称群中交换律并不总是成立，所以一般的对称群不是交换群。

群G的单位元经常记做1或1G，这个记号来自乘法单位元。对于阿贝尔群，可以把群运算记做+，单位元记做0；这种情况下群称为加法群。单位元也可记做id。

群(G, ·) 也常常简记为G。可以根据上下文来判断一个符号指的是集合还是群。

#### 例子

例一：整数加法群
最常见的群之一是整数集Z和整数的加法所构成的群。它由以下数列组成：

..., −4, −3, −2, −1, 0, 1, 2, 3, 4, ...

下面将整数的加法的性质与四个群公理做对比，可以看出，整数集和整数的加法是可以构成群的。

对于任何两个整数a和b，它们的和a + b也是整数。换句话说，在任何时候，把两个整数相加都能得出整数的结果。这个性质叫做在加法下封闭。

对于任何整数a, b和c，(a + b) + c = a +（b + c）。用话语来表达，先把a加到b，然后把它们的和加到c，所得到的结果与把a加到b与c的和是相等的。这个性质叫做结合律。

如果a是任何整数，那么0 + a = a + 0 = a。零叫做加法的单位元，因为把它加到任何整数都得到相同的整数。

对于任何整数a，存在另一个整数b使得a + b = b + a = 0。整数b叫做整数a的逆元，记为−a。

[群wiki](https://zh.wikipedia.org/wiki/%E7%BE%A4#cite_note-3)

### 半群semigroup

在数学中，半群是闭合于结合性二元运算之下的集合 S 构成的代数结构。

半群的运算经常指示为乘号，也就是或简写为 x·y 来指示应用半群运算于有序对 (x, y) 的结果。

半群的正式研究开始于二十世纪早期。自从1950年代，有限半群的研究在理论计算机科学中变得特别重要，因为在有限半群和有限自动机之间有自然的联系。

#### 定义

集合S和其上的二元运算·:S×S→S。若·满足结合律，即：∀x,y,z∈S，有(x·y)·z=x·(y·z)，则称有序对(S,·)为半群，运算·称为该半群的乘法。实际使用中，在上下文明确的情况下，可以简略叙述为“半群S”。

#### 例子

作为一种平凡的情形，空集是一个半群。
正整数带有加法运算。

[半群wiki](https://zh.wikipedia.org/wiki/%E5%8D%8A%E7%BE%A4)

### 幺半群monoid

在抽象代数此一数学分支中，幺半群（英语：monoid，又称为单群、亚群、具幺半群或四分之三群）是指一个带有可结合二元运算和单位元的代数结构。

幺半群在许多的数学分支中都会出现。在几何学中，幺半群捉取了函数复合的概念；更确切地，此一概念是从范畴论中抽象出来的，之中的幺半群是个带有一个对象的范畴。幺半群也常被用来当做计算机科学的坚固代数基础；在此，变换幺半群和语法幺半群被用来描述有限状态自动机，而迹幺半群和历史幺半群则是做为进程演算和并行计算的基础。

#### 定义

幺半群是一个带有二元运算 `*: M × M → M` 的集合 M ，其符合下列公理：

- 结合律：对任何在 M 内的a、b、c ， `(a*b)*c = a*(b*c)` 。
- 单位元：存在一在 M 内的元素e，使得任一于 M 内的 a 都会符合 `a*e = e*a = a `。

通常也会多加上另一个公理：
封闭性：对任何在 M 内的 a 、 b ， `a*b` 也会在 M 内。
但这不是必要的，因为在二元运算中即内含了此一公理。

另外，幺半群也可以说是带有单位元的半群。

幺半群除了没有逆元素之外，满足其他所有群的公理。因此，一个带有逆元素的幺半群和群是一样的。

#### 和范畴论的关系

幺半群可视之为一类特殊的范畴。幺半群运算满足的公理同于范畴中从一个对象到自身的态射。换言之：

> 幺半群实质上是只有单个对象的范畴。

精确地说，给定一个幺半群 `(M,*)`，可构造一个只有单个对象的小范畴，使得其态射由 M 的元素给出，而其合成则由 幺半群的运算 * 给出。

同理，幺半群之间的同态不外是这些范畴间的函子。就此意义来说，范畴论可视为是幺半群概念的延伸。许多关于幺半群的定义及定理皆可推广至小范畴。

幺半群一如其它代数结构，本身也形成一个范畴，记作 Mon，其对象是幺半群而态射是幺半群的同态。

范畴论中也有幺半对象的概念，它抽象地定义了何谓一个范畴中的幺半群。

#### 例子

- 自然数N是加法及乘法上的可交换幺半群。

[幺半群wiki](https://zh.wikipedia.org/wiki/%E5%B9%BA%E5%8D%8A%E7%BE%A4)

### 范畴

在范畴论中，范畴此一概念代表着一堆数学实体和存在于这些实体间的关系。

范畴论是数学的一门学科，以抽象的方法来处理数学概念，将这些概念形式化成一组组的“物件”及“态射”。数学中许多重要的领域可以形式化成范畴，并且使用范畴论，令在这些领域中许多难理解、难捉摸的数学结论可以比没有使用范畴还会更容易叙述及证明。

范畴最容易理解的一个例子为集合范畴，其物件为集合，态射为集合间的函数。但需注意，范畴的物件不一定要是集合，态射也不一定要是函数；一个数学概念若可以找到一种方法，以符合物件及态射的定义，则可形成一个有效的范畴，且所有在范畴论中导出的结论都可应用在这个数学概念之上。

#### 定义

一个范畴C包括：

一个由物件所构成的类ob(C)
物件间的态射所构成的类hom(C)。每一个态射f都会有唯一个“源物件”a和“目标物件”b，且 a和b都在ob(C)之内。因此写成f: a → b，且称f为由a至b的态射。所有由a至b的态射所构成的“态射类”，其标记为hom(a, b) （或 homC(a, b)）。

对任三个物件a、b和c，二元运算hom(a, b)×hom(b, c)→hom(a, c)称之为态射复合；f : a → b和g : b → c的复合写成g o f或gf。
此态射复合满足下列公理：

（结合律）若f : a → b、g : b → c且h : c → d，则h o(g o f)=(h o g)o f；
（单位元）对任一物件x，存在一态射1x : x → x，使得每一态射f : a → b，都会有1b o f = f = f o 1a。此一态射称为“x的单位态射”。
由上述公理，可证明对每一个物件均只确实地存在着单一个单位态射。一些作者会将每一个物件等同于其相对应的单位态射。

小范畴是一个ob(C)和hom(C)都是集合而不是真类的范畴。不是小范畴的范畴则称之为大范畴。局部小范畴是指对所有物件a和b，态射类hom(a,b)都会是集合（被称之为态射集合）的一个范畴。许多在数学中的重要范畴（如集合的范畴），即使不是小范畴，但也都至少会是局部小范畴。

[范畴论wiki](https://zh.wikipedia.org/wiki/%E8%8C%83%E7%95%B4%E8%AE%BA)

### 态射

数学上，态射（morphism）是两个数学结构之间保持结构的一种过程抽象。

最常见的这种过程的例子是在某种意义上保持结构的函数或映射。例如，在集合论中，态射就是函数；在群论中，它们是群同态；而在拓扑学中，它们是连续函数；在泛代数（universal algebra）的范围，态射通常就是同态。

对态射和它们定义于其间的结构（或对象）的抽象研究构成了范畴论的一部分。在范畴论中，态射不必是函数，而通常被视为两个对象（不必是集合）间的箭头。不像映射一个集合的元素到另外一个集合，它们只是表示域（domain）和陪域（codomain）间的某种关系。

#### 定义

一个范畴C由两个类给定：一个对象的类和一个态射的类。

有两个操作定义在每个态射上，域（domain，或源）和陪域（codomain，或目标）。

态射经常用从域到他们的陪域的箭头来表示，例如若一个态射f域为X而陪域为Y，它记为f : X → Y。所有从X到Y的态射的集合记为homC(X,Y)或者hom(X, Y)。（有些作者采用MorC(X,Y)或Mor(X, Y)）。

对于任意三个对象X，Y，Z，存在一个二元运算hom(X, Y)×hom(Y, Z) → hom(X, Z)称为复合。f : X → Y和g : Y → Z的复合记为g o f 或gf（有些作者采用fg）。态射的复合经常采用交换图来表示。例如

![MorphismComposition-01](./MorphismComposition-01.png)

态射必须满足两条公理：

存在恒等态射：对于每个对象X，存在一个态射idX : X → X称为X上的恒等态射，使得对于每个态射f : A → B我们有idB o f = f = f o idB

满足结合律：h o (g o f) = (h o g) o f 在任何操作有定义的时候。

当C是一个具体范畴的时候，复合只是通常的函数复合，恒等态射只是恒等函数，而结合律是自动满足的。（函数复合是结合的。）

[态射wiki](https://zh.wikipedia.org/wiki/%E6%80%81%E5%B0%84)

### 函子Functor

在范畴论中，函子是范畴间的一类映射。函子也可以解释为小范畴范畴内的态射。

函子会保持单位态射与态射的复合。一个由一范畴映射至其自身的函子称之为“自函子”。

[函子wiki](https://zh.wikipedia.org/wiki/%E5%87%BD%E5%AD%90)

### group/semigroup/monoid的命名

> - 对乘法封闭的集合，就是 magma，汉译「原群」
> - 乘法结合律的原群，就是 semigroup，汉译「半群」
> - 带有单位元的半群，就是 monoid，汉译「幺半群」
> - 带有逆元的幺半群，就是 group 群

> Mono- 幺 （源于希腊语的词缀）
> -id 用于形成名词的后缀，无实义 （同样源于希腊语的后缀）

>Group 群 有4个性质 C.A.N.I.
>- C: Close 封闭性
>- A: Associative 连续性
>- N: Neutral (or Identity = Id) 幺元
>- I: Inverse 逆元
>- Semi-Group 半群 只有2个性质: C.A.

Monoid 么半群 : C.A. + N (= Id) => Mono + Id


知乎：

[为什么「群」和「半群」的英文是 group 和 semigroup，而「幺半群」却是 monoid](https://www.zhihu.com/question/37100637)

[数学中代数的有两个名词：环，半群，请问环为什么叫做环，它和汉字里的环（字典中的意思）有什么相同之处；同样，半群为什么叫做半群，这个”半“字是怎么解释呢？](https://www.zhihu.com/question/20564445)

## Monad缺点

Dijkstra语录：

> 程序的优雅性不是可以或缺的奢侈品，而是决定成功还是失败的一个要素。优雅并不是一个美学的问题，也不是一个时尚品味的问题，优雅能够被翻译成可行的技术。牛津字典对 elegant 的解释是：pleasingly ingenious and simple。如果你的程序真的优雅，那么它就会容易管理。第一是因为它比其它的方案都要短，第二是因为它的组件都可以被换成另外的方案而不会影响其它的部分。很奇怪的是，最优雅的程序往往也是最高效的。

> 我的母亲是一个优秀的数学家。有一次我问她几何难不难，她说一点也不难，只要你用“心”来理解所有的公式。如果你需要超过5行公式，那么你就走错路了。

> 为什么这么少的人追求优雅？这就是现实。如果说优雅也有缺点的话，那就是你需要艰巨的工作才能得到它，需要良好的教育才能欣赏它。

## 资料

### Monad

SICP

- [函数式语言的宗教](http://www.yinwang.org/blog-cn/2013/03/31/purely-functional)

- [A Schemer's Introduction to Monads](http://www.ccs.neu.edu/home/dherman/research/tutorials/monads-for-schemers.txt)

- [陈年译稿——一个面向Scheme程序员的monad介绍](http://www.cnblogs.com/fzwudc/archive/2011/04/19/2020982.html)

- [从函数式编程到Promise](https://blog.fundebug.com/2017/06/21/write-monad-in-js/)

- [Monads in JavaScript](https://curiosity-driven.org/monads-in-javascript#)

### 流

- [流，计数与生成函数](http://notebook.xyli.me/SICP/stream-count-and-generating-function/)

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
