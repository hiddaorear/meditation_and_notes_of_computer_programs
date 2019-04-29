# stream

流优点在于，能忽略程序中各个时间的实际发生顺序，这是赋值无法做到的事情，赋值就需要考虑时间和变化。

## 流的实现

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

## 参考资料

- [流，计数与生成函数](http://notebook.xyli.me/SICP/stream-count-and-generating-function/)



## change log

- 2019/4/29 created doc
