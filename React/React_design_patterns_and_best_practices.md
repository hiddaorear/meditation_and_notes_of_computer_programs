# React Design Patterns and Best Practices

## 关于编程的思考

React是我使用时间最长，具有高级抽象能力的前端组件。在学习和使用过程中，技巧繁多，对项目反思，以及重构的冲动，都会归于对复杂度的控制上。这个让我想起了SICP。摘录这本书中一些话。

> 我认为，在计算机科学中保持计算中的趣味性是特别重要的事情。我认为，我们的责任是去拓展这一领域，将其发展到新的方向，并在自己家里保持趣味性。我希望，我们不要变成传道士，不要认为你是兜售圣经的人。你所掌握的，也是我认为并希望的，也就是智慧：那种看到这一机器比你第一次站在他面前能做得更多的能力。这样你才能将他向前推进。
Alan J. Perlis

> 一个计算机语言并不仅仅是让计算机执行操作的一种方式，更重要的是，他是一种表述有关方法学的思想的新颖的形式化媒介。因此，程序必须写得能供人们阅读，
偶尔地去供计算机执行。其次，我们相信，在这一层次的课程里，最基本的材料并不是特定计算机设计语言的语法，不是高效计算某种功能的巧妙算法，也不是算法的数学分析或计算的本质基础，而是一些能够控制大型软件系统的智力复杂性的技术。

> 掌握了控制大型系统中的复杂性的主要技术。应该知道，在什么时候那些东西不需要去读，那些东西不需要去理解。

> (有关Lisp)，可以做过程抽象和数据抽象，可以通过高阶函数抓住公共的使用模式，可以用赋值和数据操作去模拟局部状态，可以利用流和延时求值连接起一个程序的各个部分。

> 当我们描述一个语言的时，需要将注意力放在这一语言所提供的，能够将简单的认识组合起来形成更复杂认识的方法方面。每一种强有力的语言都为此提供了三种机制：
> - 基本表达形式。最简单个体
> - 组合的方法。简单个体构造复合元素
> - 抽象的方法。通过这个抽象的方法，为复合对象命名，并将它当做单元去操作

## JSX的抽象能力

JSX顾名思义，是JavaScript和XML的结合。XML描述UI的结构，JavaScript操作UI。二者混在一起的时候，JS可能有描述UI的能力。二者在React中结合运用的例子：函数子组件。

### 函数子组件

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

React总结，来源于Michele Bertoli著的《React设计模式于最佳实践》
