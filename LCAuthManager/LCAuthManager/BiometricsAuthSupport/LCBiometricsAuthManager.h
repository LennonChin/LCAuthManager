//
//  LCBiometricsAuthManager.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>
@class LCAuthManagerConfig;

typedef NS_ENUM(NSUInteger, BiometricsType) {
    BiometricsTypeNone = 0,         // 不支持
    BiometricsTypeTouchID = 1,      // Touch ID
    BiometricsTypeFaceID = 2,       // Face ID
};

@interface LCBiometricsAuthManager : NSObject

/** 是否支持生物识别 */
+ (BiometricsType)isSupportBiometricsAuth;

/** 更新生物识别持久化 */
+ (void)setBiometricsAuthPersistence:(BOOL)isOn;

/** 查看是否设置了生物识别 */
+ (BOOL)isBiometricsAuthOpened;

/**
 使用生物识别验证

 @param reason 显示的理由
 @param fallbackTitle 验证出错后的右边按钮
 @param successBlock 成功回调Block
 @param failBlock 失败回调Block
 @param fallbackBlock 当生物识别达到最大次数时，会出现弹框，点击右fallbackBlock会调用该Block
 */
+ (void)verifyBiometricsAuthWithReason:(NSString *)reason fallbackTitle:(NSString *)fallbackTitle Success:(void (^)(void))successBlock Fail:(void (^)(NSError *error, LAError errorCode))failBlock Fallback:(void (^)(NSError *error, LAError errorCode))fallbackBlock;

@end
