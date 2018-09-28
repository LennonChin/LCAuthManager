//
//  LCGestureAuthIndicator.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCGestureAuthIndicator.h"
#import "LCAuthManagerConfig.h"
#import "LCAuthManagerConstant.h"
#import "LCAuthManager.h"

@interface LCGestureAuthIndicator ()
@property (nonatomic, strong) NSMutableArray* buttonArray;
@end

@implementation LCGestureAuthIndicator

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        [self initCircles];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.clipsToBounds = YES;
        [self initCircles];
    }
    return self;
}

- (void)initCircles {
    
    self.buttonArray = [NSMutableArray array];
    
    // 初始化圆点
    for (int i = 0; i < 9; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        int x = (i % 3) * ([LCAuthManager globalConfig].indicatorCircleDiameter + [LCAuthManager globalConfig].indicatorCircleMargin);
        int y = (i / 3) * ([LCAuthManager globalConfig].indicatorCircleDiameter + [LCAuthManager globalConfig].indicatorCircleMargin);
        LCLog(@"每个圆点位置: (%d, %d)", x, y);
        [button setFrame:CGRectMake(x, y, [LCAuthManager globalConfig].indicatorCircleDiameter, [LCAuthManager globalConfig].indicatorCircleDiameter)];
        
        [button setBackgroundColor:[LCAuthManager globalConfig].indicatorCircleNormalBgColor];
        button.layer.cornerRadius = [LCAuthManager globalConfig].indicatorCircleDiameter * 0.5;
        button.layer.borderColor = [LCAuthManager globalConfig].indicatorCircleNormalBorderColor.CGColor;
        button.layer.borderWidth = [LCAuthManager globalConfig].indicatorCircleBorderWidth;
        
        button.userInteractionEnabled = NO;// 禁止用户交互
        button.tag = i + [LCAuthManager globalConfig].indicatorCircleBaseTagNumber + 1; // tag从基数+1开始,
        [self addSubview:button];
        [self.buttonArray addObject:button];
    }
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setPasswordString:(NSString*)string {
    
    [self resetButtonsState];
    
    NSMutableArray* numbers = [[NSMutableArray alloc] initWithCapacity:string.length];
    
    for (int i = 0; i < string.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSNumber* number = [NSNumber numberWithInt:[string substringWithRange:range].intValue-1]; // 数字是1开始的
        [numbers addObject:number];
        UIButton *button = self.buttonArray[number.intValue];
        [button setBackgroundColor:[LCAuthManager globalConfig].indicatorCircleActiveBgColor];
        button.layer.cornerRadius = [LCAuthManager globalConfig].indicatorCircleDiameter * 0.5;
        button.layer.borderColor = [LCAuthManager globalConfig].indicatorCircleActiveBorderColor.CGColor;
        button.layer.borderWidth = [LCAuthManager globalConfig].indicatorCircleBorderWidth;
    }
    
    // 自动清除圆点状态
    [self performSelector:@selector(resetButtonsState) withObject:nil afterDelay:[LCAuthManager globalConfig].indicatorAutoResetStatesTime];
    
}

- (void)resetButtonsState {
    
    for (UIButton* button in self.buttonArray) {
        
        [button setBackgroundColor:[LCAuthManager globalConfig].indicatorCircleNormalBgColor];
        button.layer.cornerRadius = [LCAuthManager globalConfig].indicatorCircleDiameter * 0.5;
        button.layer.borderColor = [LCAuthManager globalConfig].indicatorCircleNormalBorderColor.CGColor;
        button.layer.borderWidth = [LCAuthManager globalConfig].indicatorCircleBorderWidth;
    }
}

@end
