# MVC

- [核心](#核心)
- [MVC概念](#MVC概念)
- [相关的设计模式](#相关的设计模式)
  - [Observer模式](#Observer模式)
  - [Composite模式](#Composite模式)
  - [Strategy模式](#Strategy模式)
  - [Factory Metchod](#Factory Metchod)
  - [Decorator模式](#Decorator模式)
- [在用React开发时的相关模式](#在用React开发时的相关模式)
  - [哑组件概念与View的复用以及Composite](#哑组件概念与View的复用以及Composite)
  - [React的事件系统的设计](#React的事件系统的设计)
  - [Decorator模式与高阶组件](#Decorator模式与高阶组件)
  - [VM与Observer模式](#VM与Observer模式)
- [延伸](#延伸)
  - [multi-method与Visitor](#multi-method与Visitor)
- [参考资料](#参考资料)

## 核心

> 设计面向对象软件比较困难，而设计可复用的面向对象软件就更加困难。

关键是复用。

> 程序设计语言的选择非常重要，他将影响人们理解问题的出发点。我们的设计模式采用了Smalltalk和C++层的语言特性，这个选择设计上决定了那些机制可以方便的实现，而那些则不能。若我们采用过程式语言，可能就要包括诸如“继承”，‘封装’和“多态”的设计模式。

## MVC概念

> Model是应用对象，View是Model在屏幕上的表示，Controller是定义用户界面对用户输入的响应方式。

> 不使用MVC，用户界面设计往往将这些对象混在一起，而MVC则将他们分离以提高灵活性和复用性。

> MVC通过建立一个“订购/通知”协议来分离V和M(Observer模式)。

“订购/通知”协议保证V正确的反映M的状态。M一旦变化，V将相应刷新。由于“订购/通知”协议这层抽象的存在，使得我们可以为一个M提供不同的V，也可以为一个M创建新的V，而无需重写M。

> MVC的另一个特征是视图可以嵌套（Composite模式）。

我觉得，这里应该提一下V应该是可以复用的。V已经与M没有强关联了，那么V就可以用其他其他M上。

> MVC允许你在不改变视图外观的情况下改变视图对用户输入的响应方式。

> V使用Controller子类的实例来实现一个特定的响应策略。要实现不同的响应策略只要用不同的种类的C实例替换即可。

> V-C关系是Strategy模式的一个例子。

## 相关的设计模式

### Observer模式

M和V的分离的设计，需要实现M的改变，能够影响V，而M并不需要了解V的细节。如果是分离对象，使得一个对象的改变能影响另一个对象，这个对方不需要知道哪些被影响的对象的细节。

### Composite模式

组合视图和其构件平等对待。将一些对象划分为一组，并将该组对象当做一个对象来使用。

### Strategy模式

### Factory Metchod

指定视图缺省控制器

### Decorator模式

增加视图滚动。

## 在用React开发时的相关模式

### 哑组件概念与View的复用以及Composite

### React的事件系统的设计

### Decorator模式与高阶组件

### VM与Observer模式


## 延伸

### multi-method与Visitor

CLOS支持多方法(multi-method)的概念，这就减少了Visitor模式的必要性

## 参考资料

- [wiki MVC](https://zh.wikipedia.org/wiki/MVC)

- [Scaling Isomorphic Javascript Code](https://blog.nodejitsu.com/scaling-isomorphic-javascript-code/)

- [Understanding MVC And MVP (For JavaScript And Backbone Developers)](https://addyosmani.com/blog/understanding-mvc-and-mvp-for-javascript-and-backbone-developers/)

- 《Design Patterns -- elements of reusable Object-Oriented Software》

## change log

- 2019/9/17 created doc
- 2019/9/18 读四人帮的设计模式，并总结
