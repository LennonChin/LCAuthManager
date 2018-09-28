//
//  LCAuthManagerConstant.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#ifndef LCAuthManagerConstant_h
#define LCAuthManagerConstant_h

#ifdef DEBUG
#define LCLog(format, ...) NSLog((@"%s[%d]:" format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define LCLog(format, ...) /* */
#endif

// 判断系统版本是否大于等于8.0
#define IOS_VERSION_8_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)? (YES):(NO))

// 判断系统版本是否大于等于9.0
#define IOS_VERSION_9_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)? (YES):(NO))

// 屏幕尺寸
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

#endif /* LCAuthManagerConstant_h */

/**
 * 进入手势密码界面时的不同目的
 */
typedef NS_ENUM(NSUInteger, LCGestureAuthViewType) {
    LCGestureAuthViewTypeCheck,     // 检查手势密码
    LCGestureAuthViewTypeCreate,    // 创建手势密码
    LCGestureAuthViewTypeModify,    // 修改
    LCGestureAuthViewTypeClean,     // 清除
    LCGestureAuthViewTypeUnknown,   // 其他未知
};

/**
 * 手势密码验证结果
 */
typedef NS_ENUM(NSUInteger, LCGestureAuthCheckResultType) {
    LCGestureAuthViewCheckResultSuccess,    // 验证成功
    LCGestureAuthViewCheckResultFailed,     // 验证失败
    LCGestureAuthViewCheckResultCancel      // 验证取消
};

/**
 * 生物识别可用类型
 */
typedef NS_ENUM(NSUInteger, LCBiometricsType) {
    LCBiometricsTypeNone = 0,           // 不支持
    LCBiometricsTypeTouchID = 1,        // Touch ID
    LCBiometricsTypeFaceID = 2,         // Face ID
    LCBiometricsTypeUnknown = 3,        // 未知，主要用于检测
};

/**
 * 生物识别验证结果
 */
typedef NS_ENUM(NSUInteger, LCBiometricsAuthCheckResultType) {
    /**
     * 当前设备不支持Biometrics Authentication
     */
    LCBiometricsAuthCheckResultTypeNotSupport = 0,
    /**
     * Biometrics Authentication验证成功
     */
    LCBiometricsAuthCheckResultTypeSuccess = 1,
    
    /**
     * Biometrics Authentication验证失败
     */
    LCBiometricsAuthCheckResultTypeFail = 2,
    /**
     * Biometrics Authentication被用户手动取消
     */
    LCBiometricsAuthCheckResultTypeUserCancel = 3,
    /**
     * 用户不使用Biometrics Authentication，选择手动输入密码
     */
    LCBiometricsAuthCheckResultTypeInputPassword = 4,
    /**
     * Biometrics Authentication被系统取消
     * 如遇到来电、锁屏、按了Home键等
     */
    LCBiometricsAuthCheckResultTypeSystemCancel = 5,
    /**
     * Biometrics Authentication无法启动
     * 因为用户没有设置密码
     */
    LCBiometricsAuthCheckResultTypePasswordNotSet = 6,
    /**
     * Biometrics Authentication无法启动
     * 因为用户没有设置Biometrics Authentication
     */
    LCBiometricsAuthCheckResultTypeTouchIDNotSet = 7,
    /**
     * Biometrics Authentication无效
     */
    LCBiometricsAuthCheckResultTypeTouchIDNotAvailable = 8,
    /**
     * Biometrics Authentication被锁定
     * 连续多次验证Biometrics Authentication失败，系统需要用户手动输入密码
     */
    LCBiometricsAuthCheckResultTypeTouchIDLockout = 9,
    /**
     * 当前软件被挂起并取消了授权
     * 如App进入了后台等
     */
    LCBiometricsAuthCheckResultTypeAppCancel = 10,
    /**
     * 当前软件被挂起并取消了授权
     * LAContext对象无效
     */
    LCBiometricsAuthCheckResultTypeInvalidContext = 11,
    /**
     * 系统版本不支持Biometrics Authentication
     * 必须高于iOS 8.0才能使用
     */
    LCBiometricsAuthCheckResultTypeVersionNotSupport = 12,
    /**
     * 其他结果
     */
    LCBiometricsAuthCheckResultTypeUnknown = 13
};


