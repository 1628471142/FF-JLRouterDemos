//
//  ViewController.m
//  FFRouterDemo
//
//  Created by 李雪峰 on 2019/6/21.
//  Copyright © 2019 李雪峰. All rights reserved.
//

#import "ViewController.h"
#import <FFRouter.h>
#import "FFRouterManager.h"
#import "BaseViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    NSArray * ary = @[@"A",@"B",@"C",@"D",@"E",@"presentA"];
    for (int i = 0; i < 6; i ++) {
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(50, 100 + i * 100, 80, 50)];
        [btn setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:btn];
        [btn setTitle:ary[i] forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)btnClick:(UIButton *)sender{
    switch (sender.tag) {
        case 0:
        {
            [FFRouterManager routeWithName:@"AViewController" isPresent:NO];
        }
            break;
        case 1:
        {
            [FFRouterManager routeWithName:@"BViewController" isPresent:NO];
        }
            break;
        case 2:
        {
            BaseViewController * vc = [FFRouterManager routeObjectWithName:@"CViewController" isPresent:YES];
            __weak ViewController * weakself = self;
            __weak BaseViewController * weakvc = vc;
            vc.backBlock = ^{
                [weakself.view setBackgroundColor:weakvc.view.backgroundColor];
            };
        }
            break;
        case 3:
        {
            __weak ViewController * weakself = self;
            [FFRouterManager routeCallbackWithName:@"DViewController" isPresent:NO targetCallback:^(id callbackObjc) {
                NSLog(@"callbackObjc = %@",callbackObjc);
            
            }];
        }
            break;
        case 4:
//            [FFRouterManager routeWithName:@"EViewController" isPresent:NO];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"JLRouterDemo://"] options:@{} completionHandler:nil];

            break;
        case 5:
            [FFRouterManager routeWithName:@"AViewController" isPresent:YES];
            break;
        default:
            break;
    }
}

@end
