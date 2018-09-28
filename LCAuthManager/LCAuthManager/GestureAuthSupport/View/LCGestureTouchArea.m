//
//  LCGestureTouchArea.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCGestureTouchArea.h"
#import "LCGestureAuthViewController.h"
#import "LCAuthManagerConstant.h"
#import "LCAuthManager.h"

@interface LCGestureTouchArea () {
    NSMutableArray* buttonArray;
    NSMutableArray* selectedButtonArray;
    NSMutableArray* wrongButtonArray;
    CGPoint nowPoint;
    
    NSTimer* timer;
    
    BOOL isWrongColor;
    BOOL isDrawing; // 正在画中
}
@end

@implementation LCGestureTouchArea

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
    buttonArray = [NSMutableArray array];
    selectedButtonArray = [NSMutableArray array];
    
    // 初始化圆点
    for (int i = 0; i < 9; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        int x = [LCAuthManager globalConfig].touchAreaCircleMargin + (i % 3) * ([LCAuthManager globalConfig].touchAreaCircleDiameter + ([LCAuthManager globalConfig].touchAreaWithAndHeight - [LCAuthManager globalConfig].touchAreaCircleMargin * 2 - [LCAuthManager globalConfig].touchAreaCircleDiameter * 3) / 2);
        int y = [LCAuthManager globalConfig].touchAreaCircleMargin + (i / 3) * ([LCAuthManager globalConfig].touchAreaCircleDiameter + ([LCAuthManager globalConfig].touchAreaWithAndHeight -[LCAuthManager globalConfig].touchAreaCircleMargin * 2- [LCAuthManager globalConfig].touchAreaCircleDiameter * 3) / 2);
        
        [button setFrame:CGRectMake(x, y, [LCAuthManager globalConfig].touchAreaCircleDiameter, [LCAuthManager globalConfig].touchAreaCircleDiameter)];
        
        [button setBackgroundColor:[UIColor clearColor]];
        [button setBackgroundImage:[LCAuthManager globalConfig].touchAreaButtonNormalImage forState:UIControlStateNormal];
        [button setBackgroundImage:[LCAuthManager globalConfig].touchAreaButtonActiveImage forState:UIControlStateSelected];
        button.userInteractionEnabled= NO;// 禁止用户交互
        button.alpha = [LCAuthManager globalConfig].touchAreaCircleAlpha;
        button.tag = i + [LCAuthManager globalConfig].touchAreaCircleBaseTagNumber + 1;
        [self addSubview:button];
        [buttonArray addObject:button];
    }
    
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - 事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    LCLog(@"touch began");
    isDrawing = NO;
    // 如果是错误色才重置(timer重置过了)
    if (isWrongColor) {
        [self clearColorAndSelectedButton];
    }
    CGPoint point = [[touches anyObject] locationInView:self];
    [self updateFingerPosition:point];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    isDrawing = YES;
    
    CGPoint point = [[touches anyObject] locationInView:self];
    [self updateFingerPosition:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    LCLog(@"输入密码结束");
    [self endPosition];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    LCLog(@"输入密码取消");
    [self endPosition];
}

#pragma mark - 绘制连线
- (void)drawRect:(CGRect)rect {
    LCLog(@"drawRect - %@", [NSString stringWithFormat:@"%d", isWrongColor]);
    
    if (selectedButtonArray.count > 0) {
        // 正误线条色
        isWrongColor ? [[LCAuthManager globalConfig].touchAreaLineColorWrong set] : [[LCAuthManager globalConfig].touchAreaLineColor set];
        
        //设置上下文属性
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        //新建路径：管理线条
        CGMutablePathRef pathM = CGPathCreateMutable();
        
        //线条转角样式
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        
        //设置线宽
        CGContextSetLineWidth(ctx, [LCAuthManager globalConfig].touchAreaLineWidth);
        
        //遍历所有的itemView
        [selectedButtonArray enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGPoint point = CGPointMake(button.center.x, button.center.y);
            
            // 画中心圆
            CGRect circleRect = CGRectMake(button.center.x- [LCAuthManager globalConfig].touchAreaLineWidth/2,
                                           button.center.y - [LCAuthManager globalConfig].touchAreaLineWidth/2,
                                           [LCAuthManager globalConfig].touchAreaLineWidth,
                                           [LCAuthManager globalConfig].touchAreaLineWidth);
            CGContextSetFillColorWithColor(ctx, [LCAuthManager globalConfig].touchAreaLineColor.CGColor);
            CGContextFillEllipseInRect(ctx, circleRect);
            
            if(idx == 0) {//第一个
                
                //添加起点
                CGPathMoveToPoint(pathM, NULL, point.x, point.y);
                
            } else {//其他
                
                //添加路径线条
                CGPathAddLineToPoint(pathM, NULL, point.x, point.y);
                
            }
            
        }];
        
        //将路径添加到上下文
        CGContextAddPath(ctx, pathM);
        
        //渲染路径
        CGContextStrokePath(ctx);
        
        //释放路径
        CGPathRelease(pathM);
        
        if (isDrawing) {
            // 画当前线
            UIButton *lastButton = selectedButtonArray.lastObject;
            CGContextMoveToPoint(ctx, lastButton.center.x, lastButton.center.y);
            CGContextAddLineToPoint(ctx, nowPoint.x, nowPoint.y);
            CGContextStrokePath(ctx);
            
        }
    }
    
}

#pragma mark - 处理
// 当前手指位置
- (void)updateFingerPosition:(CGPoint)point {
    
    nowPoint = point;
    
    for (UIButton *thisbutton in buttonArray) {
        
        CGFloat xDiff = point.x - thisbutton.center.x;
        CGFloat yDiff = point.y - thisbutton.center.y;
        
        if (fabs(xDiff) < 36 && fabs (yDiff) < 36) {
            // 未选中的才能加入
            if (!thisbutton.selected) {
                thisbutton.selected = YES;
                [selectedButtonArray  addObject:thisbutton];
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)endPosition {
    isDrawing = NO;
    // 重绘，可以清除最后多余的线
    [self setNeedsDisplay];
    
    UIButton *strbutton;
    NSString *string = @"";
    
    // 生成密码串
    for (int i = 0; i < selectedButtonArray.count; i++) {
        strbutton = selectedButtonArray[i];
        string = [string stringByAppendingFormat:@"%d",strbutton.tag - [LCAuthManager globalConfig].touchAreaCircleBaseTagNumber];
    }
    
    // 清除到初始样式
    [self performSelector:@selector(clearColorAndSelectedButton) withObject:nil afterDelay:0.8];
    
    if ([self.delegate respondsToSelector:@selector(lockString:)]) {
        
        if (string && string.length>0) {
            
            [self.delegate lockString:string];
            
        }
    }
    
    LCLog(@"end Position");
    
}

// 清除至初始状态
- (void)clearColor {
    if (isWrongColor) {
        LCLog(@"clearColorAndSelectedButton");
        // 重置颜色
        isWrongColor = NO;
        for (UIButton* button in buttonArray) {
            [button setBackgroundImage:[LCAuthManager globalConfig].touchAreaButtonActiveImage forState:UIControlStateSelected];
        }
        
    }
}

- (void)clearSelectedButton {
    // 换到下次按时再弄
    for (UIButton *thisButton in buttonArray) {
        [thisButton setSelected:NO];
    }
    [selectedButtonArray removeAllObjects];
    
    [self setNeedsDisplay];
}

- (void)clearColorAndSelectedButton {
    if (!isDrawing) {
        
        [self clearColor];
        [self clearSelectedButton];
        
    }
}

#pragma mark - 生成密码
-(void)addstring {
    
}

#pragma mark - 显示错误
- (void)showErrorCircles:(NSString*)string {
    LCLog(@"ShowError");

    isWrongColor = YES;
    
    // 清空数组（不清空会导致重复绘制闭合线段）
    [selectedButtonArray removeAllObjects];
    
    NSMutableArray* numbers = [[NSMutableArray alloc] initWithCapacity:string.length];
    for (int i = 0; i < string.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSNumber* number = [NSNumber numberWithInt:[string substringWithRange:range].intValue-1]; // 数字是1开始的
        [numbers addObject:number];
        [buttonArray[number.intValue] setSelected:YES];
        
        [selectedButtonArray addObject:buttonArray[number.intValue]];
    }
    
    for (UIButton* button in buttonArray) {
        if (button.selected) {
            [button setBackgroundImage:[LCAuthManager globalConfig].touchAreaButtonErrorImage forState:UIControlStateSelected];
        }
        
    }
    
    [self setNeedsDisplay];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(clearColorAndSelectedButton)
                                           userInfo:nil
                                            repeats:NO];
    
}
@end
