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

#import "LCAuthManagerConstant.h"

@interface LCGestureAuthViewController : UIViewController
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

/** 辅助按钮被点击的回调，operationType：0-第一个辅助按钮被点击，1-第二个辅助按钮被点击 */
@property (nonatomic, strong) void(^assistOperationBlock)(LCGestureAuthViewController *gestureAuthViewController, LCGestureAuthViewType viewType, NSInteger operationType);

/** 取消验证并关闭手势密码控制器 */
- (void)cancelCheck;
@end
