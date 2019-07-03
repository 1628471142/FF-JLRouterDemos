//
//  BViewController.m
//  JLRouterDemo
//
//  Created by 李雪峰 on 2019/6/17.
//  Copyright © 2019 李雪峰. All rights reserved.
//

#import "BViewController.h"

@interface BViewController ()
{
    NSString * _sex;
}
@end

@implementation BViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.paramLab.text = [NSString stringWithFormat:@"BViewController name = %@,sex = %@,age = %@",self.name,_sex,_age];
    NSLog(@"BViewController name = %@,sex = %@",self.name,_sex);

}


@end
