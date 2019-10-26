# React v16.7 Hooks

#### 2019/4/7

更多理论上的讨论见Lisp中Monad中的React Hooks条目。

## Hooks定义

Hooks是函数组件一类特殊函数（通常以use开头，如useState），使得可以在function component中依旧使用state和life-cycles，以及使用custom hook复用业务逻辑

### 抽象理解

- `useState(State Monad)`
- `useEffect(_->Algebraic Effect)` 注入Algebraic Effect。

Algebraic Effect简单来说是generator without yield。直观理解，如果render函数是一个generator，可以适当的时候yield出执行权(useState)，让框架做点事情(如记录state到VDOM)，然后框架再把render需要的数据返回到yield处(如上次的state和setState函数)


## 原则

有状态的组件没有渲染，有渲染的组件没有状态

## Hooks分类

- State hooks(state)
- Effect hooks(生命周期，side effect)
- Custom hooks(自定义hooks，复用组件逻辑)

## 典型用法

### useReducer, useState, useEffect, Custom

1. 官方例子：


``` JavaScript

import React, { useReducer, useState } from 'react';

const initialState = {count: 0};

function reducer(state, action) {
  switch (action.type) {
    case 'increment':
      return {count: state.count + 1};
    case 'decrement':
      return {count: state.count - 1};
    default:
      throw new Error();
  }
}

// useReducer, useState
function Counter({initialState}) {
  const [state, dispatch] = useReducer(reducer, initialState);
  return (
    <>
      Count: {state.count}
      <button onClick={() => dispatch({type: 'increment'})}>+</button>
      <button onClick={() => dispatch({type: 'decrement'})}>-</button>
    </>
  );
}

```

问题：`state`和`useReducer`绑定了，无法和其他组件共享数据。

改进：`React.createContext()`和`useReducer`一起使用。

`React.createContext()`是一种生产者和消费者模式，在顶层组件使用`Context.Provider`生产或修改数据，子组件使用`Context.Consumer`消费数据。

我们可以在顶层组件绑定`state`和`useReducer`，返回状态`state`和`dispatch`方法给`Context.Provider`。

``` JavaScript
const CountContext = React.createContext();
const CountContextProvider = (props) {
    const [state, dispatch] = useReduer(reducer, { count: 0 });
    return (
        <CountContext.Provier value={{state, dispatch}}>
            {props.children}
        </CountContext.Provier>
    )
}

```

改进版本的问题：数据量大，组件很多，会导致渲染性能下降。每次`state`改变，都会从顶部传递下去，性能影响很大。

进一步改进办法：使用`memo`或者`useMemo()`；或拆分粒度更细的`context`，不同的数据模块，包装不同的`ContextProvider`；或者使用`Hooks`特性（不允许条件分支，循环嵌套）。

2. 异步

``` JavaScript

import React, { useEffect, useReducer, useState } from 'react';

/*
* 容器组件
*/
function SmartTestAPIUrlInput(props) {
    const { data, doFetch, isError } = useAsyncData(value, {});

    const [value, setValue] = useState(props.value);
    const changeHandler = (value) => {
        setValue(value);
        doFetch(value);
    };

    return DumbTestAPIUrlInput({value, data, changeHandler, isError });
}

function DumbTestAPIUrlInput(props) {
    const {
        value,
        data,
        changeHandler,
        isError
    } = props;

    return (
        <div className={cls}>
            <Input
                value={value}
                onChange={changeHandler}
            />
            <ul className="list">
                {!isError && data.map(item => {
                    return <li>{item.text}</li>
                })}
            </ul>
        </div>
    );
}

/*
* reducer
*/
const dataFetchReducer = (state, action) => {
    switch (action.type) {
        case 'FETCH_INIT':
            return {
                ...state,
                isLoading: true,
                isError: false
            };
        case 'FETCH_SUCCESS':
            return {
                ...state,
                isLoading: false,
                isError: false,
                data: action.data,
            };
        case 'FETCH_FAILURE':
            return {
                ...state,
                isLoading: false,
                isError: true,
            };
        default:
            throw new Error('异步请求失败');
    }
};

/**
 * 异步请求
 * useReducer, useState, useEffect, Custom
 */
export function useAsyncData(value, initData) {
    const [param, setParam] = useState(value);
    const [state, dispatch] = useReducer(dataFetchReducer, {
        isLoading: false,
        isError: false,
        data: initData,
    });

    useEffect(_ => {
        const fetchData = _  => {
            dispatch({type: 'FETCH_INIT'});
            fetch({param})
                .then((response) => {
                    dispatch({
                        type: 'FETCH_SUCCESS',
                        data: {status: response.status, ...response.data}
                    });
                })
                .catch((error) => {
                    dispatch({type: 'FETCH_FAILURE'});
                    throw error;
                });
        };

        param && fetchData();
    }, [param]);

    const doFetch = param => {
        setUrl(param);
    };
    return {...state, doFetch};
}

```

## 资料

- [对React Hooks的一些思考](https://zhuanlan.zhihu.com/p/48264713)

- [React Hooks - useState的简单工作原理](http://tech.colla.me/zh/show/react_hook_useState)

## change log

- 2019/4/7 修订，备注Hooks资料在Lisp的Monad中
- 2019/4/10 修订，补充实战方面的资料
- 2019/10/11 凌晨3点修改，新增useState资料
- 2019/4/29 补充useReducer, useState, useEffect, Custom的例子
