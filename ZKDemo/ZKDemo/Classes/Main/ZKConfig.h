
// ------------ 定义define ----------------

/** 根据用户选择 更换语言 */
#define ZKLocalizedString(key) [NSString stringWithFormat:@"%@",[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultKey_AppLanguage]] ofType:@"lproj"]] localizedStringForKey:(key) value:nil table:@"ZKLocalized"]]

/** 使用系统默认语言 */
//#define ZKLocalizedString(key) NSLocalizedStringFromTable(key, @"ZKLocalized", nil)


// ------------ 常量声明 ----------------

#import <Foundation/Foundation.h>

@interface ZKConfig : NSObject

extern NSString *const UserDefaultKey_AppLanguage;

@end
