# The Racket Guide

## Interpreter by Racket

### calculate

``` Racket
#lang racket

(define calc
  (lambda (exp)
    (match exp
      [(? number? x) x]
      [`(,op, e1, e2)
       (let ([v1 (calc e1)]
             [v2 (calc e2)])
         (match op
           [`+ (+ v1 v2)]
           [`- (- v1 v2)]
           [`* (* v1 v2)]
           [`/ (/ v1 v2)]))])))

(calc `(+ 1 2))
(calc `(* (+ 1 2)(+ 3 4)))

```

### interpreter

``` Racket
#lang racket

(define env0 '())

(define ext-env
  (lambda (x v env)
          (cons `(,x ., v) env)))


(define lookup
  (lambda (x env)
          (let ([p (assq x env)])
            (cond
              [(not p) #f]
              [else (cdr p)]))))

(struct Closure (f env))

(define interp
  (lambda (exp env)
    (match exp
      [(? symbol? x)
       (let ([v (lookup x env)])
         (cond
           [(not v)
            (error "undefined variable" x)]
           [else v]))]
      [(? number? x) x]
      [`(lambda (,x), e)
       (Closure exp env)]
      [`(let ([,x, e1]), e2)
       (let ([v1 (interp e1 env)])
         (interp e2 (ext-env x v1 env)))]
      [`(,e1, e2)
       (let ([v1 (interp e1 env)]
             [v2 (interp e2 env)])
         (match v1
           [(Closure `(lambda (,x), e) env-save)
            (interp e (ext-env x v2 env-save))]))]
      [`(,op, e1, e2)
       (let ([v1 (interp e1 env)]
             [v2 (interp e2 env)])
         (match op
           ['+ (+ v1 v2)]
           ['- (- v1 v2)]
           ['* (* v1 v2)]
           ['/ (/ v1 v2)]))])))

(define r2
  (lambda (exp)
    (interp exp env0)))


(r2 '(+ 1 2))
(r2 '(* (+ 1 2) (+ 3 4)))

(r2
 '(let ([x 2])
      (let ([f (lambda (y) (* x y))])
         (f 3))))

(r2
 '(let ([x 2])
 (let ([f (lambda (y) (* x y))])
   (let ([x 4])
     (f 3)))))

```

## 基础语法疑问

### ``(,op, e1, e2)`中，为什么要在首位写逗号？

### ``(,x ., v) ` 中，为什么要写逗号？官方文档没有这种怪异的写法

## 完整代码

- [calc](./calc.rkt)

- [interpreter](./interp.rkt)

## 参考资料

- [怎样写一个解释器](https://www.yinwang.org/blog-cn/2012/08/01/interpreter)

## change log

- 2019/11/10 created doc。瑶瑶回老家，妹妹因婚事有矛盾，惹人生气，一个人在深圳思考并写代码。
