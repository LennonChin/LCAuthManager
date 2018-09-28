//
//  LCBiometricsAuthManager.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "LCAuthManagerConstant.h"

@interface LCBiometricsAuthManager : NSObject

/** 是否支持生物识别 */
+ (LCBiometricsType)isSupportBiometricsAuth;

/** 更新生物识别持久化 */
+ (BOOL)persistBiometricsAuth:(LCBiometricsType)biometricsType isOn:(BOOL)isOn;

/** 查看是否设置了生物识别 */
+ (BOOL)isBiometricsAuthOpened:(LCBiometricsType)biometricsType;

/**
 使用生物识别验证

 @param reason 显示的理由
 @param fallbackTitle 验证出错后的右边按钮
 @param successBlock 成功回调Block
 @param failBlock 失败回调Block
 @param fallbackBlock 当生物识别达到最大次数时，会出现弹框，点击右fallbackBlock会调用该Block
 */
+ (void)verifyBiometricsAuthWithReason:(NSString *)reason
                         fallbackTitle:(NSString *)fallbackTitle
                               Success:(void (^)(LCBiometricsAuthCheckResultType checkResultType))successBlock
                                  Fail:(void (^)(LCBiometricsAuthCheckResultType checkResultType, NSError *error))failBlock
                              Fallback:(void (^)(LCBiometricsAuthCheckResultType checkResultType, NSError *error))fallbackBlock;

@end
