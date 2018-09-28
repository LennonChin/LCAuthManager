//
//  LCGestureAuthViewController.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCGestureAuthViewController.h"
#import "LCGestureAuthIndicator.h"
#import "LCGestureTouchArea.h"
#import "LCAuthPasswordManager.h"
#import "LCAuthManagerConstant.h"
#import "LCAuthManager.h"
#import "LCUtils.h"

@interface LCGestureAuthViewController ()<LCGestureTouchAreaDelegate>

/** 剩余几次输入机会 */
@property(nonatomic, assign) NSInteger remainderRetryTimes;

@property (weak, nonatomic) IBOutlet UIImageView *preSnapImageView; // 上一界面截图
@property (weak, nonatomic) IBOutlet UIImageView *currentSnapImageView; // 当前界面截图
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopCons;

// 标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
// 九点指示图
@property (nonatomic, strong) IBOutlet LCGestureAuthIndicator* indicatorView;
// 触摸田字控件
@property (nonatomic, strong) IBOutlet LCGestureTouchArea *touchAreaView;

// 提示语
@property (strong, nonatomic) IBOutlet UILabel *tipLablel;

@property (strong, nonatomic) IBOutlet UIButton *tipButton; // 重设/（取消）的提示按钮

@property (nonatomic, strong) NSString* savedPassword; // 本地存储的密码
@property (nonatomic, strong) NSString* passwordOld; // 旧密码
@property (nonatomic, strong) NSString* passwordNew; // 新密码
@property (nonatomic, strong) NSString* passwordconfirm; // 确认密码

// 三步提示语
@property (nonatomic, strong) NSString* tip1;
@property (nonatomic, strong) NSString* tip2;
@property (nonatomic, strong) NSString* tip3;

// 约束，用于适配小屏
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeButtonTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *touchAreaCenterYCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherOperateBottomCons;

@property (weak, nonatomic) IBOutlet UIButton *useBiometricsAuthButton;
@property (weak, nonatomic) IBOutlet UILabel *useBiometricsAuthLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIButton *firstAssistButton;
@property (weak, nonatomic) IBOutlet UIButton *secondAssistButton;
@property (weak, nonatomic) IBOutlet UIView *assistOperationsdivideLine;

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@end

@implementation LCGestureAuthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)initWithType:(LCGestureAuthViewType)type {
    self = [super init];
    if (self) {
        _lockViewType = type;
    }
    return self;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _closeButtonTopCons.constant = [LCUtils isZeroBezel] ? 45 : 30;
    
    self.view.backgroundColor = [LCAuthManager globalConfig].gestrueVCbackgroundColor;
    self.backgroundImageView.image = [LCAuthManager globalConfig].gestrueVCBackgroundImage;
    [self.closeBtn setImage:[LCAuthManager globalConfig].closeGestureAuthButtonImage forState:UIControlStateNormal];
    
    // 设置是否开启生物识别验证辅助
    self.useBiometricsAuthButton.hidden = YES;
    self.useBiometricsAuthLabel.hidden = YES;
    if ([LCAuthManager globalConfig].useBiometricsAuthAssist) {
        if ([LCAuthManager isSupportBiometricsAuth] == LCBiometricsTypeTouchID) {
            self.useBiometricsAuthButton.hidden = NO;
            self.useBiometricsAuthLabel.hidden = NO;
            [self.useBiometricsAuthButton setImage:[UIImage imageNamed:@"LCAuthManager.bundle/touch_id"] forState:UIControlStateNormal];
            [self.useBiometricsAuthLabel setText:@"使用指纹验证"];
        } else if ([LCAuthManager isSupportBiometricsAuth] == LCBiometricsTypeFaceID) {
            self.useBiometricsAuthButton.hidden = NO;
            self.useBiometricsAuthLabel.hidden = NO;
            [self.useBiometricsAuthButton setImage:[UIImage imageNamed:@"LCAuthManager.bundle/face_id"] forState:UIControlStateNormal];
            [self.useBiometricsAuthLabel setText:@"使用面容验证"];
        }
    }
    
    // 辅助操作
    if ([LCAuthManager globalConfig].useAssistOperations) {
        self.firstAssistButton.hidden = NO;
        self.secondAssistButton.hidden = NO;
        self.assistOperationsdivideLine.hidden = NO;
        [self.firstAssistButton setTitle:[LCAuthManager globalConfig].firstAssistButtonTitle forState:UIControlStateNormal];
        [self.secondAssistButton setTitle:[LCAuthManager globalConfig].secondAssistButtonTitle forState:UIControlStateNormal];
    } else {
        self.firstAssistButton.hidden = YES;
        self.secondAssistButton.hidden = YES;
        self.assistOperationsdivideLine.hidden = YES;
    }
    
    // 指示器和触摸区域
    self.indicatorView.backgroundColor = [UIColor clearColor];
    self.touchAreaView.backgroundColor = [UIColor clearColor];
    self.touchAreaView.delegate = self;
    
    // Logo
    if ([LCUtils isIPhone6Plus] || [LCUtils isIPhoneX] || [LCUtils isIPhoneXr] ||
        [LCUtils isIPhoneXs] || [LCUtils isIPhoneXsMax]) {
        self.logoImageView.image = [LCAuthManager globalConfig].logoImage;
        self.logoImageView.hidden = NO;
        self.logoTopCons.constant = [LCUtils valueForDifferentSizeS_3_5:0
                                                                  S_4_0:0
                                                                  S_4_7:0
                                                                  S_5_5:(_useBiometricsAuthButton.hidden ? 55 : 45)
                                                                  S_5_8:60
                                                                  S_6_1:65
                                                                  S_6_5:(_useBiometricsAuthButton.hidden ? 90 : 95)];
    } else {
        self.logoImageView.image = nil;
        self.logoImageView.hidden = YES;
        self.logoTopCons.constant = 20;
    }
    
    // 适配屏幕
    _touchAreaCenterYCons.constant = [LCUtils valueForDifferentSizeS_3_5:-20
                                                                   S_4_0:(_useBiometricsAuthButton.hidden ? -55 : -20)
                                                                   S_4_7:(_useBiometricsAuthButton.hidden ? -65 : -20)
                                                                   S_5_5:(_useBiometricsAuthButton.hidden ? -55 : -45)
                                                                   S_5_8:(_useBiometricsAuthButton.hidden ? -55 : -45)
                                                                   S_6_1:(_useBiometricsAuthButton.hidden ? -65 : -45)
                                                                   S_6_5:(_useBiometricsAuthButton.hidden ? -60 : -75)];
    
    // 适配全面屏
    if ([LCUtils isZeroBezel]) {
        _otherOperateBottomCons.constant = 35;
    }
}

- (void)viewWillAppear:(BOOL)animated {
#ifdef LCGestureAuthAnimationOn
    [self capturePreSnap];
#endif
    
    [super viewWillAppear:animated];
    
    // 初始化内容
    switch (_lockViewType) {
        case LCGestureAuthViewTypeCheck:
        {
            _titleLabel.text = @"验证手势密码";
            _tipLablel.text = @"请绘制手势密码";
            _closeBtn.hidden = YES;
        }
            break;
        case LCGestureAuthViewTypeCreate:
        {
            _titleLabel.text = @"创建手势密码";
            _tipLablel.text = @"创建手势密码";
            _useBiometricsAuthButton.hidden = YES;
            _useBiometricsAuthLabel.hidden = YES;
            _closeBtn.hidden = NO;
        }
            break;
        case LCGestureAuthViewTypeModify:
        {
            _titleLabel.text = @"修改手势密码";
            _tipLablel.text = @"请绘制当前密码";
            _useBiometricsAuthButton.hidden = YES;
            _useBiometricsAuthLabel.hidden = YES;
            _closeBtn.hidden = NO;
        }
            break;
        case LCGestureAuthViewTypeClean:
        {
            _titleLabel.text = @"清除手势密码";
            _tipLablel.text = @"请绘制当前密码以清除密码";
            _closeBtn.hidden = NO;
        }
            break;
        default:
        {
            _titleLabel.text = @"验证手势密码";
            _tipLablel.text = @"请绘制当前密码";
            _closeBtn.hidden = YES;
        }
    }
    
    // 初始化尝试机会
    _remainderRetryTimes = [LCAuthManager globalConfig].maxGestureRetryTimes;
    
    self.passwordOld = @"";
    self.passwordNew = @"";
    self.passwordconfirm = @"";
    
    // 本地保存的手势密码
    self.savedPassword = [LCAuthPasswordManager loadGesturePassword];
    LCLog(@"本地保存的密码是：%@", self.savedPassword);
    
    [self updateTipButtonStatus];
}

#pragma mark - 检查 / 更新密码
- (void)checkPassword:(NSString*)string {
    
    // 验证密码正确
    if ([string isEqualToString:self.savedPassword]) { // 验证旧密码
        
        if (_lockViewType == LCGestureAuthViewTypeModify) { // 修改密码
            
            self.passwordOld = string; // 设置旧密码，说明是在修改
            [self setTip:@"请输入新的密码"];
            
        } else if (_lockViewType == LCGestureAuthViewTypeClean) { // 清除密码

            [LCAuthPasswordManager persistGesturePassword:nil];
            
            [self hide];
            
            // 通知代理
            if ([LCAuthManager delegate] && [[LCAuthManager delegate] respondsToSelector:@selector(gestureCheckState:viewType:)]) {
                
                [[LCAuthManager delegate] gestureCheckState:LCGestureAuthViewCheckResultSuccess viewType:_lockViewType];
                
            }
            
        } else if (_lockViewType == LCGestureAuthViewTypeCheck) { // 验证成功
            
            [self hide];
            
            // 通知代理
            if ([LCAuthManager delegate] && [[LCAuthManager delegate] respondsToSelector:@selector(gestureCheckState:viewType:)]) {
                [[LCAuthManager delegate] gestureCheckState:LCGestureAuthViewCheckResultSuccess viewType:_lockViewType];
            }
        }
        
    } else if (string.length > 0) {
        
        // 验证密码错误
        _remainderRetryTimes--;
        
        if (_remainderRetryTimes > 0) {
            
            if (_remainderRetryTimes == 1) {
                
                [self setErrorTip:[NSString stringWithFormat:@"最后的机会啦"] errorPswd:string];
                
            } else {
                
                [self setErrorTip:[NSString stringWithFormat:@"密码错误，还可以尝试%zd次", _remainderRetryTimes] errorPswd:string];
                
            }
        
        } else {
            // 输错超过最大次数，这里该做一些如强制退出重设密码等操作
            !_reachMaxRetryTimesBlock ? : _reachMaxRetryTimesBlock(self, _lockViewType);
            // 通知代理
            if ([LCAuthManager delegate] && [[LCAuthManager delegate] respondsToSelector:@selector(gestureRetryReachMaxTimesWithAuthController:viewType:)]) {
                [[LCAuthManager delegate] gestureRetryReachMaxTimesWithAuthController:self viewType:_lockViewType];
            }
        }
        
    }
    
}

- (void)createPassword:(NSString*)string {
    
    // 输入密码
    if ([self.passwordNew isEqualToString:@""] && [self.passwordconfirm isEqualToString:@""]) {
        
        self.passwordNew = string;
        
        [self setTip:self.tip2];
        
    } else if (![self.passwordNew isEqualToString:@""] && [self.passwordconfirm isEqualToString:@""]) {

        // 确认输入密码
        self.passwordconfirm = string;
        
        // 检查两次输入的密码是否相同
        if ([self.passwordNew isEqualToString:self.passwordconfirm]) {
            
            // 成功
            LCLog(@"两次密码一致");
            
            [LCAuthPasswordManager persistGesturePassword:string];
            
            if ([LCAuthManager delegate] && [[LCAuthManager delegate] respondsToSelector:@selector(gestureCheckState:viewType:)]) {
                
                [[LCAuthManager delegate] gestureCheckState:LCGestureAuthViewCheckResultSuccess viewType:_lockViewType];
                
            }
            
            [self hide];
            
        } else {
            
            self.passwordconfirm = @"";
            
            [self setErrorTip:@"与上一次绘制不一致，请重新绘制" errorPswd:string];
            
        }
        
    }
    
}

#pragma mark - 显示提示
- (void)setTip:(NSString*)tip {
    [_tipLablel setText:tip];
    [_tipLablel setTextColor:[LCAuthManager globalConfig].normalTipColor];
    
    _tipLablel.alpha = 0;
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:1 animations:^{
        weakSelf.tipLablel.alpha = 1;
    } completion:^(BOOL finished){
    }];
}

// 错误
- (void)setErrorTip:(NSString*)tip errorPswd:(NSString*)string {
    // 显示错误点点
    [self.touchAreaView showErrorCircles:string];
    
    [_tipLablel setText:tip];
    [_tipLablel setTextColor:[LCAuthManager globalConfig].errorTipColor];
    
    [self shakeAnimationForView:_tipLablel];
}

#pragma mark 新建/修改后保存
- (void)updateTipButtonStatus {
    LCLog(@"重设TipButton");
    if ((_lockViewType == LCGestureAuthViewTypeCreate ||
         _lockViewType == LCGestureAuthViewTypeModify) &&
        ![self.passwordNew isEqualToString:@""])  {
        
        // 新建或修改 & 确认时 才显示按钮
        [self.tipButton setTitle:@"点击此处以重新开始" forState:UIControlStateNormal];
        [self.tipButton setAlpha:1.0];
        
    } else {
        
        [self.tipButton setAlpha:0.0];
        
    }
}

#pragma mark - 成功后返回
- (void)hide {
    switch (_lockViewType) {
            
        case LCGestureAuthViewTypeCheck:
        {
        }
            break;
        case LCGestureAuthViewTypeCreate:
        {
            [LCAuthPasswordManager persistGesturePassword:self.passwordNew];
        }
            break;
        case LCGestureAuthViewTypeModify:
        {
            if ([self.passwordconfirm isEqualToString:@""]) {
                
                // 表示未完成修改，将不做操作
                [LCAuthPasswordManager persistGesturePassword:self.savedPassword];
                
            } else {
                
                // 表示已完成修改，存储密码
                [LCAuthPasswordManager persistGesturePassword:self.passwordconfirm];
                
            }
            
        }
            break;
        case LCGestureAuthViewTypeClean:
        {
            [LCAuthPasswordManager persistGesturePassword:nil];
        }
            break;
        default:
        {
            [LCAuthPasswordManager persistGesturePassword:nil];
        }
    }
    
    // 在这里可能需要回调上个页面做一些刷新什么的动作

#ifdef LCGestureAuthAnimationOn
    [self captureCurrentSnap];
    // 隐藏控件
    for (UIView* v in self.view.subviews) {
        if (v.tag > 10000) continue;
        v.hidden = YES;
    }
    // 动画解锁
    [self animateUnlock];
#else
    
    // 防止8.0以下系统在忘记手势密码及使用其他账号登录的情况下无法弹出视图
    [self dismissViewControllerAnimated:IOS_VERSION_8_OR_ABOVE completion:nil];
    
#endif
    
}

#pragma mark - delegate 每次划完手势后
- (void)lockString:(NSString *)string {
    LCLog(@"这次的密码[%@]", string);
    
    // 更新指示圆点
    [self.indicatorView setPasswordString:string];
    
    if (string.length < [LCAuthManager globalConfig].gesturePasswordMinLength) {
        
        [self setTip:@"最少绘制4位密码，请重新绘制"];
        return;
        
    }
    
    switch (_lockViewType) {
            
        case LCGestureAuthViewTypeCheck:
        {
            _tipLablel.text = @"请绘制解锁密码";
            [self checkPassword:string];
        }
            break;
        case LCGestureAuthViewTypeCreate:
        {
            
            self.tip1 = @"请绘制新的密码";
            self.tip2 = @"请再次绘制解锁密码";
            self.tip3 = @"解锁密码创建成功";
            [self createPassword:string];
            
        }
            break;
        case LCGestureAuthViewTypeModify:
        {
            if ([self.passwordOld isEqualToString:@""]) {
                
                self.tip1 = @"请绘制当前密码";
                [self checkPassword:string];
                
            } else {
                
                self.tip2 = @"请再次绘制密码";
                self.tip3 = @"密码修改成功";
                [self createPassword:string];
                
            }
        }
            break;
        case LCGestureAuthViewTypeClean:
        default:
        {
            self.tip1 = @"请绘制密码以清除密码";
            self.tip2 = @"清除密码成功";
            [self checkPassword:string];
        }
    }
    
    [self updateTipButtonStatus];
}

#pragma mark - 解锁动画
// 截屏，用于动画
#ifdef LCGestureAuthAnimationOn
- (UIImage *)imageFromView:(UIView *)theView {
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

// 上一界面截图
- (void)capturePreSnap {
    self.preSnapImageView.hidden = YES; // 默认是隐藏的
    self.preSnapImageView.image = [self imageFromView:self.presentingViewController.view];
}

// 当前界面截图
- (void)captureCurrentSnap {
    self.currentSnapImageView.hidden = YES; // 默认是隐藏的
    self.currentSnapImageView.image = [self imageFromView:self.view];
}

- (void)animateUnlock {
    
    self.currentSnapImageView.hidden = NO;
    self.preSnapImageView.hidden = NO;
    
    static NSTimeInterval duration = 0.5;
    
    // currentSnap
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:2.0];
    
    CABasicAnimation *opacityAnimation;
    opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue=[NSNumber numberWithFloat:1];
    opacityAnimation.toValue=[NSNumber numberWithFloat:0];
    
    CAAnimationGroup* animationGroup =[CAAnimationGroup animation];
    animationGroup.animations = @[scaleAnimation, opacityAnimation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = duration;
    animationGroup.delegate = self;
    animationGroup.autoreverses = NO; // 防止最后显现
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    [self.currentSnapImageView.layer addAnimation:animationGroup forKey:nil];
    
    // preSnap
    scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.5];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
    
    opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:1];
    
    animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[scaleAnimation, opacityAnimation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = duration;

    [self.preSnapImageView.layer addAnimation:animationGroup forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.currentSnapImageView.hidden = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
}
#endif

#pragma mark 抖动动画
- (void)shakeAnimationForView:(UIView *)view {
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint left = CGPointMake(position.x - 8, position.y);
    CGPoint right = CGPointMake(position.x + 8, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:left]];
    [animation setToValue:[NSValue valueWithCGPoint:right]];
    [animation setAutoreverses:YES]; // 平滑结束
    [animation setDuration:0.03];
    [animation setRepeatCount:4];
    
    [viewLayer addAnimation:animation forKey:nil];
}

- (void)reset {
    
    self.passwordNew = @"";
    self.passwordconfirm = @"";
    
    [self hide];

}

#pragma mark - 其他操作
- (IBAction)useBiometricsAuth:(id)sender {
    LCLog(@"使用生物识别辅助验证");
    LCBiometricsType biometricsType = [LCBiometricsAuthManager isSupportBiometricsAuth];
    
    if (biometricsType != LCBiometricsTypeNone) {
        
        //初始化上下文对象
        NSString *reason = ((biometricsType == LCBiometricsTypeTouchID) ? @"使用指纹识别辅助验证" : @"使用面容识别辅助验证");
        NSString *fallbackTitle = ((biometricsType == LCBiometricsTypeTouchID) ? @"使用密码" : @"");
        
        fallbackTitle = ((biometricsType == LCBiometricsTypeTouchID) ? @"使用密码" : @"");
        
        __block LCGestureAuthViewType weakLockViewType = _lockViewType;
        [LCAuthManager verifyBiometricsAuthWithReason:reason fallbackTitle:fallbackTitle Success:^(LCBiometricsAuthCheckResultType checkResultType) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 切换主线程处理
                [self hide];
                if ([LCAuthManager delegate] && [[LCAuthManager delegate] respondsToSelector:@selector(gestureCheckState:viewType:)]) {
                    [[LCAuthManager delegate] gestureCheckState:LCGestureAuthViewCheckResultSuccess viewType:weakLockViewType];
                }
            });
            
        } Fail:^(LCBiometricsAuthCheckResultType checkResultType, NSError *error) {
            
            // 未通过
            dispatch_async(dispatch_get_main_queue(), ^{
                // 切换主线程处理
                if ([LCAuthManager delegate] && [[LCAuthManager delegate] respondsToSelector:@selector(gestureCheckState:viewType:)]) {
                    [[LCAuthManager delegate] gestureCheckState:LCGestureAuthViewCheckResultFailed viewType:weakLockViewType];
                }
            });
            
        } Fallback:^(LCBiometricsAuthCheckResultType checkResultType, NSError *error) {
            // 未通过
            dispatch_async(dispatch_get_main_queue(), ^{
                // 切换主线程处理
                if ([LCAuthManager delegate] && [[LCAuthManager delegate] respondsToSelector:@selector(gestureCheckState:viewType:)]) {
                    [[LCAuthManager delegate] gestureCheckState:LCGestureAuthViewCheckResultCancel viewType:weakLockViewType];
                }
            });
        } delegate:[LCAuthManager delegate]];
    }
}

- (IBAction)firstAssistClick:(UIButton *)sender {
    
    LCLog(@"点击辅助操作一：%@", sender.titleLabel.text);
    
    !_assistOperationBlock ? : _assistOperationBlock(self, _lockViewType, 0);
    // 通知代理
    if ([LCAuthManager delegate] && [[LCAuthManager delegate] respondsToSelector:@selector(assistOperationWithAuthController:viewType:operationType:)]) {
        [[LCAuthManager delegate] assistOperationWithAuthController:self viewType:_lockViewType operationType:1];
    }
}

-(IBAction)secondAssistClick:(UIButton *)sender {
    
    LCLog(@"点击辅助操作二：%@", sender.titleLabel.text);
    
    !_assistOperationBlock ? : _assistOperationBlock(self, _lockViewType, 1);
    // 通知代理
    if ([LCAuthManager delegate] && [[LCAuthManager delegate] respondsToSelector:@selector(assistOperationWithAuthController:viewType:operationType:)]) {
        [[LCAuthManager delegate] assistOperationWithAuthController:self viewType:_lockViewType operationType:0];
    }
}

- (IBAction)close:(id)sender {
    
    __weak typeof(self)weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if ([LCAuthManager delegate] && [[LCAuthManager delegate] respondsToSelector:@selector(gestureCheckState:viewType:)]) {
            [[LCAuthManager delegate] gestureCheckState:LCGestureAuthViewCheckResultCancel viewType:weakSelf.lockViewType];
        }
    }];
}

- (void)cancelCheck {
    
    [self close:_closeBtn];
}

- (void)dealloc {
    
    LCLog(@"%s", __FUNCTION__);
    
}

// 不允许允许横屏旋转
- (BOOL)shouldAutorotate {
    
    return NO;
    
}

// 仅支持竖屏方向的旋转
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}

// 默认为竖屏
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}
@end
