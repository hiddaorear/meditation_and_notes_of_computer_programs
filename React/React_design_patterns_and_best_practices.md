# React Design Patterns and Best Practices

## JSX的抽象能力

JSX顾名思义，是JavaScript和XML的结合。XML描述UI的结构，JavaScript操作UI。二者混在一起的时候，JS可能有描述UI的能力。二者在React中结合运用的例子：函数子组件。

### 函数子组件:renderProps?

``` javascript

const FunctionAsChild = ({ children, url }) => {
    console.log(url);
    return children('World');
};

FunctionAsChild.propTypes = {
    children: PropTypes.func.isRequired,
    url: PropTypes.string.isRequired,
};

<FunctionAsChild
    url='http://www.yinwang.org'
>
    {(param, url) => <div>Hello, {param}! and {url}</div>}
</FunctionAsChild>

```

FunctionAsChild与dumb最大的区别在于，返回了children，且children是一个函数。FunctionAsChild本身是一个函数，可以通过函数参数访问属性url和特殊的props属性children，即函数也具有和JSX组件类似的能力。而返回的children函数，作为JSX一个表达式执行。可以看出，函数在JSX中，具有的JSX类似的描述UI的功能。当然，函数不具备生命周期，也就无法利用shouldComponentUpdate来优化性能。

优点：
1. 函数子组件封装的组件，传递给组件的是变量，而非固定属性。
``` js
<Fetch url="test">
    {data => <List data={data} />}
</Fetch>
```
2. 不要求children函数使用预定义的名称。


### 高阶组件

``` js
const HoC = Component => EnchencedComponent;
```

高阶组件其实是函数，接受组件作为参数，对组件增强之后返回。

例如，给组件添加className porp的高阶组件，注意命名习惯，以with开头：

```js

const withClassName = Component => props => (
    <Component {...props} className="my-class" />
);

const MyComponent = ({ className }) => (
    <div className={className}>
)

MyComponent.propType = {
    className: PropTypes.string,
};

const MyCompontentWithClassName = withClassName(MyComponent);

```

高阶组件可以进一步，使用函数的能力，如：柯里化。

### Hooks

React函数式编程化。

#### Capture Value

值不可变特性。

#### useEffect

怎么处理副作用。

#### Redux and useReducer

局部状态管理。

#### example

经典使用例子。

#### 实现原理(Array)

 不要在循环，条件判断，嵌套函数里面调用Hooks，其原因是什么？


## 组件抽象

### dumb Component & smart Component

容器组件和表现组件。

容器组件sarmt Component是普通的JSX组件，有完整的生命周期，主要用于数据流处理和状态管理。表现组件dumb Component，主要用于数据展示，不含数据获取逻辑，无状态。

### 函数的使用

- 通用的事件处理器，避免表单等组件每种类型写一个对应的函数。
``` js
handEvent(event) {
    swith (event.type) {
        case 'click':
            console.log('child');
            break;
        case 'dbclick':
            console.log('dbclick');
            break;
        default:
            console.log('unhandled');
    }
}

```

- 不宜在render中使用绑定函数，每次渲染重新绑定触发函数。
``` js

// 不推荐
class Button extent React.Component {
    handleClick() {
        console.log(this);
    }
    render() {
        return <button onClick={() => this.handleClick()} />
    }
}

class RightButton extent React.Component {
    handleClick = () => {
        console.log(this);
    }
    render() {
        return <button onClick={handleClick} />
    }
}

```


### DOM抽象

- ref
- on开头的属性，表示在向React描述期望达成的行为，不会向底层DOM节点添加真正的事件处理器。React在根节点上添加了单个的事件处理器，利用事件冒泡，做事件代理，可以优化性能。
- 不宜在DOM上展开props对象。`<div {...props}/>`

## 数据流抽象

### props

#### 不宜用props初始化状态

- 违背了单一数据源原则；
后果：导致本组件的state作为一个数据源，以及上层的props也是一个数据源。在有些情况下，需要同步这两者，带来额外的复杂度。且同步数据到props，会引起子组件再次渲染，此时state的状态要不容易破坏，需要小心处理，接受新的props值，同步不会导致组件无限刷新渲染。
- 传递给state的props如果变化了，在没有在其他生命周期里处理的情况下，state的状态不会同步更新；
此时，要处理这个情况，一般会用getDerivedStateFromProps（旧版本componentWillReceiveProps）生命周期，来处理props新的值，为了避免接受props之后带来额外渲染，需要针对props中所有需要更新props属性，做对比。导致组件额外依赖props的处理。如果后续组件修改，涉及上层props更新，需要在此生命周期中添加对应的props处理，否则会不能获取新的props数据。

如果要有些props就是来初始化的，可以用特殊的命名，如initialValue之类。

不用props初始化状态，就产生了另一个问题：props的值，在子组件可能需要被修改。怎么处理？上层组件写好onChange函数，并传递给子组件。
这样处理下来，就接近我们的表现组件和容器组件的设计模式了。这种场景，就可以这样分离抽象之。


### state

### context

### 数据流库

- Redux
- Mobx

## 不推荐的实践

[You Probably Don't Need Derived State](https://reactjs.org/blog/2018/06/07/you-probably-dont-need-derived-state.html)

[[译] 你可能不需要 Derived State](https://zhuanlan.zhihu.com/p/38090110)

## 工程工具

## storybook

[storybook](https://github.com/storybooks/storybook)

无需运行整个应用，渲染单个组件，便于开发和测试。

## react-docgen

prop类型定义，自动生成组件的文档。

## PureComponent
性能优化。浅检查组件的props和state，嵌套对象和数组不会被比较。

### react-addons-perf
chrome-react-perf拓展。
监控性能。

### why-did-you-update
找出不需要渲染的组件。

### 单元测试

- Jest
- Enzyme

## 资料

### todolist

- [React Hooks issue - by Sebastian Markbåge ](https://github.com/reactjs/rfcs/pull/68#issuecomment-439314884)
- [React 作者关于 Hooks 的深度 issue，值得你阅读](https://zhuanlan.zhihu.com/p/53375744)

- [为什么顺序调用对 React Hooks 很重要？](https://overreacted.io/zh-hans/why-do-hooks-rely-on-call-order/)

- [Hooks FAQ](https://reactjs.org/docs/hooks-faq.html#how-do-lifecycle-methods-correspond-to-hooks)

- [React16 新特性](https://github.com/dt-fe/weekly/blob/master/83.%E7%B2%BE%E8%AF%BB%E3%80%8AReact16%20%E6%96%B0%E7%89%B9%E6%80%A7%E3%80%8B.md)

- [精读《怎么用 React Hooks 造轮子》](https://github.com/dt-fe/weekly/blob/master/80.%E7%B2%BE%E8%AF%BB%E3%80%8A%E6%80%8E%E4%B9%88%E7%94%A8%20React%20Hooks%20%E9%80%A0%E8%BD%AE%E5%AD%90%E3%80%8B.md)
- [阅读源码后，来讲讲React Hooks是怎么实现的](https://juejin.im/post/5bdfc1c4e51d4539f4178e1f)

- [react hooks进阶与原理](https://zhuanlan.zhihu.com/p/51356920)
- [深入 React Hook 系统的原理](https://www.jishuwen.com/d/2PLO#tuit)



### done

- React总结，来源于Michele Bertoli著的《React设计模式于最佳实践》

- [精读《React Hooks》](https://github.com/dt-fe/weekly/blob/master/79.%E7%B2%BE%E8%AF%BB%E3%80%8AReact%20Hooks%E3%80%8B.md)
- [A Complete Guide to useEffect](https://overreacted.io/a-complete-guide-to-useeffect/)
- [精读《useEffect 完全指南》](https://github.com/dt-fe/weekly/blob/master/96.%E7%B2%BE%E8%AF%BB%E3%80%8AuseEffect%20%E5%AE%8C%E5%85%A8%E6%8C%87%E5%8D%97%E3%80%8B.md)
- [精读《Function VS Class 组件](https://github.com/dt-fe/weekly/blob/master/95.%E7%B2%BE%E8%AF%BB%E3%80%8AFunction%20VS%20Class%20%E7%BB%84%E4%BB%B6%E3%80%8B.md)

## React博客和资料

- [overreacted - by Dan Abramov](https://overreacted.io/)
- [进击的React](https://zhuanlan.zhihu.com/advancing-react)
