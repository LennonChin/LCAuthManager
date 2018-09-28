//
//  LCGestureAuthViewController.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//
//  解锁控件头文件，使用时包含它即可

//#define LCGestureAuthAnimationOn  // 开启窗口动画，注释此行即可关闭

#import <UIKit/UIKit.h>

#import "LCGestureAuthPassword.h"
#import "LCGestureTouchArea.h"
@class LCGestureAuthViewController;

/**
 * 进入此界面时的不同目的
 */
typedef enum {
    LCGestureAuthViewTypeCheck,     // 检查手势密码
    LCGestureAuthViewTypeCreate,    // 创建手势密码
    LCGestureAuthViewTypeModify,    // 修改
    LCGestureAuthViewTypeClean,     // 清除
    LCGestureAuthViewTypeUnknown,   // 其他未知
} LCGestureAuthViewType;

typedef enum {
    LCGestureAuthViewCheckResultSuccess,  // 验证成功
    LCGestureAuthViewCheckResultFailed,    // 验证失败
    LCGestureAuthViewCheckResultCancel    // 验证取消
} LCGestureAuthCheckResultType;

@protocol LCGestureAuthCheckDelegate <NSObject>
@optional
/** 针对某种验证的验证结果 */
- (void)checkState:(LCGestureAuthCheckResultType)checkResultType viewType:(LCGestureAuthViewType)viewType;
/** 达到最大次数代理方法 */
- (void)reachMaxRetryTimesWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType;
/** 忘记手势密码的回调 */
- (void)forgetPasswordWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType;
/** 使用其他账户登录的回调 */
- (void)useOtherAcountLoginWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType;
@end

@interface LCGestureAuthViewController : UIViewController
@property (nonatomic, assign) id<LCGestureAuthCheckDelegate> delegate;
/**
 * 打开此窗口的类型
 */
@property (nonatomic, assign) LCGestureAuthViewType lockViewType;
/**
 * 直接指定方式打开
 */
- (id)initWithType:(LCGestureAuthViewType)type;

/** 达到最大次数的Block回调 */
@property (nonatomic, strong) void(^reachMaxRetryTimesBlock)(LCGestureAuthViewController *gestureAuthViewController, LCGestureAuthViewType viewType);

/** 忘记手势密码的回调 */
@property (nonatomic, strong) void(^forgetPasswordBlock)(LCGestureAuthViewController *gestureAuthViewController, LCGestureAuthViewType viewType);

/** 使用其他账户登录的回调 */
@property (nonatomic, strong) void(^useOtherAcountLoginBlock)(LCGestureAuthViewController *gestureAuthViewController, LCGestureAuthViewType viewType);

/** 取消验证并关闭手势密码控制器 */
- (void)cancelCheck;

/** 直接调用忘记手势密码 */
- (void)directlyforgotPassword;
/** 直接调用使用其他账户登录 */
- (void)directlyUseOtherAcountLogin;
@end
