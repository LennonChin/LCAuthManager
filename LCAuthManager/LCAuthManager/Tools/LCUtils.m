//
//  LCUtils.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/28.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCUtils.h"
#import "LCAuthManagerConstant.h"

@implementation LCUtils
+ (BOOL)isZeroBezel {
    if (@available(iOS 11.0, *)) {
        return !UIEdgeInsetsEqualToEdgeInsets([UIApplication sharedApplication].windows.firstObject.safeAreaInsets, UIEdgeInsetsZero);
    }
    return NO;
}

+ (BOOL)isIPad {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

+ (BOOL)isIPhone4 {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) && ![self isIPad] : NO);
}

+ (BOOL)isIPhone5  {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) && ![self isIPad] : NO);
}

+ (BOOL)isIPhone6  {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) && ![self isIPad] : NO);
}

+ (BOOL)isIPhone6Plus  {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) && ![self isIPad] : NO);
}

+ (BOOL)isIPhoneX  {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && ![self isIPad] : NO);
}

+ (BOOL)isIPhoneXr  {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && ![self isIPad] : NO);
}

+ (BOOL)isIPhoneXs  {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && ![self isIPad] : NO);
}

+ (BOOL)isIPhoneXsMax  {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && ![self isIPad] : NO);
}

+ (CGFloat)valueForDifferentSizeS_3_5:(CGFloat)S_3_5
                                S_4_0:(CGFloat)S_4_0
                                S_4_7:(CGFloat)S_4_7
                                S_5_5:(CGFloat)S_5_5
                                S_5_8:(CGFloat)S_5_8
                                S_6_1:(CGFloat)S_6_1
                                S_6_5:(CGFloat)S_6_5 {
    
    if ([self isIPhone4]) {
        LCLog(@"3.5寸");
        return S_3_5;
    }
    
    if ([self isIPhone5]) {
        LCLog(@"4.0寸");
        return S_4_0;
    }
    
    if ([self isIPhone6]) {
        LCLog(@"4.7寸");
        return S_4_7;
    }
    
    if ([self isIPhone6Plus]) {
        LCLog(@"5.5寸");
        return S_5_5;
    }
    
    if ([self isIPhoneX] || [self isIPhoneXs]) {
        LCLog(@"5.8寸");
        return S_5_8;
    }
    
    if ([self isIPhoneXr]) {
        LCLog(@"6.1寸");
        return S_6_1;
    }
    
    if ([self isIPhoneXsMax]) {
        LCLog(@"6.5寸");
        return S_6_5;
    }
    return 0.0;
}
@end
