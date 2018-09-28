//
//  LCAuthManager.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCBiometricsAuthManager.h"
#import "LCGestureAuthViewController.h"

@interface LCAuthManager : NSObject
#pragma mark - 配置
+ (void)setGlobalConfig:(LCAuthManagerConfig *)globalConfig;
+ (LCAuthManagerConfig *)globalConfig;

/**
 暂时关闭验证
 适用于如对外分享内容后返回App，此时应该暂时不用验证

 @param timeout 超时时间
 */
+ (void)setCloseAuthTemporary:(NSTimeInterval)timeout;

#pragma mark - 手势密码相关
/** 查看是否设置了手势密码识别 */
+ (BOOL)isGestureAuthOpened;


/**
 显示手势密码控制器

 @param lockViewType 操作类型
 @param hostViewController 用于present操作的控制器
 @param delegate 代理
 @return 手势密码控制器
 */
+ (LCGestureAuthViewController *)showGestureAuthViewControllerWithType:(LCGestureAuthViewType)lockViewType hostViewControllerView:(UIViewController *)hostViewController delegate:(id<LCGestureAuthCheckDelegate>)delegate;

#pragma mark - 生物识别相关
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
 @param fallback 当生物识别达到最大次数时，会出现弹框，点击右侧按钮会调用该Block
 */
+ (void)verifyBiometricsAuthWithReason:(NSString *)reason fallbackTitle:(NSString *)fallbackTitle Success:(void (^)(void))successBlock Fail:(void (^)(NSError *error, LAError errorCode))failBlock Fallback:(void (^)(NSError *error, LAError errorCode))fallback;

@end
