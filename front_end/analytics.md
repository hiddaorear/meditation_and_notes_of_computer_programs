# analytics

## 切入点

### 用户唯一标识

保证有用户登录态，可以使用用户信息。无，则需要考虑生成唯一token，存储在cookie中，设置较长的过期时间。cookie的缺点，可以被清除。

网站统计多数是要基于用户的数据，所以第一步，要识别用户。

### 上报的请求

#### 朴素实现

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

#### 改进

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

var REPORT_URL = 'https://github.com/';
var IP_LIST = ['127.0.0.1', '127.0.0.1'];

var work = {
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

## 关键指标

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

### 白屏时间(first Paint Time)

- 定义： 打开页面到页面开始有东西渲染。 白屏时间 = 浏览器渲染出第一个元素 - 页面访问时间点； 通常认为是渲染body或解析完head的时间点
- 标准： 无

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

#### 注意

- 页面存在iframe的情况
- gif图片在IE上可能重复触发load事件
- CSS重要背景图需要通过JS请求图片url来统计
- 无图片，则统计文字出现时间
- 解析到某个元素，则首屏完成，可以在这个元素之后加入script计算时间

### 用户可操作时间
- 定义：默认可以认为是domready的时间。用户可以正常操作，如：点击，输入等
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



# 参考资料

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
