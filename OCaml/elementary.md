# OCaml初步

## install

### core

`opam install core`

## build

文件以`md`作为后缀。我们新建`sum.ml`文件。用corebuild来编译，生成`sum.native`可执行文件。

`corebuild sum.native`

运行`sum.native`

``` bash
./sum.native
```

以`Ctrl-D`来结束输入。

注：corebuild是随Core安装的，建立在ocamlbuild之上的小包装器，作用是传入使用Core构建程序所需的标志。

#### Core and utop

``` bash
#require "core";;
open Core;;
```

在utop中使用Core，不能直接用`open Core.std;;`引入，会报错。要先`#require "core";;`

## 参考资料

- [99 Problems (solved) in OCaml](https://ocaml.org/learn/tutorials/99problems.html)

## 学习过程中遇到的问题

### How to read/understand this part: `type a . a term -> a`?

 `a .` apparently means ∀a

 - [How to read/understand function signature with GADT?](https://discuss.ocaml.org/t/how-to-read-understand-function-signature-with-gadt/2250)


### Extending an existing type in OCaml

- [Reuse and extend the defined type in Ocaml](https://stackoverflow.com/questions/6881652/reuse-and-extend-the-defined-type-in-ocaml)

- [What is the “right” way to add constraints on a type, to handle recursive structures with variants and to combine fragments of types?](https://discuss.ocaml.org/t/what-is-the-right-way-to-add-constraints-on-a-type-to-handle-recursive-structures-with-variants-and-to-combine-fragments-of-types/2810)

- [Extending an existing type in OCaml](https://stackoverflow.com/questions/1746743/extending-an-existing-type-in-ocaml)

- [Defining a type for lambda expressions in Ocaml](https://stackoverflow.com/questions/7369615/defining-a-type-for-lambda-expressions-in-ocaml)

### GADT

- [Detecting use-cases for GADTs in OCaml](https://mads-hartmann.com/ocaml/2015/01/05/gadt-ocaml.html)

- [什么是GADT？它有什么作用？](https://www.zhihu.com/question/67043774)

- [Generalized algebraic datatypes](https://caml.inria.fr/pub/docs/manual-ocaml/manual033.html)

- [GADTs: Wizardry for a Typesafe Age](https://dttw.tech/posts/SkHN2ZlEG)

 - [An concrete simple example to demonstrate GADT in OCaml?](https://stackoverflow.com/questions/27864200/an-concrete-simple-example-to-demonstrate-gadt-in-ocaml)



## change log

- 2019/9/21 created doc
