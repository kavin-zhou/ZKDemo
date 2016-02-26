//
//  ZKLocalViewController.m
//  ZKDemo
//
//  Created by ZK on 16/2/26.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKLocalViewController.h"
#import "ZKXibViewController.h"
#import "ZKCodeViewController.h"
#import "ZKConfig.h"
#import "NSBundle+Language.h"
#import "AppDelegate.h"
#import "ZKMainViewController.h"

@interface ZKLocalViewController () <UIActionSheetDelegate>

@end

@implementation ZKLocalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)xibBtnClick {
    ZKXibViewController *xibVC = [[ZKXibViewController alloc] init];
    [self.navigationController pushViewController:xibVC animated:YES];
}

- (IBAction)codeBtnClick {
    ZKCodeViewController *codeVC = [[ZKCodeViewController alloc] init];
    [self.navigationController pushViewController:codeVC animated:YES];
}

- (IBAction)seleteLanguageBtnClick {
    UIActionSheet *sheetView = [[UIActionSheet alloc] initWithTitle:ZKLocalizedString(@"选择语言")delegate:self cancelButtonTitle:ZKLocalizedString(@"取消")destructiveButtonTitle:nil otherButtonTitles:ZKLocalizedString(@"中文"),ZKLocalizedString(@"日文"), nil];
    [sheetView showInView:self.view];
}

// <UIActionSheetDelegate>
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            NSLog(@"选择中文");
            [self didSeleteLanguage:@"zh-Hans"];
        }
            break;
            
        case 1: {
            NSLog(@"选择日文");
            [self didSeleteLanguage:@"ja"];
        }
            break;
            
        default:
            break;
    }
}

- (void)didSeleteLanguage:(NSString *)language
{
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:UserDefaultKey_AppLanguage];
    [NSBundle setLanguage:language];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate refreshMain];
}

@end
