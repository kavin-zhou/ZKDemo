//
//  ZKCodeViewController.m
//  ZKDemo
//
//  Created by ZK on 16/2/26.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKCodeViewController.h"
#import "ZKConfig.h"

@interface ZKCodeViewController ()

@end

@implementation ZKCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *button = ({
        button = [[UIButton alloc] init];
        button.frame = CGRectMake(100, 100, 100, 50);
        button.backgroundColor = [UIColor blueColor];
        [button setTitle:ZKLocalizedString(@"点击")forState:UIControlStateNormal];
        [self.view addSubview:button];
        button;
    });
    
    UILabel *label = ({
        label = [[UILabel alloc] init];
        label.frame = CGRectMake(100, 200, 200, 80);
        label.center = self.view.center;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor yellowColor];
        label.text = ZKLocalizedString(@"标签");
        [self.view addSubview:label];
        label;
    });
}


@end
