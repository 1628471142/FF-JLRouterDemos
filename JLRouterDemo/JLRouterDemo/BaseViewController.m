//
//  BaseViewController.m
//  JLRouterDemo
//
//  Created by 李雪峰 on 2019/6/18.
//  Copyright © 2019 李雪峰. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, ScreenWidth, 50)];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.text = NSStringFromClass([self class]);
    [self.view addSubview:_titleLab];

    _paramLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, ScreenWidth, 50)];
    _paramLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_paramLab];
    
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth - 80)/2, 280, 80, 50)];
    [_backBtn setTitle:@"dismiss" forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
}

- (void)backClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
