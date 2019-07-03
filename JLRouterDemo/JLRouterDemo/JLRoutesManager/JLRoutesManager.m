//
//  JLRoutesManager.m
//  JLRouterDemo
//
//  Created by 李雪峰 on 2019/6/17.
//  Copyright © 2019 李雪峰. All rights reserved.
//

#import "JLRoutesManager.h"
#import <objc/runtime.h>
@implementation JLRoutesManager

static JLRoutesManager * _manager = nil;

+ (JLRoutesManager *)shareManager{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _manager = [self globalRoutes];
        _manager.routeNamesDictionary = [self readSimpleNamesJSON];
        _manager.routeClassNameMap = [self readClassMapJSON];
    });
    return _manager;
}

// 读取本地路由简化名称对照表
+ (NSDictionary *)readSimpleNamesJSON{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"router_simple_names" ofType:@"json"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSDictionary * jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (!data || error) {
        //DLog(@"JSON解码失败");
        return nil;
    } else {
        return jsonObj;
    }
}

// 读取路由与类名对照表
+ (NSDictionary *)readClassMapJSON{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"router_class_common_map" ofType:@"json"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSDictionary * jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (!data || error) {
        //DLog(@"JSON解码失败");
        return nil;
    } else {
        return jsonObj;
    }
}

- (void)addRoutes:(NSArray *)routePatterns{
    for (NSString * route in routePatterns) {
        [self addRoute:route handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
            NSLog(@"路由成功，parameters = %@",parameters);
            NSString * JLRoutePattern = parameters[@"JLRoutePattern"];
            NSString * module = [JLRoutesManager getModuleNameWithPattern:JLRoutePattern];
            NSString * jumpType = parameters[@"jumptype"];
            if ([jumpType isEqualToString:@"present"]) {
                [JLRoutesManager presentToViewControllerWithParameters:parameters module:module];
            }else{
                [JLRoutesManager pushToViewControllerWithParameters:parameters module:module];
            }
            return YES;
        }];
    }
}

+ (NSString *)getModuleNameWithPattern:(NSString *)JLRoutePattern{
    NSRange startRange = [JLRoutePattern rangeOfString:@"/"];
    NSRange endRange = [JLRoutePattern rangeOfString:@"/:controller"];
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    NSString * module = [JLRoutePattern substringWithRange:range];
    return module;
}

+ (void)pushToViewControllerWithParameters:(NSDictionary *)parameters module:(NSString *)module{
    NSString * className = [self getClassNameWithParameters:parameters module:(NSString *)module];
    if (!className) {
        NSLog(@"未查询到对应的class,请查验路由对照表");
        return;
    }
    UIViewController * vc = [[NSClassFromString(className) alloc] init];
    UIViewController * curVc = [JLRoutesManager getCurrentViewController];
    [JLRoutesManager addParamToVC:vc params:parameters];
    if ([curVc navigationController] && vc) {
        [curVc.navigationController pushViewController:vc animated:YES];
    }else{
        NSLog(@"目标控制器不存在或nav控制器不存在，请查验路由入参");
    }
}

+ (void)presentToViewControllerWithParameters:(NSDictionary *)parameters module:(NSString *)module{
    NSString * className = [self getClassNameWithParameters:parameters module:(NSString *)module];
    if (!className) {
        NSLog(@"未查询到对应的class,请查验路由对照表");
        return;
    }
    UIViewController * vc = [[NSClassFromString(className) alloc] init];
    UIViewController * curVc = [JLRoutesManager getCurrentViewController];
    [JLRoutesManager addParamToVC:vc params:parameters];
    if (vc && curVc) {
        [curVc presentViewController:vc animated:YES completion:nil];
    }else{
        NSLog(@"控制器不存在，请查验路由入参");
    }
}

+ (NSString *)getClassNameWithParameters:(NSDictionary *)parameters module:(NSString *)module{
    NSURL * routeURL = parameters[@"JLRouteURL"];
    NSArray * array = [[self shareManager].routeClassNameMap objectForKey:module];
    NSString * className;
    for (NSDictionary *dic in array) {
        NSString * url = dic[@"url"];
        if ([routeURL.absoluteString containsString:url]) {
            className = dic[@"iosclass"];
            break;
        }
    }
    if (className == nil) {
        for (NSString *key in [self shareManager].routeNamesDictionary.allKeys) {
            NSString * value = [self shareManager].routeNamesDictionary[key];
            if ([value isEqualToString:routeURL.absoluteString]) className = key;
        }
        className = [[self shareManager].routeClassNameMap objectForKey:routeURL.absoluteString];
    }
    return className;
}

+ (BOOL)routeWithName:(NSString *)name{
    return [self routeWithName:name withParameters:nil];
}

+ (BOOL)routeForPresentWithName:(NSString *)name{
    return [self routeForPresentWithName:name withParameters:nil];
}

+ (BOOL)routeWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters{
    NSString * routeURL = [[self shareManager].routeNamesDictionary objectForKey:name];
    if (routeURL) {
        return [self routeURLString:routeURL withParameters:parameters];
    }else{
        return NO;
    }
}

+ (BOOL)routeForPresentWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    [dic setValuesForKeysWithDictionary:@{@"jumptype":@"present"}];
    return [self routeWithName:name withParameters:dic];
}

+ (BOOL)routeURLString:(NSString *)URLString{
    return [self routeURLString:URLString withParameters:nil];
}

+ (BOOL)routeURLString:(NSString *)URLString withParameters:(nullable NSDictionary *)parameters{
    NSURL * url = [NSURL URLWithString:URLString];
    return [[self shareManager] routeURL:url withParameters:parameters];
}

// 暂简单统一实现，后续在BaseViewController增加入参方法，有特殊需求其子类可重写
+ (void)addParamToVC:(UIViewController *)vc params:(NSDictionary <NSString *,NSString *>*)params{
    unsigned int outCount = 0;
    objc_property_t * properties = class_copyPropertyList(vc.class , &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithUTF8String:property_getName(property)];
        NSString *param = params[key];
        if (param != nil) {
            [vc setValue:param forKey:key];
        }
    }
}

+ (UIViewController *)getCurrentViewController {
    UIViewController * vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        } else {
            break;
        }
    }
    return vc;
}


@end
