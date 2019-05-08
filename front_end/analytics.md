# analytics

## 关键指标

### 用户唯一标识

保证有用户登录态，可以使用用户信息。无，则需要考虑生成唯一token，存储在cookie中，设置较长的过期时间。cookie的缺点，可以被清除。

网站统计多数是要基于用户的数据，所以第一步，要识别用户。

### PV(Page View)

- 定义：一天之内，页面被所有用户访问总次数。 每一次刷新会增加一次PV
- 用途：统计关键页面或临时推广性页面的PV，考察访问量或推广效果； 作为单页面统计参数
- 缺点：PV统计不做限制，可以人为的刷新页面提升数据，单纯看着PV无法反应页面被用户访问的具体情况

### UV(Unique Visitor)

- 定义： 一天之内，不同的用户个数；同一个页面，同一天，同一个用户访问多次，只能算一次
- 用途：最有价值指标，反应页面的访问用户数；作为单页面统计参数

#### 技术实现:

- 很多站点根据访问目标页面的IP数来统计UV。缺点：办公区或校园局域网，多个用户访问的IP是同一个

- 根据Cookie和IP统计，打开页面写入唯一的Cookie，结合IP一起上报。缺点：Cookie可能被清除，页面重新访问算第二次

- 结合浏览器的userAgent和IP统计。缺点：userAgent可能相同

### VV(Visit View)

- 定义：用户从进入网站到离开，整个过程只算一次；针对整个网站的统计指标


## 前端技术指标

### 白屏时间(first paint time)

- 定义： 打开页面到页面开始有东西渲染。 白屏时间 = 浏览器渲染出第一个元素 - 页面访问时间点；
- 标准： 百度(263ms)

first paint time没有写入标准的原因：[first paint time](https://github.com/w3c/navigation-timing/issues/21)。主要原因，白屏时间标准，定义很模糊。如果以画出第一个像素作为时间，那么遇到本来就是空白的页面怎么处理？

#### 传统技术实现

分析视图(WebPagetest)，白屏时间出现在**头部外链资源加载完附近**，原因在于浏览器加载并解析头部资源，才渲染页面，不必到CSS树和DOM树的解析，而是马上显示中间结果。根据这个观察的经验，得出经验意义上的测量的技术实现，并不精确。

这样，如果知道了渲染首字节的时间，和头部资源加载的时间，我们两者相减，就可以得出白屏时间。由于JS需要等待在其之前JS和CSS加载完，才执行，也就是JS的执行是有顺序的，因此，我们可以在head中所有资源加载之前打点，得到开始加载的时间点，在head最后打点，得到加载完成的时间点。

``` html

<!DOCTYPE HTML>
<html>
    <head>
        <meta charset="UTF-8"/>
        <script>
          var start_time = +new Date; //测试时间起点，实际统计起点为 DNS 查询
         // 更精确的实现，服务器在此处给出时间戳。或，performance.timing.navigationStart
        </script>
        <script src="script.js"></script>
        <script>
          var end_time = +new Date; //时间终点
          var headtime = end_time - start_time; //头部资源加载时间
          // 或者
          // var headtime = end_time - performance.timing.navigationStart
          console.log(headtime);
        </script>
    </head>
    <body>
        <p>在头部资源加载完之前页面将是白屏</p>
    </body>
</html>

```

#### chrome技术实现(firstPaintTime)

navigationStart：当前浏览器窗口的前一个网页关闭，发生unload事件时的Unix毫秒时间戳。如果没有前一个网页，则**等于fetchStart属性**。

``` html

<!DOCTYPE HTML>
<html>
    <head>
        <meta charset="UTF-8"/>
        <script src="script.js"></script>
        <script>
            window.onload = function() {
                requestIdleFrame(function() {
                    let firstPaintTime = window.chrome.loadTimes().firstPaintTime * 1000 - window.performance.timing.navigationStart;
                    console.log(firstPaintTime);
                });
            }
        </script>
    </head>
    <body>
        <p>在头部资源加载完之前页面将是白屏</p>
    </body>
</html>



```


PC版网站抽样(单位ms)

|站点  | 白屏时间 |
| :------| :------: |
| 淘宝 | 138 |
|京东  | 292 |
| 头条(https://www.toutiao.com/) | 228 |
| 头条广告投放平台(https://ad.toutiao.com/promotion/) |221  |
| 腾讯课堂 | 1626 |

 PC推荐250ms内

### 首屏时间

- 定义： 首屏内所有内容渲染出来的时间。 首屏时间 = 浏览器首屏渲染完成 - 页面访问时间点
- 标准： 移动端，最长3s，推荐值为1.5s以内； PC端，最长1.5s，推荐值为1s以内
- 技术实现： 通常统计首屏内图片的加载时间（首屏内加载最慢的一张图片）

具体技术实现思路：`计算首屏大小 -> 找出其中图片 -> 绑定首屏图片的load事件 -> load触发之后判断是否在首屏内，并找出最慢的一张 -> 最慢的一张图片的加载时间，即首屏时间`

#### 注意

- 页面存在iframe的情况
- gif图片在IE上可能重复触发load事件
- CSS重要背景图需要通过JS请求图片url来统计
- 无图片，则统计文字出现时间
- 解析到某个元素，则首屏完成，可以在这个元素之后加入script计算时间

### 用户可操作时间

- 定义：默认可以认为是domready(即DOMContentLoaded)的时间。用户可以正常操作，如：点击，输入等
- 标准: 无

 PC版网站抽样(单位ms)

|站点  | 用户可操作时间 |
| :------| :------: |
| 淘宝 | 1013 |
|京东  | 1183  |
| 头条(https://www.toutiao.com/) | 1607 |
| 头条广告投放平台(https://ad.toutiao.com/promotion/) | 1690 |
| 腾讯课堂 | 2056 |

 PC推荐1500ms内

### 总下载时间

- 定义： 所有资源加载完成的时间，即页面onload时间
- 标准： 无

 PC版网站抽样(单位ms)

|站点  | 总下载时间 |
| :------| :------: |
| 淘宝 | 4092 |
|京东  | 2810  |
| 头条(https://www.toutiao.com/) | 1160 |
| 头条广告投放平台(https://ad.toutiao.com/promotion/) | 2285 |
| 腾讯课堂 | 4028 |

 PC推荐3000ms内(视具体情况而定，图片加载影响很大，如果网站图片较多，则放宽)

## Chorme标准

[Chrome 64 to deprecate the chrome.loadTimes() API](https://developers.google.com/web/updates/2017/12/chrome-loadtimes-deprecated#startloadtime)

### FP(First Paint)

首次绘制包括了任何用户自定义的背景绘制，它是首先将像素绘制到屏幕的时刻。(与白屏时间相关)


``` JavaScript

function firstPaintTime() {
  if (window.PerformancePaintTiming) {
    const fpEntry = performance.getEntriesByType('paint')[0];
    return (fpEntry.startTime + performance.timeOrigin) / 1000;
  }
}

```

### FCP(First Contentfull Paint)

首次内容绘制是浏览器将第一个 DOM 渲染到屏幕的时间。(与白屏时间相关)

`window.performance.getEntriesByType('paint')`

### DCL(DOMContentLoaded Event)

也叫DOM ready。

HTML文档完全加载和解析之后，DOMContentLoaded事件就被触发。无需等待CSS，image和iframe完成加载。注意：DOMContentLoaded事件必须等待其所属script之前的CSS加载完成才会触发(JS可能依赖他前面的CSS用于计算)。

UI渲染引擎和JS执行引擎是互斥的，JS引擎执行，则UI线程会被挂起。但JS加载与UI渲染不一定互斥。同步script的加载会导致DOM树构建的暂停。这种情况下，会对DOMContentLoaded造成影响。但带`async`和`defer`的外部脚本，浏览器不会等待其加载完成和执行。注意，这两个标识仅仅对外部脚本起作用。

`async`和`defer`的外部脚本，浏览器会在后台加载脚本(并行)，加载完成之后，`defer`等到页面加载解析完成之后才执行，在`DOMContentLoader`之前；而`async`脚本，则会导致文档停止解析(如果文档还没解析完成)，执行脚本，执行完之后，文档接着解析，可能会影响`DOMContentLoader`事件。

![async and defer](./async_and_defer.png)


|  | async | defer |
| :------| :------: | :------: |
| 顺序 | 在页面出现顺序，不影响执行顺序  | 依照页面出现顺序执行|
| DOMContentLoaded | 影响  |不影响|


``` JavaScript

document.addEventListener('DOMContentLoaded', function(){
    console.log('DOMContentLoaded');
});

```

### L(Onload Event)

在文档装载完成后会触发  load 事件。此时，在文档中的所有对象都在DOM中，所有图片，脚本，链接以及子框都完成了装载。

document.addEventListener('load', function(){
    console.log('load');
});



### PC版网站JS和CSS包大小(单位KB)

PC版网站抽样(单位KB)

|站点  | JS | CSS |
| :------| :------: |:------: |
| 淘宝 | 26.0  |0|
| 京东  | 20.5  |2.9|
| 头条(https://www.toutiao.com/) | 32.5  |32|
| 头条广告投放平台(https://ad.toutiao.com/promotion/) |36.8  |55.4|
| 腾讯课堂 |34.1  |35|


 可以得出结论：一般站点的JS包为300KB左右，CSS为40KB上下浮动（偏差较大，与优化手段有关）

### 用户对性能的感知

| 时长 | 感觉 |
| :------| :------: |
|0-100ms|即时|
|100-300ms| 轻微可觉察延迟|
|300-1000ms|断断续续|
|1000+ms|失去耐心|
|10000+ms|放弃|

## 上报的实现

### 朴素实现

为了避免ajax的不便之处，一般用`Image src`的方式上报。代码例子：

``` javascript
// 上报数据
// @param  {String} logType 上报日志的类型
// @param  {Object} data    上报的数据内容
function log(logType, data) {
    var queryArr = [];
    for(var key in data) {
      queryArr.push(encodeURIComponent(key) + '=' + encodeURIComponent(data[key]));
    }
    var queryString = queryArr.join('&');
    var uniqueId = "log_"+ (new Date()).getTime();
    var image = new Image(1,1);

    window[uniqueId] = image;   // use global pointer to prevent unexpected GC

    // 如果使用服务器的域名地址上报失败，则随机使用一个备用 IP 列表中的服务器进行上报
    image.onerror = function() {
      var ip = IP_LIST[Math.floor(Math.random() * IP_LIST.length)];
      image.src = window.location.protocol + '//' + ip + '/j.gif?act=' + logType + '&' + queryString;
      image.onerror = function() {
        window[uniqueId] = null;  // release global pointer
      };
    };

    image.onload = function() {
      window[uniqueId] = null; // release global pointer
    };

    image.src = REPORT_URL + '?act=' + logType + '&' + queryString;
}
```

以上基本实现存在的问题：调用之后立即执行上报逻辑，可能影响页面性能

### 使用requestIdleCallback改进

``` javascript

function idleCallback(params) {
    const { heavyWork, didTimeout=0, isDone, afterDone } = params;
    console.log( heavyWork, didTimeout, isDone, afterDone );
    if (isDone()) {
        afterDone && afterDone();
        return;
    }

    requestIdleCallback(function (deadline) {
        while ((deadline.timeRemaining() > 0 || deadline.didTimeout) && !isDone()) {
            heavyWork();
        }
        idleCallback(params);
    }, {didTimeout});
}

const REPORT_URL = 'https://github.com/';
const IP_LIST = ['127.0.0.1', '127.0.0.1'];

const work = {
    didTimeout: 1000,
    done: false,
    heavyWork: () => {
        this.done = true;
        console.log('work');
    },
    isDone: () => {
        return this.done;
    },
    afterDone: () => {
        console.log('done');
    }
};
idleCallback(work);

```

更多的改进，可以把上报的数据存储在Stroage中，批量上报。但有被清空的风险。

## 技术注意事项

### `image src`请求没有发出问题

错误代码：

``` javascript
function c(q) {
    var p=window.document.location.href,sQ='',sV='';
    for(v in q){
        switch (v){
            case "title":sV=encodeURIComponent(q[v].replace(/<[^<>]+>/g,""));break;
            case "url":sV=escape(q[v]);break;
            default:sV=q[v]
        }
        sQ+=v+"="+sV+"&";
    }
    new Image().src = "http://s.baidu.com/w.gif?q=meizz&"+sQ+"path="+p+"&cid=9&t="+ new Date().getTime();
    return true;
}
```

> 为什么要将新建的 Image 对象赋值给一个 window 对象下的属性呢？原因是在于浏览器的垃圾回收机制会积极地回收这个 Image 对象，且回收的时机很可能在 Image 根据 src 的值发起请求之前，这就导致了上报请求并没有发出。

>  new Image() 对象没有赋给任何变量，在这个函数执行结束时，浏览器的垃圾回收机制对这种“无主”的对象是毫不客气的回收的，而正是这种回收行为导致了这个HTTP请求（异步的）没有发出，从而造成了LOG数据的丢失。

> 因为一个大脚本的运行回产生大量的“垃圾”，浏览器垃圾回收也会相应地更频繁的启动，从而造成LOG数据丢失

## Codeless Tracking(无埋点技术)

Codeless Tracking俗称无埋点技术。相比在代码里手动硬编码埋点，无埋点技术不需要在业务代码中，修改代码以支持上报。没有侵入业务代码，是Codeless Tracking的优点，而无侵入，也导致了这种技术的弱点：

1. 很难结合业务逻辑处理上报。如表单提交成功，然后上报，Codeless Tracking不容易处理Ajax返回成功的情况；如需要计算的情况，两个input的数据，相加之后的结果上报；
2. 需要构造某种标识，用于标记上报的所属的视图；常见方案有：DOM选择器，在DOM树结构位置，点击的坐标；

### 标记

#### 标记的交互实现

一般把需要埋点的业务页面，嵌入数据统计的平台页面中。一般以iframe的形式。然后在业务页面中点击鼠标右键（避免和正常点击事件一样，造成a标签跳转），弹窗，填写需要上报的维度信息。弹窗可能会影响原始的业务页面布局和DOM结构，怎么避免呢？

我们可以使用Shadow DOM来避免这个问题。 Shadow DOM允许在文档（document）渲染时插入一棵DOM元素子树，但是这棵子树不在主DOM树中。 主DOM树的CSS选择器和JavaScript代码都不会影响到Shadow DOM，也保护主文档不受shadow DOM样式的侵袭。

#### 唯一标识的生成

如何生成唯一的标识，标记业务模块的view呢？最容易想到的实现就是利用DOM选择器(css-selector)，DOM选择器能选择了批量的节点，比如一个ul列表。为了避免这个问题，我们可以在提供的额外标识，比如是在ul中第几个li上。彻底避免这个问题，可以使用节点在DOM树(xpath)，从根节点到此节点唯一的路径。如此，处理也还是有问题，还是用ul列表举例，比如业务目标就是一个ul列表呢？这种情况，处理办法也很简单，直接标记li的父节点ul即可。

上面两个办法可以实现view的标识，但都无法处理DOM结构变更的问题。强依赖DOM结构，而业务变动或项目维护，很可能导致DOM变化，标识失效。

为了避免对DOM的依赖，我们还是上报点击事件在view中的坐标。不过，这个实现有一个问题，就是屏幕尺寸是不确定的。解决方法：我们规定一个标准的屏幕大小，把其他屏幕规约到这个标准屏幕。

即便是利用坐标，依然会受业务代码修改的影响。比如，以前按钮在页面最上面，后面修改为最下面。点击相同的坐标，但业务已经不一样了。

怎么处理这种变化呢？我们还是可以这样，记录当前的业务页面的结构，同时记录所有的点击事件。当我们需要查看业务数据的时候，把上报的点击的数据和业务页面结合起来，从记录所有数据中规约出我们想要的数据。这种办法可以应对业务代码变更，但代价也很大，需要记录非常多的冗余数据。

这和编程语言的类型推导功能一样，虽然可以推导类型，很多实现都有一些边界情况，比如Haskell的大名鼎鼎的HM类型系统。反而不如我们编程的时候写上类型来得简单。

如果我们在DOM中，对需要上报的业务的最外层，添加id作为标识，当我们生成唯一标识的时候，先识别外层的id，以此为基准，生成唯一的标识。以后代码变更的时候，这个id作为约定，保留下来即可。

不过这么处理，就不能称之为无埋点了。

### 结合业务

如果上报的数据需要结合业务或计算呢？

我们可以引入JS，允许打点的时候，执行一个JS函数，上报这个函数输出的结果即可。

## 参考资料

- [揭开JS无埋点技术的神秘面纱](http://unclechen.github.io/2018/06/24/%E6%8F%AD%E5%BC%80JS%E6%97%A0%E5%9F%8B%E7%82%B9%E6%8A%80%E6%9C%AF%E7%9A%84%E7%A5%9E%E7%A7%98%E9%9D%A2%E7%BA%B1/)

- [JS埋点技术分析](http://unclechen.github.io/2017/12/24/JS%E5%9F%8B%E7%82%B9%E6%8A%80%E6%9C%AF%E5%88%86%E6%9E%90/)

- [神奇的Shadow DOM](https://aotu.io/notes/2016/06/24/Shadow-DOM/index.html)

- 《现代前端技术解析》by 张成文

- [网站统计那些事（一）：背景与基础概念](https://afantasy.ninja/2017/05/08/user-tracking-i/)

- [网站统计那些事（二）：统计脚本实现（上） ](https://afantasy.ninja/2017/05/08/user-tracking-ii/)

- [网站统计那些事（三）：统计脚本实现（下）](https://afantasy.ninja/2017/05/08/user-tracking-iii/)

- [网站统计那些事（四）：工程化，模块化与测试](https://afantasy.ninja/2017/05/08/user-tracking-iv/)

## change log

- 2019/4/22 created doc

- 2019/4/23 未能细致整理，由于有自己思考的切入点了，这里暂时直接使用参考资料文字

- 2019/5/7 新增Codeless Tracking无埋点技术

- 2019/5/8 上午，补充白屏时间的测量的技术实现

- 2019/5/8 下午，补充首屏时间的测量的技术实现
