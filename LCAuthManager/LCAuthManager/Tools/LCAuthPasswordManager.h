//
//  LCAuthPasswordManager.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//
//  密码保存模块

#import <Foundation/Foundation.h>
#import "LCAuthManagerConfig.h"

@interface LCAuthPasswordManager : NSObject
#pragma mark - 手势密码相关
/** 加载手势密码 */
+ (NSString *)loadGesturePassword;
/** 持久化手势密码 */
+ (BOOL)persistGesturePassword:(NSString *)password;

#pragma mark - 生物识别相关
/** 查看是否设置了生物识别 */
+ (BOOL)isBiometricsAuthOpened:(LCBiometricsType)biometricsType;
/** 生物识别相关，持久化生物识别的开启状态 */
+ (BOOL)persistBiometricsAuth:(LCBiometricsType)biometricsType isOn:(BOOL)isOn;

#pragma mark - 辅助方法
+ (BOOL)persistenceValue:(NSObject *)value forKey:(NSString *)key;
+ (NSObject *)getPersistenceValueForKey:(NSString *)key;
@end
