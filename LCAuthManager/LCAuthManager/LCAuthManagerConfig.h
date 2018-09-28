//
//  LCAuthManagerConfig.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCAuthManager.h"

@interface LCAuthManagerConfig : NSObject
/** 本地持久化的字典名称 */
@property (nonatomic, strong) NSString *persistenceName;

/** 代理 */
@property (nonatomic, weak) id<LCAuthManagerDelegate> delegate;

/**
 * 是否自己处理凭证的保存
 *
 * 该框架中，凭证的存储是直接存储在用户配置中的，且是明文存储，
 * 所以并不建议将直接用于安全性要求较高的环境中，
 * 用户可以通过将该选项置为YES，并实现规定的代理方法，自己处理凭证的存储，
 * 框架将自动使用代理方法进行凭证的读取和持久化
 */
@property (nonatomic, assign) BOOL keepAuthentication;

#pragma mark - 手势密码相关配置
#pragma mark 密码配置
/** 手势密码最短长度 */
@property (nonatomic, assign) NSInteger gesturePasswordMinLength;
/** 最大重试次数 */
@property (nonatomic, assign) NSInteger maxGestureRetryTimes;

#pragma mark 样式配置
/** 正常时提示文字的颜色 */
@property (nonatomic, strong) UIColor *normalTipColor;
/** 出错时提示文字的颜色 */
@property (nonatomic, strong) UIColor *errorTipColor;

#pragma mark 指示器相关
/** 指示器tag基数（请勿修改） */
@property (nonatomic, assign) NSInteger indicatorCircleBaseTagNumber;
/** 指示器圆点直径 */
@property (nonatomic, assign) CGFloat indicatorCircleDiameter;
/** 指示器圆点间距 */
@property (nonatomic, assign) CGFloat indicatorCircleMargin;
/** 指示器自动清除圆点状态的间隔时间 */
@property (nonatomic, assign) NSTimeInterval indicatorAutoResetStatesTime;
/** 指示器圆点边框宽度 */
@property (nonatomic, assign) CGFloat indicatorCircleBorderWidth;
/** 指示器正常情况下的圆点背景色 */
@property (nonatomic, strong) UIColor *indicatorCircleNormalBgColor;
/** 指示器正常情况下的圆点边框色 */
@property (nonatomic, strong) UIColor *indicatorCircleNormalBorderColor;
/** 指示器激活情况下的圆点背景色 */
@property (nonatomic, strong) UIColor *indicatorCircleActiveBgColor;
/** 指示器激活情况下的圆点边框色 */
@property (nonatomic, strong) UIColor *indicatorCircleActiveBorderColor;

#pragma mark 解锁区域相关
/** 解锁区域长宽 */
@property (nonatomic, assign) CGFloat touchAreaWithAndHeight;
/** 解锁区域触点tag基数（请勿修改） */
@property (nonatomic, assign) NSInteger touchAreaCircleBaseTagNumber;
/** 解锁区域触点离屏幕左边距 */
@property (nonatomic, assign) CGFloat touchAreaCircleMargin;
/** 解锁区域触点直径 */
@property (nonatomic, assign) CGFloat touchAreaCircleDiameter;
/** 解锁区域触点透明度 */
@property (nonatomic, assign) CGFloat touchAreaCircleAlpha;
/** 解锁区域触点按钮正常时的图片 */
@property (nonatomic, strong) UIImage *touchAreaButtonNormalImage;
/** 解锁区域触点按钮激活时的图片 */
@property (nonatomic, strong) UIImage *touchAreaButtonActiveImage;
/** 解锁区域触点按钮错误时的图片 */
@property (nonatomic, strong) UIImage *touchAreaButtonErrorImage;/** 解锁区域线条宽 */
@property (nonatomic, assign) CGFloat touchAreaLineWidth;
/** 解锁区域线条正常颜色 */
@property (nonatomic, strong) UIColor *touchAreaLineColor;
/** 解锁区域线条错误颜色 */
@property (nonatomic, strong) UIColor *touchAreaLineColorWrong;
/** 关闭手势密码按钮的图片 */
@property (nonatomic, strong) UIImage *closeGestureAuthButtonImage;

#pragma mark - 生物识别相关
/** 生物识别最大次数 */
@property (nonatomic, assign) NSUInteger maxBiometryFailures;
@end
