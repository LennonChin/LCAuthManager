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
#import "LCBiometricsCheckError.h"
@class LCAuthManagerConfig;

@protocol LCAuthManagerDelegate <NSObject>

@optional
#pragma mark - 手势密码相关
/** 手势密码相关，针对某种验证的验证结果 */
- (void)gestureCheckState:(LCGestureAuthCheckResultType)checkResultType viewType:(LCGestureAuthViewType)viewType;
/** 手势密码相关，达到最大次数代理方法 */
- (void)gestureRetryReachMaxTimesWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType;
/** 辅助操作相关，operationType：0-第一个辅助按钮被点击，1-第二个辅助按钮被点击 */
- (void)assistOperationWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType operationType:(NSInteger)operationType;

#pragma mark - 生物识别相关
/** 生物识别相关，针对某种验证的验证结果 */
- (void)biometricsCheckState:(LCBiometricsAuthCheckResultType)checkResultType biometricsType:(LCBiometricsType)biometricsType error:(LCBiometricsCheckError *)error;

#pragma mark - 密码持久化相关
/** 查看是否设置了生物识别 */
- (BOOL)isBiometricsAuthOpened:(LCBiometricsType)biometricsType;
/** 生物识别相关，持久化生物识别的开启状态 */
- (BOOL)persistBiometricsAuth:(LCBiometricsType)biometricsType isOn:(BOOL)isOn;
/** 查看是否设置了手势密码 */
- (BOOL)isGestureAuthOpened;
/** 手势密码相关，持久化手势密码 */
- (BOOL)persistGestureAuth:(NSString *)password;
/** 加载手势密码 */
- (NSString *)loadGestureAuth;
@end

@interface LCAuthManager : NSObject
#pragma mark - 配置
+ (void)setGlobalConfig:(LCAuthManagerConfig *)globalConfig;
+ (LCAuthManagerConfig *)globalConfig;

+ (void)setDelegate:(id<LCAuthManagerDelegate>)delegate;
+ (id<LCAuthManagerDelegate>)delegate;

/**
 暂时关闭验证
 适用于如对外分享内容后返回App，此时应该暂时不用验证

 @param timeout 超时时间，单位：秒
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
+ (LCGestureAuthViewController *)showGestureAuthViewControllerWithType:(LCGestureAuthViewType)lockViewType hostViewControllerView:(UIViewController *)hostViewController delegate:(id<LCAuthManagerDelegate>)delegate;

/** 主动触发辅助按钮的操作 */
+ (void)directlyTriggerAssistOperation:(NSInteger)operationType;

#pragma mark - 生物识别相关
/** 是否支持生物识别 */
+ (LCBiometricsType)isSupportBiometricsAuth;

/** 查看是否设置了生物识别 */
+ (BOOL)isBiometricsAuthOpened:(LCBiometricsType)biometricsType;
/** 生物识别相关，持久化生物识别的开启状态 */
+ (BOOL)persistBiometricsAuth:(LCBiometricsType)biometricsType isOn:(BOOL)isOn;

/**
 使用生物识别验证
 
 @param reason 显示的理由
 @param fallbackTitle 验证出错后的右边按钮
 @param successBlock 成功回调Block
 @param failBlock 失败回调Block
 @param fallbackBlock 当生物识别达到最大次数时，会出现弹框，点击右侧按钮会调用该Block
 */
+ (void)verifyBiometricsAuthWithReason:(NSString *)reason
                         fallbackTitle:(NSString *)fallbackTitle
                               Success:(void (^)(LCBiometricsAuthCheckResultType checkResultType))successBlock
                                  Fail:(void (^)(LCBiometricsAuthCheckResultType checkResultType, NSError *error))failBlock
                              Fallback:(void (^)(LCBiometricsAuthCheckResultType checkResultType, NSError *error))fallbackBlock
                              delegate:(id<LCAuthManagerDelegate>)delegate;

@end
