//
//  JLRoutesManager.h
//  JLRouterDemo
//
//  Created by 李雪峰 on 2019/6/17.
//  Copyright © 2019 李雪峰. All rights reserved.
//

#import "JLRoutes.h"
#import <UIKit/UIKit.h>
//获取设备的物理高度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
//获取设备的物理宽度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
NS_ASSUME_NONNULL_BEGIN

@interface JLRoutesManager : JLRoutes

// 路由地址与简化名称对照字典
@property (nonatomic, strong) NSDictionary * routeNamesDictionary;
// 路由地址与类名对照字典
@property (nonatomic, strong) NSDictionary * routeClassNameMap;

+ (JLRoutesManager *)shareManager;


/**
 添加路由规则

 @param routePatterns 路由规则数组，例如：/AControllers/:controller
 */
- (void)addRoutes:(NSArray *)routePatterns;

/**
 根据router_name_list.json简化路由名称，查找完整路由地址，默认以push方式进行跳转

 @param name 路由简化名称
 @return 是否查找到该路由
 */
+ (BOOL)routeWithName:(NSString *)name;

+ (BOOL)routeWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters;


/**
 以模态方式跳转，其他同+ (BOOL)routeWithName:(NSString *)name

 */
+ (BOOL)routeForPresentWithName:(NSString *)name;

+ (BOOL)routeForPresentWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters;


/**
 根据路由完整地址跳转

 @param URLString 路由完整地址
 @return 是否查找到该路由
 */
+ (BOOL)routeURLString:(NSString *)URLString;

+ (BOOL)routeURLString:(NSString *)URLString withParameters:(nullable  NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
