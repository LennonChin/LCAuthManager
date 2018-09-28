//
//  LCUtils.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/28.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCUtils.h"

@implementation LCUtils

+ (BOOL)isZeroBezel {
    if (@available(iOS 11.0, *)) {
        return !UIEdgeInsetsEqualToEdgeInsets([UIApplication sharedApplication].windows.firstObject.safeAreaInsets, UIEdgeInsetsZero);
    }
    return NO;
}
@end
