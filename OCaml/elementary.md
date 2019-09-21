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

## change log

- 2019/9/21 created doc
