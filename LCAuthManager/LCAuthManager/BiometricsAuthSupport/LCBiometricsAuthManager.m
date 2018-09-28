//
//  LCBiometricsAuthManager.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCBiometricsAuthManager.h"
#import "LCAuthManagerConfig.h"
#import "LCAuthManagerConstant.h"
#import "LCAuthManager.h"

static BiometricsType _isSupportBiometricsTypeFlag = BiometricsTypeNone;

@implementation LCBiometricsAuthManager

+ (BiometricsType)isSupportBiometricsAuth {
    
    if (_isSupportBiometricsTypeFlag == BiometricsTypeNone) {
        
        if (@available(iOS 8.0, *)) {
            // 判断设备是否支持生物识别
            LAContext *laContext = [[LAContext alloc] init];
            NSError *error = nil;
            BOOL isSupportBiometrics = [laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
            
            if (isSupportBiometrics && !error) {
                _isSupportBiometricsTypeFlag = BiometricsTypeTouchID;
                if (@available(iOS 11.0, *)) {
                    if (laContext.biometryType == LABiometryTypeFaceID){
                        _isSupportBiometricsTypeFlag = BiometricsTypeFaceID;
                    }
                }
            }
            
        }
        
    }
    return _isSupportBiometricsTypeFlag;
}

+ (void)setBiometricsAuthPersistence:(BOOL)isOn {
    
    if (isOn) {
        
        // 开启生物识别
        // 更新到沙盒，YES-开启了生物识别，NO-未开启生物识别
        [[LCAuthManager globalConfig] setPersistenceValue:@(YES) forKey:@"isSettedBiometricsAuth"];
    } else {
        
        // 关闭生物识别
        // 更新到沙盒，YES-开启了生物识别，NO-未开启生物识别
        [[LCAuthManager globalConfig] setPersistenceValue:@(NO) forKey:@"isSettedBiometricsAuth"];
        
    }
    LCLog(@"持久化生物识别：%d", isOn);
    
}

+ (BOOL)isBiometricsAuthOpened {
    
    NSNumber *flag = (NSNumber *)[[LCAuthManager globalConfig] getPersistenceValueForKey:@"isSettedBiometricsAuth"];
    return [flag boolValue];
}

+ (void)verifyBiometricsAuthWithReason:(NSString *)reason fallbackTitle:(NSString *)fallbackTitle Success:(void (^)(void))successBlock Fail:(void (^)(NSError *error, LAError errorCode))failBlock Fallback:(void (^)(NSError *error, LAError errorCode))fallbackBlock {
    
    BiometricsType biometricsType = [LCBiometricsAuthManager isSupportBiometricsAuth];
    
    if (biometricsType != BiometricsTypeNone) {
        
        //初始化上下文对象
        LAContext *context = [[LAContext alloc] init];
        
        // 支持生物识别验证
        /**
         *LAPolicyDeviceOwnerAuthentication > iOS9.0才可以使用，先验证生物识别，如果选择验证手机密码可以自动调起输入手机密码
         *LAPolicyDeviceOwnerAuthenticationWithBiometrics > iOS8.0才可以使用，先验证生物识别，如果选择验证手机密码需要自己处理
         */
        context.localizedFallbackTitle = fallbackTitle; // 当使用生物识别失败的时候右边的回调按钮显示的文字
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                
                !successBlock ? : successBlock();
                
            } else if (error) {
                
                NSLog(@"LCBiometricsAuthManager evaluatePolicy Error: %@", error);
                
                if (@available(iOS 9.0, *)) {
                    /**
                     * 在这种情况下，如果是指纹识别，会使用密码验证；如果是面容识别，将调用回调
                     * 这里建议在使用面容识别时，不要传入fallbackTitle参数，识别出错时就不会显示右侧按钮
                     * 系统在处理面容识别出错时转为使用密码验证并不完善
                     */
                    if (error.code == LAErrorUserFallback && biometricsType == BiometricsTypeFaceID) {
                        !fallbackBlock ? : fallbackBlock(error, error.code);
                        return;
                    }
                }
                // 当 < iOS9.0且不是点击“输入密码”时才执行失败回调
                !failBlock ? : failBlock(error, error.code);
            }
        }];
        
    } else {
        LCLog(@"不支持生物识别");
    }
    
}
@end
