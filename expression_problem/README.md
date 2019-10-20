# Expression problem

- [expresssion problem 简介 ](#expresssion problem 简介)
    - [矩阵](#矩阵)
- [OCaml](#OCaml)
    - [polymorphic variant](#polymorphic variant)
- [Java](#Java)
    - [Visitor Pattern](#Visitor Pattern)
    - [Object Algebras](#Object Algebras)
- [JavaScript](#JavaScript)
    - [visitor pattern](#visitor pattern)
- [参考资料](#参考资料)

> 密涅瓦的猫头鹰，只有在黄昏的时候才起飞
-- 黑格尔

> visitor，本质上是函数式编程语言里的含有“模式匹配pattern matching”的递归函数。
-- 王垠

> Java没有模式匹配，所以很多需要类似功能的人就得使用visitor pattern。为了所谓的“通用性”，他们往往把visitor pattern搞出多层继承关系，让你转几弯也搞不清楚到底哪个visitor才是干实事的。
-- 王垠

## expresssion problem 简介

> The Expression Problem is a new name for an old problem.  The goal is to define a datatype by cases, where one can add new cases to the datatype and new functions over the datatype, without recompiling existing code, and while retaining static type safety (e.g., no casts).  For the concrete example, we take expressions as the data type, begin with one case (constants) and one function (evaluators), then add one more construct (plus) and one more function (conversion to a string).
-- Philip Wadler

### 矩阵

## OCaml

### polymorphic variant

### 类型约束

## Java

### Visitor Pattern

#### 方法的本质

#### 优缺点

- 易于新增操作

- 访问者集中相关操作而分离无关操作

- 通过类层次进行访问

- 破坏封装

#### 实现的问题

- Double dispatch

- 谁负责遍历对象结构

#### 行为模式的思考

- 封装变化

- 对象作为参数

### Object Algebras

#### Algebras

## JavaScript

### visitor pattern

动态类型语言，无约束。call，apply随意修改this，调用其他对方的方法。

### `Array.prototype.slice.call`

slice方法的，只要有length属性就行。

``` js
let a  = Array.prototype.slice.call({a: 1, b: 2, c: 3, length: 3});
// [empty × 3]

let b  = Array.prototype.slice.call({0: 1, 1: 2, 2: 3, length: 3});
// [1, 2, 3]
```

习惯用法：

- `Array.prototype.slice.call(arguments, 1);`

- `Array.prototype.slice.call(document.childNodes);`

### 无类型约束的实现

### 类型约束的实现

## 反思

### 误导的技术文章

### 概念的本质

## 参考资料

### design patterns

- [编程的宗派](https://www.yinwang.org/blog-cn/2015/04/03/paradigms)

- [解密“设计模式”](https://www.yinwang.org/blog-cn/2013/03/07/design-patterns)

- [OCaml: Match expression inside another one?](https://stackoverflow.com/questions/257605/ocaml-match-expression-inside-another-one)

### Visitor Pattern and Finally Tagless

- [完全放弃ADT和record，拥抱polymorphic variant和row是否可行？](https://www.zhihu.com/question/310754155)

- [OOP vs FP：用 Visitor 模式克服 OOP 的局限](http://mxm.ink/post/2018-07-31-oop-vs-fp/)

- [Visitor Pattern 与 Finally Tagless：解决表达式问题](https://ice1000.org/2019/01/01/FinallyTaglessVisitorPattern/)

- [使用 Object Algebra 改善解释器代码设计](https://zjuwyd.com/2018/10/03/ObjectAlgebra/)

- [Visitor Pattern](https://zhuanlan.zhihu.com/p/35987864)


### expression problem

- [Expression problem wiki](https://en.wikipedia.org/wiki/Expression_problem)

- [Expression Problem的现状如何？](https://www.zhihu.com/question/314310650)

- [Greenspunning Predicate and Multiple Dispatch in JavaScript](http://raganwald.com/2014/06/23/multiple-dispatch.html)

- [Solving the Expression Problem in Javascript](https://blog.jayway.com/2013/06/21/15201/)

- [单分派、双分派及两种设计模式 Java](https://juejin.im/post/5d79fabb6fb9a06b1777e2fd)

- [The Expression Problem and its solutions C++](https://eli.thegreenplace.net/2016/the-expression-problem-and-its-solutions/)

- [Extensibility for the Masses Practical Extensibility with Object Algebras](https://www.cs.utexas.edu/~wcook/Drafts/2012/ecoop2012.pdf)

- [The expression problem as a litmus test](http://ane.github.io/2016/01/08/the-expression-problem-as-a-litmus-test.html)

- [expression_problem_1.ml](https://github.com/rizo/lambda-lab/blob/master/expression-problem/ocaml/expression_problem_1.ml)

- [Expression problem](https://en.wikipedia.org/wiki/Expression_problem)

- [Extending an existing type in OCaml](https://stackoverflow.com/questions/1746743/extending-an-existing-type-in-ocaml)

- [Expression problem Code](http://caml.inria.fr/cgi-bin/viewvc.cgi/ocaml/trunk/testlabl/mixin.ml?diff_format=c&view=markup&pathrev=10238)

## change log

- 2019/9/20 created doc

- 2019/9/22 补充参考资料

- 2019/9/30 完成OCaml版本的Finally Tagless的版本理解，可以开始写OCaml部分了

- 2019/10/11 完成OCaml的expression problem例子，补充参考资料

- 2019/10/12 完成正确的OCaml的expression problem的实现，直接参考别人的博客写代码，被坑了半个月。也是由于我对OCaml不熟悉，加上心急，被这个博客的作者气死了，瞎写代码。

- 2019/10/20 合并visitor模式文档

## 附录

### 完整代码

### OCaml Expression Problem

``` OCaml
type exp =
  Int of int
| Negate of exp
| Add of exp * exp

let rec eval  = function
  | Int i -> i
  | Negate e ->  -(eval e)
  | Add(e1, e2) -> (eval e1 ) + (eval e2)

let rec toString = function
  | Int i -> string_of_int i
  | Negate e -> "-(" ^ (toString e) ^ ")"
  | Add(e1, e2)  -> "(" ^ (toString e1) ^ "+" ^ (toString e2) ^ ")"

;;


let res = toString (Add ((Negate (Int 5)), (Int 6)));;
let num = eval (Add ((Negate (Int 5)), (Int 6)));;
print_endline res;;
print_endline (string_of_int num);;
```

### OCaml polymorphic variant

``` OCaml

exception BadResult of string

type exp =
  [`Int of int
  | `Negate of exp
  | `Add of exp * exp]

let rec eval  = function
  | `Int i -> i
  | `Negate e ->  -(eval e)
  | `Add(e1, e2) -> (eval e1 ) + (eval e2)

let rec toString = function
  | `Int i -> string_of_int i
  | `Negate e -> "-(" ^ (toString e) ^ ")"
  | `Add(e1, e2)  -> "(" ^ (toString e1) ^ "+" ^ (toString e2) ^ ")"

type new_exp = [ exp | `Sub of new_exp * new_exp]

let rec new_eval : new_exp -> int = function
  | #exp as exp -> eval exp
  | `Sub(e1, e2) -> (new_eval e1) - (new_eval e2)

let rec new_toString : new_exp -> string = function
  | `Sub(e1, e2) -> "(" ^ (new_toString e1) ^ "-" ^ (new_toString e2) ^ ")"
  | #exp as exp -> toString exp

;;

let a = `Int 10
let b = `Int 6
let c = `Sub(a, b)
let d = new_eval c
;;
print_endline (string_of_int d);;

let res = toString (`Add ((`Negate (`Int 5)), (`Int 6)));;
let num = eval (`Add ((`Negate (`Int 5)), (`Int 6)));;
print_endline res;;
print_endline (string_of_int num);;

```

### Java Visitor pattern

``` Java

package siegel.visitor;

public class VisitorPattern {
    public static void main(String[] args) {
        System.out.println("nice!");
        Exp exp1 = new Add(new Literal(1), new Literal(2));
        int res = exp1.accept(new ExpEvalVisitor());
        String show = exp1.accept(new ExpShowVisitor());
        System.out.println("eval reslut:" + res);
        System.out.println("show reslut:" + show);


        Exp exp2 = new Add(new Literal(2), new Literal(2));
        Exp2 exp3 = new Divide(exp1, exp2);
        int res4 = exp3.accept(new ExpEvalVisitor2());
        System.out.println("divide eval reslut:" + res4);
    }
}


interface Exp {
    <T> T accept(ExpVisitor<T> visitor);
}

interface ExpVisitor<T> {
    public T forLiteral(int v);
    public T forAdd(Exp a, Exp b);
}


class Literal implements Exp {
    public final int val;

    public Literal(int val) {
        this.val = val;
    }

    public <T> T accept(ExpVisitor<T> visitor) {
        return visitor.forLiteral(val);
    }
}

class Add implements Exp {
    public final Exp a;
    public final Exp b;

    public Add(Exp a, Exp b) {
        this.a = a;
        this.b = b;
    }

    public <T> T accept(ExpVisitor<T> visitor) {
        return visitor.forAdd(a, b);
    }
}

class ExpEvalVisitor implements ExpVisitor<Integer> {
    @Override
    public Integer forLiteral(int v) {
        return v;
    }

    @Override
    public Integer forAdd(Exp a, Exp b) {
        return a.accept(this) + b.accept(this);
    }
}

class ExpShowVisitor implements ExpVisitor<String> {
    @Override
    public String forLiteral(int v) {
        return v + "";
    }

    @Override
    public String forAdd(Exp a, Exp b) {
        return "(" + a.accept(this) + "+" + b.accept(this) + ")";
    }
}

interface ExpVisitor2<T> extends ExpVisitor<T> {
    public T forDivide(Exp a, Exp b);
}

class ExpEvalVisitor2 extends ExpEvalVisitor implements ExpVisitor2<Integer> {
    @Override
    public Integer forDivide(Exp a, Exp b) {
        return a.accept(this)  / b.accept(this);
    }
}

abstract class Exp2 {
    public abstract <T> T accept(ExpVisitor2<T> visitor);
}

final class Divide extends Exp2 {
    public final Exp a;
    public final Exp b;

    public Divide(Exp a, Exp b) {
        this.a = a;
        this.b = b;
    }

    public <T> T accept(ExpVisitor2<T> visitor) {
        return visitor.forDivide(a, b);
    }
}
```

### Java object Algebras

``` java

package siegel.objectAlgebras;

public class ObjectAlgebras {
    public static void main(String[] args) {
        System.out.println("nice!");
        Eval e = new Eval();
        int res = e.add(e.literal(1), e.literal(2));
        System.out.println("result: " + res);

        Eval2 e2 = new Eval2();
        int res2 = e2.divide(e2.literal(4), e2.literal(2));
        System.out.println("2 result: " + res2);
    }
}


interface Exp<T> {
    public T literal(int v);
    public T add(T a, T b);
}


class Eval implements Exp<Integer> {
    @Override
    public Integer literal(int v) {
        return v;
    }

    @Override
    public Integer add(Integer a, Integer b) {
        return a + b;
    }
}

class Show implements Exp<String> {
    @Override
    public String literal(int v) {
        return v + "";
    }

    @Override
    public String add(String a, String b) {
        return "(" + a + "+" + b + ")";
    }
}

interface Exp2<T> extends Exp<T> {
    public T divide(T a, T b);
}

class Eval2 extends Eval implements Exp2<Integer> {
    @Override
    public Integer divide(Integer a, Integer b) {
        return a / b;
    }
}

```
