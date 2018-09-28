//
//  ViewController.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "ViewController.h"

#import "AppDelegate.h"
#import "LCAuthManager.h"
#import "LCAuthPasswordManager.h"

@interface ViewController ()<LCAuthManagerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *gestureSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *biometricsAuthSwitch;
@property (weak, nonatomic) IBOutlet UILabel *biometricsLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    
    // 手势密码
    if ([LCBiometricsAuthManager isSupportBiometricsAuth] == LCBiometricsTypeNone) {
        
        self.navigationItem.title = @"手势密码";
        
    } else {
        
        if ([LCBiometricsAuthManager isSupportBiometricsAuth] == LCBiometricsTypeTouchID) {
            
            self.navigationItem.title = @"指纹识别及手势密码";
            
        } else if ([LCBiometricsAuthManager isSupportBiometricsAuth] == LCBiometricsTypeFaceID) {
            
            self.navigationItem.title = @"面容识别及手势密码";
        }
    }
    
    // 关闭按钮
    if (_haveCloseBtn) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"cha"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = barButton;
        
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor darkGrayColor];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // 初始化状态
    _gestureSwitch.on = [LCAuthManager isGestureAuthOpened];
    _biometricsAuthSwitch.on = [LCAuthManager isBiometricsAuthOpened:[LCBiometricsAuthManager isSupportBiometricsAuth]];
    
    // 刷新表格数据
    [self.tableView reloadData];
    
    if (_biometricsLabel != nil && [LCBiometricsAuthManager isSupportBiometricsAuth] == LCBiometricsTypeTouchID) {
        
        _biometricsLabel.text = @"优先使用指纹识别";
        
    } else if ([LCBiometricsAuthManager isSupportBiometricsAuth] == LCBiometricsTypeFaceID) {
        
        _biometricsLabel.text = @"优先使用面容识别";
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10.0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        if ([LCBiometricsAuthManager isSupportBiometricsAuth] == LCBiometricsTypeNone || !_gestureSwitch.on) {
            
            return 1;
            
        } else {
            
            return 2;
        }
        
    } else {
        
        return 2;
        
    }
    
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_gestureSwitch.on) {
        
        return 2;
        
    } else {
        
        return 1;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 1) {
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        if (indexPath.row == 0) {
            
            // 修改手势密码
            if(window.rootViewController.presentingViewController == nil){
                
                [LCAuthManager showGestureAuthViewControllerWithType:LCGestureAuthViewTypeModify hostViewControllerView:self delegate:self];
                
            }
            
        } else if (indexPath.row == 1) {
            
            // 忘记手势密码
            [LCAuthManager directlyforgetPassword];
            
        }
        
    }
    
}

- (IBAction)gestureSwitch:(UISwitch *)sender {
    
    if (sender.on) {
        
        // 开启手势密码
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if(window.rootViewController.presentingViewController == nil){
            
            [LCAuthManager showGestureAuthViewControllerWithType:LCGestureAuthViewTypeCreate hostViewControllerView:self delegate:self];
            
        }
        
    } else {
        
        // 关闭手势密码
        if ([LCAuthManager isGestureAuthOpened]) {
            
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if(window.rootViewController.presentingViewController == nil) {
                
                [LCAuthManager showGestureAuthViewControllerWithType:LCGestureAuthViewTypeClean hostViewControllerView:self delegate:self];
                
            }
            
        }
        
    }
}

- (IBAction)biometricsAuthSwitch:(UISwitch *)sender {
    
    LCBiometricsType biometricsType = [LCBiometricsAuthManager isSupportBiometricsAuth];
    
    if (biometricsType != LCBiometricsTypeNone) {
        
        //初始化上下文对象
        NSString *reason = @"";
        NSString *fallbackTitle = @"";
        if (sender.on) {
            
            reason = ((biometricsType == LCBiometricsTypeTouchID) ? @"按压您的指纹以开启指纹识别" : @"验证以开启面容识别");
            
        } else {
            
            reason = ((biometricsType == LCBiometricsTypeTouchID) ? @"按压您的指纹以关闭指纹识别" : @"验证以关闭面容识别");
        }
        
        fallbackTitle = ((biometricsType == LCBiometricsTypeTouchID) ? @"使用密码" : @"");
        
        [LCAuthManager verifyBiometricsAuthWithReason:reason fallbackTitle:@"使用手势密码" Success:^(LCBiometricsAuthCheckResultType checkResultType) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (sender.on) {
                    
                    // 开启生物识别
                    // 存储到沙盒，1-开启了生物识别，0-未开启生物识别
                    [LCAuthPasswordManager persistBiometricsAuth:biometricsType isOn:YES];
                    
                    // 刷新表格数据
                    [self.tableView reloadData];
                    
                    // 提示
                    if (biometricsType == LCBiometricsTypeTouchID) {
                        NSLog(@"开启指纹识别成功");
                    } else if (biometricsType == LCBiometricsTypeFaceID) {
                        NSLog(@"开启面容识别成功");
                    }
                    
                } if (!sender.on) {
                    
                    // 关闭生物识别
                    // 更新到沙盒，1-开启了生物识别，0-未开启生物识别
                    [LCAuthPasswordManager persistBiometricsAuth:biometricsType isOn:NO];
                    
                    // 刷新表格数据
                    [self.tableView reloadData];
                    
                    // 提示
                    if (biometricsType == LCBiometricsTypeTouchID) {
                        NSLog(@"关闭指纹识别成功");
                    } else if (biometricsType == LCBiometricsTypeFaceID) {
                        NSLog(@"关闭面容识别成功");
                    }
                }
                
            });
            
        } Fail:^(LCBiometricsAuthCheckResultType checkResultType, NSError *error) {
            
            // 未通过
            dispatch_async(dispatch_get_main_queue(), ^{
                // 切换主线程处理
                sender.on = !sender.on;
            });
            
        } Fallback:^(LCBiometricsAuthCheckResultType checkResultType, NSError *error) {
            // 未通过
            dispatch_async(dispatch_get_main_queue(), ^{
                // 切换主线程处理
                sender.on = !sender.on;
            });
        } delegate:nil];
        
    } else {
        
        // 未通过，重置
        sender.on = !sender.on;
        
        // 刷新表格数据
        [self.tableView reloadData];
        
        // 提示
        NSLog(@"操作出错，请重试");
        
    }
    
}

#pragma mark - LLLockDelegate
- (void)gestureCheckState:(LCGestureAuthCheckResultType)checkResultType viewType:(LCGestureAuthViewType)viewType {
    
    if (viewType == LCGestureAuthViewTypeCreate) {
        
        if (checkResultType == LCGestureAuthViewCheckResultSuccess) {
            
            _gestureSwitch.on = YES;
            
            NSLog(@"创建手势密码成功");
            
        } else if (checkResultType == LCGestureAuthViewCheckResultFailed) {
            
            _gestureSwitch.on = NO;
            
            NSLog(@"创建手势密码失败");
            
        } else if (checkResultType == LCGestureAuthViewCheckResultCancel) {
            
            _gestureSwitch.on = NO;
            
        }
        
    } else if (viewType == LCGestureAuthViewTypeClean) {
        
        if (checkResultType == LCGestureAuthViewCheckResultSuccess) {
            
            // 更新对象数据
            _gestureSwitch.on = NO;
            
            // 顺便关闭生物识别
            [LCAuthPasswordManager persistBiometricsAuth:[LCBiometricsAuthManager isSupportBiometricsAuth] isOn:NO];
            
            NSLog(@"清除手势密码成功");
            
        } else if (checkResultType == LCGestureAuthViewCheckResultFailed) {
            
            _gestureSwitch.on = YES;
            
            NSLog(@"清除手势密码失败");
            
        } else if (checkResultType == LCGestureAuthViewCheckResultCancel) {
            
            _gestureSwitch.on = YES;
            
        }
        
    } else if (viewType == LCGestureAuthViewTypeModify) {
        
        if (checkResultType == LCGestureAuthViewCheckResultFailed) {
            
            // 回到根控制器
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } else if (checkResultType == LCGestureAuthViewCheckResultSuccess) {
            
            NSLog(@"修改手势密码成功");
            
        } else if (checkResultType == LCGestureAuthViewCheckResultCancel) {
            
        }
        
    }
    
    // 刷新表格数据
    [self.tableView reloadData];
}

#pragma mark - 代理方法
- (void)gestureRetryReachMaxTimesWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType {
    
    [self showAlert:@"达到最大次数"];
}

- (void)forgetGestureWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType {
    
    [self showAlert:@"点击了忘记手势密码"];
}

- (void)useOtherAcountLoginWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType {
    
    [self showAlert:@"使用其他账户登录"];
}

#pragma mark - 提示信息
- (void)showAlert:(NSString*)string {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:string
                                                   delegate:nil
                                          cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)dealloc {
    
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

- (void)close {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
