# A Little Java, A Few Patterns

- [type](#type)
    - [Advice](#Advice)
- [参考资料](#参考资料)

## type

> A type is a name for collection of values

abstract 定义类型

class 定义子类型

extends 将以上两者联系起来

## Advice

### Advice 1

> When specifying a collection of data, use abstract classes for datatypes and extends classes for variants.

### Advice 2

> When writing a function over a datatype, place a method in each of the variants that make up the datatype. If a field of a variant belongs to the same datatype, the method may call the corresponding method of the field in computing the function.

涉及里氏替换原则(Liskov Substitution principle)。子类对象可以在程序中替代超类。即datatype的可替换性。

### Advice 3

> When writing a function that returns values of a datatype, use new to create these values.

函数式编程的原则，减少副作用(Side Effect)。同时，可以用返回的新对象实现链式调用，增强OO函数的可组合性。函数参数是datatype(抽象的)，返回值也是datatype，这样可以自由组合，增加灵活性。

### Advice 4

> When writing several functions for the same self-referential datatype, use visitor protocols so that all methods for a function can be found in a single class.

用class去封装行为，而不只是封装数据（如：状态模式，命令模式，策略模式），有利于功能的内聚。类型是可以参数化的，方法抽象成类之后，可以拥有更强大的可组合性。

### Advice 5

书中无Advice 5.

### Advice 6

> When the additional consumed value change for a self-referential use of a visitor, don't forget to create a new visitor.

### Advice 7

> When designing visitor protocols for many different types, create a unifying protocol using Object.

### Advice 8

> When extending a class, use overriding to enchrich its functionality.

拓展一个类的时候，使用overriding的方式来增强其功能。即：利用OO的多态实现功能的拓展。visitor类，像一个高度抽象化的函数，在FP中，函数是可以自由组合的。

### Advice 9

> If a datatype many have to be extended, be forward looking and use a constructor-like (overridable) method so that visitors can be extended, too.

### Advice 10

> When modifications to objects are needed, use a class to insulate the operations that modify objects. Otherwise, beware the consequences of your actions.

当必须要对一个对象修改的时候，不要每次直接在对象的类型上添加一个方法和若干数据成员来解决。可以考虑添加一个visitor class来解决。visitor可拓展性更强。如果直接添加方法可以解决问题，后续变化，不需要频繁修改该方法，就无需引入visitor。

通过多态，把原本属于类的方法，拆分为一组带有类型结构信息的visitor。修改代码，只需要编写新的class，和胶水代码。

## 参考资料

- [A Little Java, A Few Patterns](A Little Java, a Few Patterns [Felleisen & Friedman 1997-12-19].pdf)

- [《A Little Java, A Few Patterns》笔记](https://a-little-java-a-few-patterns.readthedocs.io/zh_CN/latest/foreword.html)

- [子龙山人《a little java a few patterns》读书笔记](https://zilongshanren.com/post/a-little-java-a-few-patterns-book-review/)

## change log

- 2019/10/13 created doc
