//
//  BaseViewController.h
//  JLRouterDemo
//
//  Created by 李雪峰 on 2019/6/18.
//  Copyright © 2019 李雪峰. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^RouterBackEventBlock)(void);
//获取设备的物理高度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
//获取设备的物理宽度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UILabel * titleLab;

@property (nonatomic, strong) UIButton * backBtn;

@property (nonatomic, strong) UILabel * paramLab;

@property (nonatomic, copy) RouterBackEventBlock backBlock;

- (void)backClick;

@end

NS_ASSUME_NONNULL_END
