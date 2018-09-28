//
//  LCAuthManagerConfig.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCAuthManagerConfig.h"

@implementation LCAuthManagerConfig
- (instancetype)init {
    if (self = [super init]) {
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig {
    _persistenceName = @"LCAuthManagerConfig";
#pragma mark - 手势密码相关配置
    // 密码配置
    _passwordMinLength = 4;
    _maxGestureRetryTimes = 5;
    // 指示器相关
    _normalTipColor = [UIColor colorWithRed:0.96 green:0.36 blue:0.37 alpha:1];
    _errorTipColor = [UIColor colorWithRed:245.0 / 255.0 green:67.0 / 255.0 blue:73.0 / 255.0 alpha:1.0];
    _indicatorCircleBaseTagNumber = 10000;
    _indicatorCircleDiameter = 10.0;
    _indicatorCircleMargin = 8.0;
    _indicatorCircleBorderWidth = 1.0;
    _indicatorAutoResetStatesTime = 0.8;
    _indicatorCircleNormalBgColor = [UIColor whiteColor];
    _indicatorCircleNormalBorderColor = [UIColor lightGrayColor];
    _indicatorCircleActiveBgColor = [UIColor colorWithRed:0.96 green:0.36 blue:0.37 alpha:1];
    _indicatorCircleActiveBorderColor = [UIColor colorWithRed:245.0 / 255.0 green:67.0 / 255.0 blue:74.0 / 255.0 alpha:1.0];
    // 解锁区域
    _touchAreaWithAndHeight = 280;
    _touchAreaCircleBaseTagNumber = 10000;
    _touchAreaCircleMargin = 10.0;
    _touchAreaCircleDiameter = 65;
    _touchAreaCircleAlpha = 1.0;
    _touchAreaButtonNormalImage = [UIImage imageNamed:@"LCAuthManager.bundle/gesture_auth_circle_normal"];
    _touchAreaButtonActiveImage = [UIImage imageNamed:@"LCAuthManager.bundle/gesture_auth_circle_selected"];
    _touchAreaButtonErrorImage = [UIImage imageNamed:@"LCAuthManager.bundle/gesture_auth_circle_error"];
    _touchAreaLineWidth = 2.0;
    _touchAreaLineColor = [UIColor colorWithRed:0.96 green:0.36 blue:0.37 alpha:1];
    _touchAreaLineColorWrong = [UIColor colorWithRed:201.0/255.0 green:9.0/255.0 blue:22.0/255.0 alpha:0.8];
    _closeGestureAuthButtonImage = [UIImage imageNamed:@"LCAuthManager.bundle/gesture_auth_close"];
    
}

- (void)setPersistenceValue:(NSObject *)value forKey:(NSString *)key {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *configs = [userDefaults objectForKey:_persistenceName];
    if (!configs || ![configs isKindOfClass:[NSDictionary class]]) {
        configs = [NSDictionary dictionary];
    }
    NSMutableDictionary *operateConfigs = [configs mutableCopy];
    if (value) {
        [operateConfigs setObject:value forKey:key];
    } else {
        [operateConfigs removeObjectForKey:key];
    }
    
    [userDefaults setObject:operateConfigs forKey:_persistenceName];
    [userDefaults synchronize];
}

- (NSObject *)getPersistenceValueForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *configs = [userDefaults objectForKey:_persistenceName];
    if (!configs || ![configs isKindOfClass:[NSDictionary class]]) {
        return nil;
    } else {
        return [configs objectForKey:key];
    }
}
@end
