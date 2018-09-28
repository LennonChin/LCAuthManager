//
//  LCGestureAuthPassword.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCGestureAuthPassword.h"
#import "LCAuthManagerConstant.h"
#import "LCAuthManagerConfig.h"
#import "LCAuthManager.h"

@implementation LCGestureAuthPassword

#pragma mark - 锁屏密码读写
/** 读取锁屏密码 */
+ (NSString*)loadLockPassword {
    
    NSString* password = (NSString *)[[LCAuthManager globalConfig] getPersistenceValueForKey:@"GesturePassword"];
    if (password != nil && ![password isEqualToString:@""] && ![password isEqualToString:@"(null)"]) {
        return password;
    }
    return nil;
}

/** 存储锁屏密码 */
+ (void)saveLockPassword:(NSString*)password {
    [[LCAuthManager globalConfig] setPersistenceValue:password forKey:@"GesturePassword"];
}

/** 是否需要提示输入密码 */
+ (BOOL)isAlreadyAskedCreateLockPassword {
    NSString* password = (NSString *)[[LCAuthManager globalConfig] getPersistenceValueForKey:@"AlreadyAsk"];
    if (password != nil && [password isEqualToString:@"YES"]) {
        return NO;
    }
    return YES;
}

/** 需要提示过输入密码了 */
+ (void)setAlreadyAskedCreateLockPassword {
    [[LCAuthManager globalConfig] setPersistenceValue:@"YES" forKey:@"AlreadyAsk"];
}
@end
