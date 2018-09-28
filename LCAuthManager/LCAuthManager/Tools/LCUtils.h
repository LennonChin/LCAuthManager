//
//  LCUtils.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/28.
//  Copyright © 2018 coderap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCUtils : NSObject
/** 判断是否是全面屏 */
+ (BOOL)isZeroBezel;
/** 判断是否是ipad */
+ (BOOL)isIPad;
/** 判断iPhone4系列 */
+ (BOOL)isIPhone4;
/** 判断iPhone5系列 */
+ (BOOL)isIPhone5;
/** 判断iPhone6系列 */
+ (BOOL)isIPhone6;
/** 判断iphone6+系列 */
+ (BOOL)isIPhone6Plus;
/** 判断iPhoneX */
+ (BOOL)isIPhoneX;
/** 判断iPHoneXr */
+ (BOOL)isIPhoneXr;
/** 判断iPhoneXs */
+ (BOOL)isIPhoneXs;
/** 判断iPhoneXs Max */
+ (BOOL)isIPhoneXsMax;

/** 根据不同屏幕返回不同的值 */
+ (CGFloat)valueForDifferentSizeS_3_5:(CGFloat)S_3_5
                                S_4_0:(CGFloat)S_4_0
                                S_4_7:(CGFloat)S_4_7
                                S_5_5:(CGFloat)S_5_5
                                S_5_8:(CGFloat)S_5_8
                                S_6_1:(CGFloat)S_6_1
                                S_6_5:(CGFloat)S_6_5;
@end
