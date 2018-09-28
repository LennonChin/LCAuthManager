//
//  LCAuthPasswordManager.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCAuthPasswordManager.h"
#import "LCAuthManagerConstant.h"
#import "LCAuthManagerConfig.h"
#import "LCBiometricsAuthManager.h"
#import "LCAuthManager.h"

@implementation LCAuthPasswordManager

#pragma mark - 手势密码读写
/** 读取锁屏密码 */
+ (NSString *)loadGesturePassword {
    
    if ([LCAuthManager globalConfig].keepAuthentication) {
        BOOL delegateCheckFlag = [[LCAuthManager delegate] respondsToSelector:@selector(loadGestureAuth)];
        NSAssert(delegateCheckFlag, @"如果配置了keepAuthentication项为YES，请实现密码持久化相关的代理方法");
        return [[LCAuthManager delegate] loadGestureAuth];
    } else {
        NSString* password = (NSString *)[self getPersistenceValueForKey:@"GesturePassword"];
        if (password != nil && ![password isEqualToString:@""] && ![password isEqualToString:@"(null)"]) {
            return password;
        }
        return nil;
    }
}

/** 存储锁屏密码 */
+ (BOOL)persistGesturePassword:(NSString *)password {
    if ([LCAuthManager globalConfig].keepAuthentication) {
        BOOL delegateCheckFlag = [[LCAuthManager delegate] respondsToSelector:@selector(persistGestureAuth:)];
        NSAssert(delegateCheckFlag, @"如果配置了keepAuthentication项为YES，请实现密码持久化相关的代理方法");
        return [[LCAuthManager delegate] persistGestureAuth:password];
        
    } else {
        return [self persistenceValue:password forKey:@"GesturePassword"];
    }
}

/** 查看是否设置了生物识别 */
+ (BOOL)isBiometricsAuthOpened:(LCBiometricsType)biometricsType {
    // 非TouchID或FaceID将不处理
    if (biometricsType == LCBiometricsTypeNone) {
        return NO;
    }
    
    if ([LCAuthManager globalConfig].keepAuthentication) {
        BOOL delegateCheckFlag = [[LCAuthManager delegate] respondsToSelector:@selector(isBiometricsAuthOpened:)];
        NSAssert(delegateCheckFlag, @"如果配置了keepAuthentication项为YES，请实现密码持久化相关的代理方法");
        return [[LCAuthManager delegate] isBiometricsAuthOpened:biometricsType];
    } else {
        return [LCBiometricsAuthManager isBiometricsAuthOpened:biometricsType];
    }
}

/** 生物识别相关，持久化生物识别的开启状态 */
+ (BOOL)persistBiometricsAuth:(LCBiometricsType)biometricsType isOn:(BOOL)isOn {
    // 非TouchID或FaceID将不处理
    if (biometricsType == LCBiometricsTypeNone) {
        return NO;
    }
    
    if ([LCAuthManager globalConfig].keepAuthentication) {
        BOOL delegateCheckFlag = [[LCAuthManager delegate] respondsToSelector:@selector(persistBiometricsAuth:isOn:)];
        NSAssert(delegateCheckFlag, @"如果配置了keepAuthentication项为YES，请实现密码持久化相关的代理方法");
        return [[LCAuthManager delegate] persistBiometricsAuth:biometricsType isOn:isOn];
    } else {
        return [LCBiometricsAuthManager persistBiometricsAuth:biometricsType isOn:isOn];
    }
}

+ (BOOL)persistenceValue:(NSObject *)value forKey:(NSString *)key {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *configs = [userDefaults objectForKey:[LCAuthManager globalConfig].persistenceName];
    if (!configs || ![configs isKindOfClass:[NSDictionary class]]) {
        configs = [NSDictionary dictionary];
    }
    NSMutableDictionary *operateConfigs = [configs mutableCopy];
    if (value) {
        [operateConfigs setObject:value forKey:key];
    } else {
        [operateConfigs removeObjectForKey:key];
    }
    
    [userDefaults setObject:operateConfigs forKey:[LCAuthManager globalConfig].persistenceName];
    [userDefaults synchronize];
    return YES;
}

+ (NSObject *)getPersistenceValueForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *configs = [userDefaults objectForKey:[LCAuthManager globalConfig].persistenceName];
    if (!configs || ![configs isKindOfClass:[NSDictionary class]]) {
        return nil;
    } else {
        return [configs objectForKey:key];
    }
}
@end
