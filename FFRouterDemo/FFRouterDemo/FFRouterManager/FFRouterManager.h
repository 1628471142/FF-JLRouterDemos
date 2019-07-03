//
//  FFRouterManager.h
//  FFRouterDemo
//
//  Created by 李雪峰 on 2019/6/24.
//  Copyright © 2019 李雪峰. All rights reserved.
//

#import "FFRouter.h"
//获取设备的物理高度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
//获取设备的物理宽度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
NS_ASSUME_NONNULL_BEGIN

@interface FFRouterManager : FFRouter

// 路由地址与简化名称对照字典
@property (nonatomic, strong) NSDictionary * routeNamesDictionary;
// 路由地址与类名对照字典
@property (nonatomic, strong) NSDictionary * routeClassNameMap;

+ (FFRouterManager *)shareManager;

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
 注册多个路由，在使用路由方法routeCallbackURL: targetCallback: 可以异步回调一个对象，当前路由仅作用于页面间跳转，故默认都是目标控制器对象

 @param routeURLs 路由地址
 */
+ (void)registerCallbackRouteURLs:(NSArray *)routeURLs scheme:(NSString *)scheme;


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

/// 相较以上三个方法，多了一个入参字典
+ (void)routeWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters isPresent:(BOOL)isPresent;

+ (id)routeObjectWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters isPresent:(BOOL)isPresent;

+ (void)routeCallbackWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters isPresent:(BOOL)isPresent targetCallback:(FFRouterCallback)targetCallback;

@end

NS_ASSUME_NONNULL_END
