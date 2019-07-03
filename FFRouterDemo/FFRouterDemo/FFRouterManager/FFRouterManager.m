//
//  FFRouterManager.m
//  FFRouterDemo
//
//  Created by 李雪峰 on 2019/6/24.
//  Copyright © 2019 李雪峰. All rights reserved.
//

#import "FFRouterManager.h"
#import <objc/runtime.h>

@implementation FFRouterManager
static FFRouterManager * _manager = nil;

+ (FFRouterManager *)shareManager{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _manager = [[FFRouterManager alloc] init];
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

+ (void)registerRouteURLs:(NSArray *)routeURLs scheme:(nonnull NSString *)scheme{
    for (NSString * route in routeURLs) {
        NSString * completeRoute  = [NSString stringWithFormat:@"%@%@",scheme,route];
        [self registerRouteURL:completeRoute handler:^(NSDictionary *routerParameters) {
            NSLog(@"路由成功，parameters = %@",routerParameters);
            [self handleRouterParameters:routerParameters];
        }];
    }
}

+ (void)registerObjectRouteURLs:(NSArray *)routeURLs scheme:(nonnull NSString *)scheme{
    for (NSString * route in routeURLs) {
        NSString * completeRoute  = [NSString stringWithFormat:@"%@%@",scheme,route];
        [self registerObjectRouteURL:completeRoute handler:^id(NSDictionary *routerParameters) {
            NSLog(@"路由成功，parameters = %@",routerParameters);
            return  [self handleRouterParameters:routerParameters];
        }];
    }
}

+ (void)registerCallbackRouteURLs:(NSArray *)routeURLs scheme:(nonnull NSString *)scheme{
    for (NSString * route in routeURLs) {
        NSString * completeRoute  = [NSString stringWithFormat:@"%@%@",scheme,route];
        [self registerCallbackRouteURL:completeRoute handler:^(NSDictionary *routerParameters, FFRouterCallback targetCallback) {
            NSLog(@"路由成功，parameters = %@",routerParameters);
            UIViewController * vc = [self handleRouterParameters:routerParameters];
            targetCallback(vc);
        }];
    }
}

+ (UIViewController *)handleRouterParameters:(NSDictionary *)routerParameters{
    NSString * FFRouterParameterURL = routerParameters[@"FFRouterParameterURL"];
    NSString * module = [self getModuleNameWithRouteURL:FFRouterParameterURL parameters:routerParameters];
    NSString * jumpType = routerParameters[@"jumptype"];
    UIViewController * vc = nil;
    if ([jumpType isEqualToString:@"present"]) {
        vc = [self presentToViewControllerWithParameters:routerParameters module:module];
    }else{
        vc = [self pushToViewControllerWithParameters:routerParameters module:module];
    }
    return vc;
}


+ (NSString *)getModuleNameWithRouteURL:(NSString *)routeURL parameters:(NSDictionary *)routerParameters{
    NSRange startRange = [routeURL rangeOfString:@"//"];
    NSRange endRange = [routeURL rangeOfString:[NSString stringWithFormat:@"/%@",routerParameters[@"controller"]]];
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    NSString * module = [routeURL substringWithRange:range];
    return module;
}

+ (UIViewController *)pushToViewControllerWithParameters:(NSDictionary *)parameters module:(NSString *)module{
    NSString * className = [self getClassNameWithParameters:parameters module:(NSString *)module];
    if (!className) {
        NSLog(@"未查询到对应的class,请查验路由对照表");
        return nil;
    }
    UIViewController * vc = [[NSClassFromString(className) alloc] init];
    UIViewController * curVc = [self getCurrentViewController];
    [self addParamToVC:vc params:parameters];
    if ([curVc navigationController] && vc) {
        [curVc.navigationController pushViewController:vc animated:YES];
        return vc;
    }else{
        NSLog(@"目标控制器不存在或nav控制器不存在，请查验路由入参");
        return nil;
    }
}

+ (UIViewController *)presentToViewControllerWithParameters:(NSDictionary *)parameters module:(NSString *)module{
    NSString * className = [self getClassNameWithParameters:parameters module:(NSString *)module];
    if (!className) {
        NSLog(@"未查询到对应的class,请查验路由对照表");
        return nil;
    }
    UIViewController * vc = [[NSClassFromString(className) alloc] init];
    UIViewController * curVc = [self getCurrentViewController];
    [self addParamToVC:vc params:parameters];
    if (vc && curVc) {
        [curVc presentViewController:vc animated:YES completion:nil];
        return vc;
    }else{
        NSLog(@"控制器不存在，请查验路由入参");
        return nil;
    }
}

+ (NSString *)getClassNameWithParameters:(NSDictionary *)parameters module:(NSString *)module{
    NSString * routeURL = parameters[@"FFRouterParameterURL"];
    NSArray * array = [[self shareManager].routeClassNameMap objectForKey:module];
    NSString * className;
    for (NSDictionary *dic in array) {
        NSString * url = dic[@"url"];
        if ([routeURL containsString:url]) {
            className = dic[@"iosclass"];
            break;
        }
    }
    if (className == nil) {
        for (NSString *key in [self shareManager].routeNamesDictionary.allKeys) {
            NSString * value = [self shareManager].routeNamesDictionary[key];
            if ([value isEqualToString:routeURL]) className = key;
        }
        className = [[self shareManager].routeClassNameMap objectForKey:routeURL];
    }
    return className;
}


+ (void)routeWithName:(NSString *)name isPresent:(BOOL)isPresent{
    [self routeWithName:name withParameters:nil isPresent:isPresent];
}

+ (id)routeObjectWithName:(NSString *)name isPresent:(BOOL)isPresent{
    return [self routeObjectWithName:name withParameters:nil isPresent:isPresent];

}

+ (void)routeCallbackWithName:(NSString *)name isPresent:(BOOL)isPresent targetCallback:(FFRouterCallback)targetCallback{
    [self routeCallbackWithName:name withParameters:nil isPresent:isPresent targetCallback:targetCallback];
}

+ (void)routeWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters isPresent:(BOOL)isPresent{
    NSString * routeURL = [[self shareManager].routeNamesDictionary objectForKey:name];
    if (isPresent) {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithDictionary:parameters];
        [dic setValuesForKeysWithDictionary:@{@"jumptype":@"present"}];
        parameters = [dic copy];
    }
    [self routeURL:routeURL withParameters:parameters];
}

+ (id)routeObjectWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters isPresent:(BOOL)isPresent{
    NSString * routeURL = [[self shareManager].routeNamesDictionary objectForKey:name];
    if (isPresent) {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithDictionary:parameters];
        [dic setValuesForKeysWithDictionary:@{@"jumptype":@"present"}];
        parameters = [dic copy];
    }
    return [self routeObjectURL:routeURL withParameters:parameters];
}

+ (void)routeCallbackWithName:(NSString *)name withParameters:(nullable NSDictionary *)parameters isPresent:(BOOL)isPresent targetCallback:(FFRouterCallback)targetCallback{
    NSString * routeURL = [[self shareManager].routeNamesDictionary objectForKey:name];
    if (isPresent) {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithDictionary:parameters];
        [dic setValuesForKeysWithDictionary:@{@"jumptype":@"present"}];
        parameters = [dic copy];
    }
    [self routeCallbackURL:routeURL targetCallback:targetCallback];
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
