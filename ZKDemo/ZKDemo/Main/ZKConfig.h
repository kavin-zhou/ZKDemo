
// ------------ 定义define ----------------

/** 根据用户选择 更换语言 */
#define ASLocalizedString(key) [NSString stringWithFormat:@"%@",[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultKey_AppLanguage]] ofType:@"lproj"]] localizedStringForKey:(key) value:nil table:@"ASLocalized"]]

/** 使用系统默认语言 */
//#define ASLocalizedString(key) NSLocalizedStringFromTable(key, @"ASLocalized", nil)


// ------------ 常量声明 ----------------

#import <Foundation/Foundation.h>

@interface ZKConfig : NSObject

extern NSString *const UserDefaultKey_AppLanguage;

@end
