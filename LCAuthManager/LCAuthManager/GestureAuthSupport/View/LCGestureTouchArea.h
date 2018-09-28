//
//  LCGestureTouchArea.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//
//  九宫格手势解锁控件

#import <UIKit/UIKit.h>
#import "LCAuthManagerConfig.h"

@protocol LCGestureTouchAreaDelegate <NSObject>
@required
- (void)lockString:(NSString *)string;
@end

@interface LCGestureTouchArea : UIView
@property (nonatomic, weak) id<LCGestureTouchAreaDelegate> delegate;
/** 设置错误的密码以高亮 */
- (void)showErrorCircles:(NSString *)string;
/** 重置 */
- (void)clearColorAndSelectedButton;
@end
