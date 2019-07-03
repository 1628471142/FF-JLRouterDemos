**前言：** JLRoutesManager是继承自**JLRoutes**的一个路由封装管理类，可以直接调用原JLRoutes的类方法，初始化实例方法新增为```[JLRoutesManager shareManager]```。同时，在项目中有两个路由名称的配置文件，分别为```router_simple_names.json（路由地址与简化名称对照表）```和```router_class_common_map.json（路由地址与类名对照表）```,根据定义的路由地址规则，对路由地址进行统一管理。

### 使用方法：

首先 

```#import "JLRoutesManager.h"```

#### 路由地址配置准备工作

**router_simple_names.json（路由地址与简化名称对照表）:** 将需要进行跳转的控制器对应的路由地址，统一地加入该文件中，以路由地址为值(value)，简化名称为键(key)，为了方便使用可以将简化名称的规则定为，固定以类名为key。内容仅含字典格式，示例如下：
```
{
    "AViewController":"JLRouterDemo://AControllers/AVC",
    "BViewController":"JLRouterDemo://BControllers/BVC",
    "DViewController":"JLRouterDemo://AControllers/DControllers/DVC",
    "EViewController":"JLRouterDemo://AControllers/EVC"
}

```


**router_class_common_map.json（路由地址与类名对照表，若不与安卓共享路由对照表可不使用此文件）：** 根据具体路由地址，进行关联对应的目标类别。注意：此文件有固定格式，示例如下：
```
{
    "AControllers":[
        {
            "url":"JLRouterDemo://AControllers/AVC",
            "iosclass":"AViewController",
            "androidclass":""
        },
        {
            "url":"JLRouterDemo://AControllers/EVC",
            "iosclass":"EViewController",
            "androidclass":""
        }
    ],
    "AControllers/DControllers":[
        {
            "url":"JLRouterDemo://AControllers/DControllers/DVC",
            "iosclass":"DViewController",
            "androidclass":""
        }
    ],
}
```


#### 具体使用：

**添加路由规则**

```
/**
 添加路由规则

 @param routePatterns 路由规则数组，例如：/AControllers/:controller
 */
- (void)addRoutes:(NSArray *)routePatterns;
```

备注：添加路由规则，传入所有路由规则的字符串数组，注意控制器参数对应的key必须是controller,例如：/home/:controller，/shop/detail/:controller等。


**以push方式进行跳转至路由简化名称对应的目标控制器**
```
/**
 根据router_name_list.json简化路由名称，查找完整路由地址，默认以push方式进行跳转

 @param name 路由简化名称
 @return 是否查找到该路由
 */
+ (BOOL)routeWithName:(NSString *)name;

+ (BOOL)routeWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters;
```
备注：兼容在参数中传入```jumptype:"present"```声明以模态方式跳转，参数用下边的方法以字典方式传入，会以kvc的方式，入参至目标控制器对象，下同。

**以模态方式进行跳转至路由简化名称对应的目标控制器**
```
/**
 以模态方式跳转，其他同+ (BOOL)routeWithName:(NSString *)name

 */
+ (BOOL)routeForPresentWithName:(NSString *)name;

+ (BOOL)routeForPresentWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters;
```

**使用完整路由地址跳转方法，无需依赖路由对照表**
```
/**
 根据路由完整地址跳转

 @param URLString 路由完整地址
 @return 是否查找到该路由
 */
+ (BOOL)routeURLString:(NSString *)URLString;

+ (BOOL)routeURLString:(NSString *)URLString withParameters:(nullable  NSDictionary *)parameters;
```
备注：传入完整的路由地址，参数可以是直接跟在路由地址后边，也可以以字典方式入参，示例：```JLRouterDemo://AControllers/AVC?jumptype=present&age=18&name=jack```

**后续按需求扩展补充：** 对无效路由地址进行统一的路由至无效提示界面；根据需要跳转至webview的界面，增加webview界面的跳转规则；入参方式在BaseViewController中增加统一解析参数的方法```-(void)configRouteParams:(NSDictionary *)params```，如在个别控制器中捕获到参数，通过重写父类方法等。