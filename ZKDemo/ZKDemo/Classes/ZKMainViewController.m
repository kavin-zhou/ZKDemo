//
//  ZKMainViewController.m
//  ZKDemo
//
//  Created by ZK on 16/2/26.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKMainViewController.h"
#import "ZKPinchViewController.h"
#import "ZKLocalViewController.h"

@interface ZKMainViewController ()

@end

@implementation ZKMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)localBtnClick
{
    ZKLocalViewController *localVC = [[ZKLocalViewController alloc] init];
    [self.navigationController pushViewController:localVC animated:YES];
}

- (IBAction)pinchBtnClick
{
    ZKPinchViewController *pinchVC = [[ZKPinchViewController alloc] init];
    [self.navigationController pushViewController:pinchVC animated:YES];
}

@end
