//
//  LCAuthManager.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCAuthManager.h"
#import "LCAuthManagerConfig.h"
#import "LCAuthPasswordManager.h"

// 配置
static LCAuthManagerConfig *_globalConfig = nil;
// 暂停验证的超时时间
static NSTimeInterval _lockTime = 0.0;

@implementation LCAuthManager
#pragma mark 配置
+ (void)setGlobalConfig:(LCAuthManagerConfig *)globalConfig {
    if (!globalConfig) {
        NSLog(@"传入空配置将重置配置");
        _globalConfig = [[LCAuthManagerConfig alloc] init];
        return;
    }
    _globalConfig = globalConfig;
}

+ (LCAuthManagerConfig *)globalConfig {
    return _globalConfig;
}

#pragma mark 代理
+ (void)setDelegate:(id<LCAuthManagerDelegate>)delegate {
    _globalConfig.delegate = delegate;
}

+ (id<LCAuthManagerDelegate>)delegate {
    return _globalConfig.delegate;
}

+ (void)initialize {
    if (!_globalConfig) {
        _globalConfig = [[LCAuthManagerConfig alloc] init];
    }
}

#pragma mark 超时处理
+ (void)setCloseAuthTemporary:(NSTimeInterval)timeout {
    _lockTime = [[NSDate date] dateByAddingTimeInterval:timeout].timeIntervalSince1970;
}
#pragma mark - 手势密码相关
+ (BOOL)isGestureAuthOpened {
    return [LCAuthPasswordManager loadGesturePassword] != nil && [LCAuthPasswordManager loadGesturePassword].length >= _globalConfig.gesturePasswordMinLength;
}


+ (LCGestureAuthViewController *)showGestureAuthViewControllerWithType:(LCGestureAuthViewType)lockViewType hostViewControllerView:(UIViewController *)hostViewController delegate:(id<LCAuthManagerDelegate>)delegate {
    if (lockViewType == LCGestureAuthViewTypeCheck) {
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
        if (nowTime < _lockTime) {
            LCLog(@"设置了超时时间：%f，当前时间：%f", _lockTime, nowTime);
            return nil;
        }
    }
    // 清除超时时间
    _lockTime = 0.0;
    LCGestureAuthViewController *gestureAuthViewController = [[LCGestureAuthViewController alloc] init];
    gestureAuthViewController.lockViewType = lockViewType;
    [LCAuthManager setDelegate:delegate];
    [hostViewController presentViewController:gestureAuthViewController animated:YES completion:nil];
    return gestureAuthViewController;
}

+ (void)directlyTriggerAssistOperation:(NSInteger)operationType {
    // 通知代理
    if ([LCAuthManager delegate] && [[LCAuthManager delegate] respondsToSelector:@selector(assistOperationWithAuthController:viewType:operationType:)]) {
        [[LCAuthManager delegate] assistOperationWithAuthController:nil viewType:LCGestureAuthViewTypeUnknown operationType:operationType];
    }
}

#pragma mark - 生物识别相关
+ (LCBiometricsType)isSupportBiometricsAuth {
    return [LCBiometricsAuthManager isSupportBiometricsAuth];
}

/** 查看是否设置了生物识别 */
+ (BOOL)isBiometricsAuthOpened:(LCBiometricsType)biometricsType {
    if (biometricsType == LCBiometricsTypeUnknown) {
        return [LCAuthPasswordManager isBiometricsAuthOpened:LCBiometricsTypeTouchID] || [LCAuthPasswordManager isBiometricsAuthOpened:LCBiometricsTypeFaceID];
    }
    return [LCAuthPasswordManager isBiometricsAuthOpened:biometricsType];
}

/** 生物识别相关，持久化生物识别的开启状态 */
+ (BOOL)persistBiometricsAuth:(LCBiometricsType)biometricsType isOn:(BOOL)isOn {
    return [LCAuthPasswordManager persistBiometricsAuth:biometricsType isOn:isOn];
}

+ (void)verifyBiometricsAuthWithReason:(NSString *)reason
                         fallbackTitle:(NSString *)fallbackTitle
                               Success:(void (^)(LCBiometricsAuthCheckResultType checkResultType))successBlock
                                  Fail:(void (^)(LCBiometricsAuthCheckResultType checkResultType, NSError *error))failBlock
                              Fallback:(void (^)(LCBiometricsAuthCheckResultType checkResultType, NSError *error))fallbackBlock
                              delegate:(id<LCAuthManagerDelegate>)delegate {
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if (nowTime < _lockTime) {
        LCLog(@"设置了超时时间：%f，当前时间：%f", _lockTime, nowTime);
        return;
    }
    // 清除超时时间
    _lockTime = 0.0;
    [LCAuthManager setDelegate:delegate];
    [LCBiometricsAuthManager verifyBiometricsAuthWithReason:reason fallbackTitle:fallbackTitle Success:successBlock Fail:failBlock Fallback:fallbackBlock];
}
@end
