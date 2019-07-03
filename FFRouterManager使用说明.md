**前言：** FFRouterManager是继承自**FFRouter**的一个路由封装管理类，可以直接调用原FFRouter的类方法，初始化实例方法新增为```[FFRouterManager shareManager]```。同时，在项目中有两个路由名称的配置文件，分别为```router_simple_names.json（路由地址与简化名称对照表）```和```router_class_common_map.json（路由地址与类名对照表）```,根据定义的路由地址规则，对路由地址进行统一管理。**注意：FFRouter与JLRoutes基本使用方法区别在于，注册路由方法有三种，启动路由的方法也有三种，需要配对使用才有效。**

### 使用方法：

首先 

```#import "FFRouterManager.h"```

#### 路由地址配置准备工作

**router_simple_names.json（路由地址与简化名称对照表）:** 将需要进行跳转的控制器对应的路由地址，统一地加入该文件中，以路由地址为值(value)，简化名称为键(key)，为了方便使用可以将简化名称的规则定为，固定以类名为key。内容仅含字典格式，示例如下：
```
{
    "AViewController":"TestDemo://AControllers/AVC",
    "BViewController":"TestDemo://BControllers/BVC",
    "DViewController":"TestDemo://AControllers/DControllers/DVC",
    "EViewController":"TestDemo://AControllers/EVC"
}

```


**router_class_common_map.json（路由地址与类名对照表，若不与安卓共享路由对照表可不使用此文件）：** 根据具体路由地址，进行关联对应的目标类别。注意：此文件有固定格式，示例如下：
```
{
    "AControllers":[
        {
            "url":"TestDemo://AControllers/AVC",
            "iosclass":"AViewController",
            "androidclass":""
        },
        {
            "url":"TestDemo://AControllers/EVC",
            "iosclass":"EViewController",
            "androidclass":""
        }
    ],
    "AControllers/DControllers":[
        {
            "url":"TestDemo://AControllers/DControllers/DVC",
            "iosclass":"DViewController",
            "androidclass":""
        }
    ],
}
```


#### 具体使用：

**注册路由规则**

```
/**
 注册多个路由，默认本项目的scheme为前缀，若有特殊需求，单独注册路由
 
 @param routeURLs 路由地址
 @param scheme 默认跳转，建议使用项目url scheme,例如：testDemo://
 */
+ (void)registerRouteURLs:(NSArray *)routeURLs scheme:(NSString *)scheme;

/**
 注册多个路由，在使用路由方法routeObjectURL: 可以同步返回一个对象，默认都是目标控制器对象

 @param routeURLs 路由地址
 */
+ (void)registerObjectRouteURLs:(NSArray *)routeURLs scheme:(NSString *)scheme;

/**
 注册多个路由，在使用路由方法routeCallbackURL: targetCallback: 可以异步回调一个对象，当前路由仅作用于页面间跳转，故默认都是目标控制器对象，如有特殊需求，可单独使用FFRouter原方法（+ (void)registerCallbackRouteURL:(NSString *)routeURL handler:(FFCallbackRouterHandler)handlerBlock）注册路由，异步回调需要的内容

 @param routeURLs 路由地址
 */
+ (void)registerCallbackRouteURLs:(NSArray *)routeURLs scheme:(NSString *)scheme;
```

备注：添加路由规则，传入所有路由规则的字符串数组，注意控制器参数对应的key必须是controller,例如：/home/:controller，/shop/detail/:controller等，示例如下：
```
[FFRouterManager registerRouteURLs:@[@"/AControllers/:controller",
                                         @"/AControllers/:controller",
                                         @"/BControllers/:controller",
                                         @"/AControllers/DControllers/:controller"] scheme:@"TestDemo://"];
    [FFRouterManager registerObjectRouteURLs:@[@"/CControllers/:controller"] scheme:@"TestDemo://"];
    [FFRouterManager registerCallbackRouteURLs:@[@"/AControllers/DControllers/:controller"] scheme:@"TestDemo://"];
```


**启动路由，跳转至目标控制器（默认为push方式）**
```
/**
 与registerRouteURLs配对使用，启动路由

 @param name 路由简称
 @param isPresent 是否为模态跳转方式
 */
+ (void)routeWithName:(NSString *)name isPresent:(BOOL)isPresent;

/**
 与registerObjectRouteURLs配对使用，启动路由

 @param name 路由简称
 @param isPresent 是否为模态跳转方式
 @return 当前默认为目标控制器对象
 */
+ (id)routeObjectWithName:(NSString *)name isPresent:(BOOL)isPresent;

/**
 与registerObjectRouteURLs配对使用，启动路由

 @param name 路由简称
 @param isPresent isPresent 是否为模态跳转方式
 @param targetCallback 当前默认异步回调对象为目标控制器对象
 */
+ (void)routeCallbackWithName:(NSString *)name isPresent:(BOOL)isPresent targetCallback:(FFRouterCallback)targetCallback;
```
备注：兼容在参数中传入```jumptype:"present"```声明以模态方式跳转，入参```(BOOL)isPresent```优先级大于完整路由地址中的```jumptype```参数。

**携带参数跳转**
```
/// 相较以上三个方法，多了一个入参字典
+ (void)routeWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters isPresent:(BOOL)isPresent;

+ (id)routeObjectWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters isPresent:(BOOL)isPresent;

+ (void)routeCallbackWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters isPresent:(BOOL)isPresent targetCallback:(FFRouterCallback)targetCallback;
```

**使用FFRouter原完整路由地址跳转方法，无需依赖路由对照表**
```
/**
 Route a URL
 
 @param URL URL to be routed
 */
+ (void)routeURL:(NSString *)URL;

/**
 Route a URL and bring additional parameters.
 
 @param URL URL to be routed
 @param parameters Additional parameters
 */
+ (void)routeURL:(NSString *)URL withParameters:(NSDictionary<NSString *, id> *)parameters;

/**
 Route a URL and get the returned Object
 
 @param URL URL to be routed
 @return Returned Object
 */
+ (id)routeObjectURL:(NSString *)URL;

/**
 Route a URL and bring additional parameters. get the returned Object
 
 @param URL URL to be routed
 @param parameters Additional parameters
 @return Returned Object
 */
+ (id)routeObjectURL:(NSString *)URL withParameters:(NSDictionary<NSString *, id> *)parameters;

/**
 Route a URL, 'targetCallBack' can asynchronously callback to return a Object.
 
 @param URL URL to be routed
 @param targetCallback asynchronous callback
 */
+ (void)routeCallbackURL:(NSString *)URL targetCallback:(FFRouterCallback)targetCallback;

/**
 Route a URL with additional parameters, and 'targetCallBack' can asynchronously callback to return a Object.
 
 @param URL URL to be routed
 @param parameters Additional parameters
 @param targetCallback asynchronous callback
 */
+ (void)routeCallbackURL:(NSString *)URL withParameters:(NSDictionary<NSString *, id> *)parameters targetCallback:(FFRouterCallback)targetCallback;
```