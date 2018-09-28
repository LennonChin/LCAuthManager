//
//  LCAuthManager.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCAuthManager.h"

static LCAuthManagerConfig *_globalConfig = nil;
// 暂停验证的超时时间
static NSTimeInterval _lockTime = 0.0;

@implementation LCAuthManager
+ (void)setGlobalConfig:(LCAuthManagerConfig *)globalConfig {
    if (!globalConfig) {
        NSLog(@"传入空配置将没有任何效果");
        return;
    }
    _globalConfig = globalConfig;
}

+ (LCAuthManagerConfig *)globalConfig {
    return _globalConfig;
}

+ (void)initialize {
    if (!_globalConfig) {
        _globalConfig = [[LCAuthManagerConfig alloc] init];
    }
}

+ (void)setCloseAuthTemporary:(NSTimeInterval)timeout {
    _lockTime = [[NSDate date] dateByAddingTimeInterval:timeout].timeIntervalSince1970;
}
#pragma mark - 手势密码相关
+ (BOOL)isGestureAuthOpened {
    return [LCGestureAuthPassword loadLockPassword] != nil;
}

#pragma mark - 生物识别相关
+ (BiometricsType)isSupportBiometricsAuth {
    return [LCBiometricsAuthManager isSupportBiometricsAuth];
}

+ (void)setBiometricsAuthPersistence:(BOOL)isOn {
    [LCBiometricsAuthManager setBiometricsAuthPersistence:isOn];
}

+ (BOOL)isBiometricsAuthOpened {
    return [LCBiometricsAuthManager isBiometricsAuthOpened];
}

+ (void)verifyBiometricsAuthWithReason:(NSString *)reason fallbackTitle:(NSString *)fallbackTitle Success:(void (^)(void))successBlock Fail:(void (^)(NSError *error, LAError errorCode))failBlock Fallback:(void (^)(NSError *error, LAError errorCode))fallbackBlock {
    if ([[NSDate date] timeIntervalSince1970] < _lockTime) {
        return;
    }
    // 清除超时时间
    _lockTime = 0.0;
    [LCBiometricsAuthManager verifyBiometricsAuthWithReason:reason fallbackTitle:fallbackTitle Success:successBlock Fail:failBlock Fallback:fallbackBlock];
}

+ (LCGestureAuthViewController *)showGestureAuthViewControllerWithType:(LCGestureAuthViewType)lockViewType hostViewControllerView:(UIViewController *)hostViewController delegate:(id<LCGestureAuthCheckDelegate>)delegate {
    if (lockViewType == LCGestureAuthViewTypeCheck) {
        if ([[NSDate date] timeIntervalSince1970] < _lockTime) {
            return nil;
        }
    }
    // 清除超时时间
    _lockTime = 0.0;
    LCGestureAuthViewController *gestureAuthViewController = [[LCGestureAuthViewController alloc] init];
    gestureAuthViewController.lockViewType = lockViewType;
    gestureAuthViewController.delegate = delegate;
    [hostViewController presentViewController:gestureAuthViewController animated:YES completion:nil];
    return gestureAuthViewController;
}
@end
