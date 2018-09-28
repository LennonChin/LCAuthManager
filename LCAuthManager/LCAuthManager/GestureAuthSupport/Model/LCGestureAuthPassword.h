//
//  LCGestureAuthPassword.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//
//  密码保存模块

#import <Foundation/Foundation.h>
#import "LCAuthManagerConfig.h"

@interface LCGestureAuthPassword : NSObject
#pragma mark - 锁屏密码读写
+ (NSString *)loadLockPassword;
+ (void)saveLockPassword:(NSString *)pswd;
+ (BOOL)isAlreadyAskedCreateLockPassword;
+ (void)setAlreadyAskedCreateLockPassword;
@end
