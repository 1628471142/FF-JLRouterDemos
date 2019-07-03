//
//  ViewController.m
//  JLRouterDemo
//
//  Created by 李雪峰 on 2019/6/17.
//  Copyright © 2019 李雪峰. All rights reserved.
//

#import "ViewController.h"
#import "JLRoutesManager.h"
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
//            [JLRoutesManager routeWithName:@"AViewController" withParameters:@{@"age":@"18"}];
            [JLRoutesManager routeForPresentWithName:@"AViewController" withParameters:@{@"age":@"18"}];
            break;
        case 1:
        {
            NSDictionary * dic = @{@"_sex":@"man",@"name":@"lee",@"_age":@"20"};
            [JLRoutesManager routeWithName:@"BViewController" withParameters:dic];
        }
            break;
        case 2:
            [JLRoutesManager routeWithName:@"CViewController"];
            break;
        case 3:
            [JLRoutesManager routeWithName:@"DViewController"];
            break;
        case 4:
//            [JLRoutesManager routeWithName:@"EViewController"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"FFRouterDemo://"] options:@{} completionHandler:nil];
            break;
        case 5:
            [JLRoutesManager routeWithName:@"presentAViewController" withParameters:@{@"age":@"18"}];
            break;
        default:
            break;
    }
}


@end
