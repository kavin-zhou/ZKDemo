//
//  AppDelegate.m
//  ZKDemo
//
//  Created by ZK on 16/2/26.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "AppDelegate.h"
#import "ZKMainViewController.h"
#import "NSBundle+Language.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setupLocalized];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self refreshMain];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)setupLocalized
{
    // 设置默认语言
    if (![[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultKey_AppLanguage]) {
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *language = languages.firstObject;
        if ([language hasPrefix:@"zh-Hans"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:UserDefaultKey_AppLanguage];
        }
        else if ([language hasPrefix:@"ja"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"ja" forKey:UserDefaultKey_AppLanguage];
        }
    }
    
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultKey_AppLanguage];
    [NSBundle setLanguage:language];
}

- (void)refreshMain
{
    ZKMainViewController *mainVC = [[ZKMainViewController alloc] init];
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    self.window.rootViewController = naVC;
}

@end
