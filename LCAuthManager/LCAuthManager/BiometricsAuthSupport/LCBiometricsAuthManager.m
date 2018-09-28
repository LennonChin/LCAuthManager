//
//  LCBiometricsAuthManager.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCBiometricsAuthManager.h"
#import "LCBiometricsCheckError.h"
#import "LCAuthManager.h"
#import "LCAuthManagerConfig.h"
#import "LCAuthPasswordManager.h"

static LCBiometricsType _isSupportBiometricsTypeFlag = LCBiometricsTypeNone;

@implementation LCBiometricsAuthManager

+ (LCBiometricsType)isSupportBiometricsAuth {
    
    if (_isSupportBiometricsTypeFlag == LCBiometricsTypeNone) {
        
        if (@available(iOS 8.0, *)) {
            // 判断设备是否支持生物识别
            LAContext *laContext = [[LAContext alloc] init];
            NSError *error = nil;
            BOOL isSupportBiometrics = [laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
            
            if (isSupportBiometrics && !error) {
                _isSupportBiometricsTypeFlag = LCBiometricsTypeTouchID;
                if (@available(iOS 11.0, *)) {
                    if (laContext.biometryType == LABiometryTypeFaceID){
                        _isSupportBiometricsTypeFlag = LCBiometricsTypeFaceID;
                    }
                }
            }
            
        }
        
    }
    return _isSupportBiometricsTypeFlag;
}

+ (BOOL)persistBiometricsAuth:(LCBiometricsType)biometricsType isOn:(BOOL)isOn {
    
    if (isOn) {
        
        // 开启生物识别
        // 更新到沙盒，YES-开启了生物识别，NO-未开启生物识别
        return [LCAuthPasswordManager persistenceValue:@(YES) forKey:[NSString stringWithFormat:@"isSettedBiometricsAuth-%zd", biometricsType]];
    } else {
        
        // 关闭生物识别
        // 更新到沙盒，YES-开启了生物识别，NO-未开启生物识别
        return [LCAuthPasswordManager persistenceValue:@(NO) forKey:[NSString stringWithFormat:@"isSettedBiometricsAuth-%zd", biometricsType]];
    }
    LCLog(@"持久化生物识别，类型：%zd，值：%d", biometricsType, isOn);
    
}

+ (BOOL)isBiometricsAuthOpened:(LCBiometricsType)biometricsType {
    
    NSNumber *flag = (NSNumber *)[LCAuthPasswordManager getPersistenceValueForKey:[NSString stringWithFormat:@"isSettedBiometricsAuth-%zd", biometricsType]];
    LCLog(@"获取生物识别，类型：%zd，结果：%d", biometricsType, [flag boolValue]);
    return [flag boolValue];
}

+ (void)verifyBiometricsAuthWithReason:(NSString *)reason
                         fallbackTitle:(NSString *)fallbackTitle
                               Success:(void (^)(LCBiometricsAuthCheckResultType checkResultType))successBlock
                                  Fail:(void (^)(LCBiometricsAuthCheckResultType checkResultType, NSError *error))failBlock
                              Fallback:(void (^)(LCBiometricsAuthCheckResultType checkResultType, NSError *error))fallbackBlock {
    
    LCBiometricsType biometricsType = [LCBiometricsAuthManager isSupportBiometricsAuth];
    
    if (biometricsType != LCBiometricsTypeNone) {
        
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
                
                !successBlock ? : successBlock(LCBiometricsAuthCheckResultTypeSuccess);
                if ([[LCAuthManager delegate] respondsToSelector:@selector(biometricsCheckState:biometricsType:error:)]) {
                    [[LCAuthManager delegate] biometricsCheckState:LCBiometricsAuthCheckResultTypeSuccess biometricsType:biometricsType error:nil];
                }
                
            } else if (error) {
                
                NSLog(@"LCBiometricsAuthManager evaluatePolicy Error: %@", error);
                
                LCBiometricsCheckError *checkError = [self operateFailResultState:error];
                
                if (@available(iOS 9.0, *)) {
                    /**
                     * 在这种情况下，如果是指纹识别，会使用密码验证；如果是面容识别，将调用回调
                     * 这里建议在使用面容识别时，不要传入fallbackTitle参数，识别出错时就不会显示右侧按钮
                     * 系统在处理面容识别出错时转为使用密码验证并不完善
                     */
                    if (error.code == LAErrorUserFallback && biometricsType == LCBiometricsTypeFaceID) {
                        !fallbackBlock ? : fallbackBlock(checkError.errorCode, checkError);
                        if ([[LCAuthManager delegate] respondsToSelector:@selector(biometricsCheckState:biometricsType:error:)]) {
                            [[LCAuthManager delegate] biometricsCheckState:checkError.errorCode biometricsType:biometricsType error:checkError];
                        }
                        return;
                    }
                }
                // 当 < iOS9.0且不是点击“输入密码”时才执行失败回调
                !failBlock ? : failBlock(checkError.errorCode, checkError);
                if ([[LCAuthManager delegate] respondsToSelector:@selector(biometricsCheckState:biometricsType:error:)]) {
                    [[LCAuthManager delegate] biometricsCheckState:checkError.errorCode biometricsType:biometricsType error:checkError];
                }
            }
        }];
        
    } else {
        LCLog(@"不支持生物识别");
    }
    
}

+ (LCBiometricsCheckError *)operateFailResultState:(NSError *_Nullable)error {
    
    NSString *biometericsTypeText = @"生物识别";
    if ([LCBiometricsAuthManager isSupportBiometricsAuth] != LCBiometricsTypeNone) {
        biometericsTypeText = [LCBiometricsAuthManager isSupportBiometricsAuth] == LCBiometricsTypeTouchID ? @"Touch ID" : @"Face ID";
    }
    
    LCBiometricsAuthCheckResultType errorCode = LCBiometricsAuthCheckResultTypeUnknown;
    
    if (@available(iOS 11.0, *)) {
        switch (error.code) {
            case LAErrorAuthenticationFailed:
                {
                    NSLog(@"%@验证失败", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeFail;
                }
                break;
            case LAErrorUserCancel:
                {
                    NSLog(@"%@被用户手动取消", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeUserCancel;
                }
                break;
            case LAErrorUserFallback:
                {
                    NSLog(@"用户不使用%@，选择手动输入密码", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeInputPassword;
                }
                break;
            case LAErrorSystemCancel:
                {
                    NSLog(@"%@被系统取消，如遇到来电、锁屏、用户点击了Home键等", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeSystemCancel;
                }
                break;
            case LAErrorPasscodeNotSet:
                {
                    NSLog(@"%@无法启动,因为用户没有设置密码", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypePasswordNotSet;
                }
                break;
            case LAErrorBiometryNotEnrolled:
                {
                    NSLog(@"%@无法启动，因为用户没有设置%@", biometericsTypeText, biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeTouchIDNotSet;
                }
                break;
            case LAErrorBiometryNotAvailable:
                {
                    NSLog(@"%@无效", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeTouchIDNotAvailable;
                }
                break;
            case LAErrorBiometryLockout:
                {
                    NSLog(@"%@被锁定，连续多次验证%@失败，系统需要用户手动输入密码", biometericsTypeText, biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeTouchIDLockout;
                }
                break;
            case LAErrorAppCancel:
                {
                    NSLog(@"当前软件被挂起并取消了授权，如App进入了后台等");
                    errorCode = LCBiometricsAuthCheckResultTypeAppCancel;
                }
                break;
            case LAErrorInvalidContext:
                {
                    NSLog(@"当前软件被挂起并取消了授权，LAContext对象无效");
                    errorCode = LCBiometricsAuthCheckResultTypeInvalidContext;
                }
                break;
            default:
                break;
        }
    } else {
        // iOS 11.0以下的版本只有Touch ID认证
        switch (error.code) {
            case LAErrorAuthenticationFailed:
                {
                    NSLog(@"%@验证失败", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeFail;
                }
                break;
            case LAErrorUserCancel:
                {
                    NSLog(@"%@被用户手动取消", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeUserCancel;
                }
                break;
            case LAErrorUserFallback:
                {
                    NSLog(@"用户不使用%@，选择手动输入密码", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeInputPassword;
                }
                break;
            case LAErrorSystemCancel:
                {
                    NSLog(@"%@被系统取消，如遇到来电、锁屏、用户点击了Home键等", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeSystemCancel;
                }
                break;
            case LAErrorPasscodeNotSet:
                {
                    NSLog(@"%@无法启动，因为用户没有设置密码", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypePasswordNotSet;
                }
                break;
            case LAErrorTouchIDNotEnrolled:
                {
                    NSLog(@"%@无法启动，因为用户没有设置%@", biometericsTypeText, biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeTouchIDNotSet;
                }
                break;
            case LAErrorTouchIDNotAvailable:
                {
                    NSLog(@"%@无效", biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeTouchIDNotAvailable;
                }
                break;
            case LAErrorTouchIDLockout:
                {
                    NSLog(@"%@被锁定，连续多次验证%@失败，系统需要用户手动输入密码", biometericsTypeText, biometericsTypeText);
                    errorCode = LCBiometricsAuthCheckResultTypeTouchIDLockout;
                }
                break;
            case LAErrorAppCancel:
                {
                    NSLog(@"当前软件被挂起并取消了授权，如App进入了后台等");
                    errorCode = LCBiometricsAuthCheckResultTypeAppCancel;
                }
                break;
            case LAErrorInvalidContext:
                {
                    NSLog(@"当前软件被挂起并取消了授权，LAContext对象无效");
                    errorCode = LCBiometricsAuthCheckResultTypeInvalidContext;
                }
                break;
            default:
                break;
        }
    }
    NSLog(@"其他错误情况");
    LCBiometricsCheckError *checkError = [[LCBiometricsCheckError alloc] initWithDomain:error.domain originCode:error.code errorCode:errorCode userInfo:nil];
    return checkError;
}
@end
