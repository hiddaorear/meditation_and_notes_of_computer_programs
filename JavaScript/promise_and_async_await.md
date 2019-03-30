# Promise

## 理解Promise

给予我们用回调处理异步的时候丢失的最重要的语言基石：return，throw和堆栈。(回调的坏处，整个代码流程基于副作用，一个函数会调用其他函数，丢失了return和throw)。

Promsie是一种代码结构和流程。

Promise只能返回Promise，因为他是异步的。

## 异常

### then的第二个参数和catch的区别

````javascript
Promise
    .reject('error')
    .then(() => {}, val => {
        console.log(val);
    });

Promise
.reject('error')
.cath(val => {
    console.log(val);
});
````

主要区别，如果then的第一个函数中抛出异常，后面的catch能捕获到，而第二个参数中的函数是捕获不到的

````javascript
p
.then(() => {
    throw new Error();
}, () => {
    // 不能捕获同一级的error
})
.catch(() => {
    // 能捕获
})

````

误区：
1. reject是用来抛出异常的，catch是用来处理异常的，reject相当于try catch中的throw
2. catch是Promise的实例方法，reject是Promise的静态方法

````javascript
let p = new Promsie();
p.catch();
p.reject(); // 无
Promise.reject();
Promise.catch(); // 无

另，可以这么理解，catch是then的语法糖

````javascript
Promise.prototype.catch = function(fn) {
    return this.then(null, fn);
}

````

### new Promise()中的异常处理

````javascript
new Promsie((resolve, reject) => {
    if (error) {
        reject();
    } else {
        resolve();
    }
})
.then(res => {
    // ...
});

````

### resolve与throw和catch

怎么理解以下结果？

````javascript
// 1
var promise = new Promise(function(resolve, reject) {
    resolve("ok");
    throw new Error('wtf')
    //setTimeout(function() { throw new Error('test') }, 0)
});
promise.then(function(value) { console.log(value) })
    .catch((err)=>{
        console.log(err)
    })
process.on('unhandledRejection', function (err, p) {
    console.error('catch exception:',err.stack)
});
// 结果为：
// ok

// 2
var promise = new Promise(function(resolve, reject) {
    resolve("ok");
    //throw new Error('wtf')
    setTimeout(function() { throw new Error('test') }, 0)
});
promise.then(function(value) { console.log(value) })
    .catch((err)=>{
        console.log(err)
    })
process.on('unhandledRejection', function (err, p) {
    console.error('catch exception:',err.stack)
});

 /* 结果为:
ok
/Users/yj/WebstormProjects/ife_solution/task0/async/asyn2.js:7
    setTimeout(function() { throw new Error('test') }, 0)
                            ^

Error: test
    at null._onTimeout (/Users/yj/WebstormProjects/ife_solution/task0/async/asyn2.js:7:35)
    at Timer.listOnTimeout (timers.js:92:15)
*/

// 3
var promise = new Promise(function(resolve, reject) {
    resolve("ok");
    throw new Error('wtf')
    setTimeout(function() { throw new Error('test') }, 0)
});
promise
    .then((value)=>{
        console.log(value);
    })
    .catch((err)=>{
        console.log(err)
    });

process.on('unhandledRejection', function (err, p) {
    console.error('catch exception:',err.stack)
});
/*结果为
ok
*/
````

为什么Promise中抛出异常和setTimeout回调函数抛出的异常不同？
1和2，Promise中resolve之后，throw new Error不会导致onRejece函数调用。而setTimeout是异步过程，此种写法，无法被promise处理，就直接抛出了；
3中，抛异常，导致setTimeout没有执行，而所抛的异常被吞掉了（原因见1和2的分析）

如果不是一个函数，就会被解释为then(null)，会导致前一个promise的结果穿透到下面；then中值，期望是一个函数

```` javascript
Promise.resolve('foo').then(Promise.resolve('bar')).then(function (result) {
  console.log(result);
});

// foo，而非bar

Promise.resolve('foo').then(null).then(function (result) {
  console.log(result);
});

// foo，而非bar
````

### Promise构造函数是同步执行的，而promise.then中的函数是异步执行的

```` javascript
const promise = new Promise((resolve, reject) => {
  console.log(1)
  resolve()
  console.log(2)
})
promise.then(() => {
  console.log(3)
})
console.log(4)

// 1 2 4 3

````

### 题目

```` javascript
// 1
const promise = new Promise((resolve, reject) => {
  resolve('success1')
  reject('error')
  resolve('success2')
})

promise
  .then((res) => {
    console.log('then: ', res)
  })
  .catch((err) => {
    console.log('catch: ', err)
  })

// 运行结果：
// then: success1
// 构造函数中的 resolve 或 reject 只有第一次执行有效，多次调用没有任何作用，promise 状态一旦改变则不能再变。


// 2
Promise.resolve()
  .then(() => {
    return new Error('error!!!')
  })
  .then((res) => {
    console.log('then: ', res)
  })
  .catch((err) => {
    console.log('catch: ', err)
  })

// 运行结果：
/*
then: Error: error!!!
    at Promise.resolve.then (...)
    at ...
*/

/*
.then 或者 .catch 中 return 一个 error 对象并不会抛出错误，所以不会被后续的 .catch 捕获，需要改成其中一种：

return Promise.reject(new Error('error!!!'))
throw new Error('error!!!')
因为返回任意一个非 promise 的值都会被包裹成 promise 对象，即 return new Error('error!!!') 等价于 return Promise.resolve(new Error('error!!!'))。

*/

// 3
Promise.resolve(1)
  .then(2)
  .then(Promise.resolve(3))
  .then(console.log)

// 运行结果：
// 1
// 解释：.then 或者 .catch 的参数期望是函数，传入非函数则会发生值穿透。

````


## async await

async function声明用于定义一个返回AsyncFunction对方的异步函数。异步函数是指通过事件循环异步执行的函数，会通过一个隐式的Promise返回结果。他的语法和结构，像是标准的同步函数。

### 优点

比Promise更便于定位异常代码位置。Promise中虽然catch能捕获异常，但异常不一定发生在catch中，而是发生在其他地方。async中，代码结构是同步，很方便定位。

### 缺点

异步的并发执行，不如`Promise.all()`方便。
