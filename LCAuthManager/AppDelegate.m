//
//  AppDelegate.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "AppDelegate.h"
#import "LCAuthManager.h"
#import "LCAuthManagerConfig.h"

@interface AppDelegate ()<LCAuthManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    // 一定要在visible之后
    [self checkAuth];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /**
     * 设置不验证的超时时间
     * 设置这个时间之后，用户切出App，并在这个时间内切回不会有验证操作
     * 使用场景：比如分享内容到其他App后切回本App，时间间隔很短，可以临时关闭验证
     */
    [LCAuthManager setCloseAuthTemporary:2];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [self checkAuth];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - 手势密码及生物识别相关
- (void)checkAuth {
    
    // 手势密码
    LCGestureAuthViewController *gestureAuthViewController = nil;
    if ([LCAuthManager isGestureAuthOpened]) {
        UINavigationController *rootViewController = (UINavigationController *)self.window.rootViewController;
        [LCAuthManager globalConfig].gestrueVCBackgroundImage = [UIImage imageNamed:@"background"];
        gestureAuthViewController = [LCAuthManager showGestureAuthViewControllerWithType:LCGestureAuthViewTypeCheck hostViewControllerView:rootViewController.topViewController delegate:self];
    }
    
    // 生物识别
    if ([LCAuthManager isBiometricsAuthOpened:LCBiometricsTypeUnknown]) {
        // 开始验证生物识别
        NSString *reason = (([LCBiometricsAuthManager isSupportBiometricsAuth] == LCBiometricsTypeTouchID) ? @"按压您的指纹以解锁" : @"验证您的面容以解锁");
        
        [LCAuthManager verifyBiometricsAuthWithReason:reason fallbackTitle:@"使用手势密码" Success:^(LCBiometricsAuthCheckResultType checkResultType) {
            
            
            // 需要切到主线程处理，当网页弹出键盘时，切出APP再切入，在子线程处理会引发崩溃
            dispatch_async(dispatch_get_main_queue(), ^{
                UINavigationController *rootViewController = (UINavigationController *)self.window.rootViewController;
                if (gestureAuthViewController != nil && rootViewController.topViewController.presentedViewController == gestureAuthViewController) {
                    
                    // 跳过手势密码的验证
                    [gestureAuthViewController cancelCheck];
                }
                
            });
            
        } Fail:^(LCBiometricsAuthCheckResultType checkResultType, NSError *error) {
            
            NSLog(@"AppDelegate evaluatePolicy Error: %@", error);
            
            switch (error.code) {
                    
                case LAErrorSystemCancel: {
                    NSLog(@"切换到其他APP，系统取消验证Biometrics ID");
                    break;
                }
                case LAErrorUserCancel: {
                    NSLog(@"用户取消验证Biometrics ID");
                    break;
                }
                case LAErrorUserFallback: {
                    NSLog(@"用户选择输入开机密码（手势密码）进行验证");
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                    }];
                    break;
                }
                default: {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        // 其他情况，切换主线程处理
                    }];
                    break;
                }
            }
            
        } Fallback:^(LCBiometricsAuthCheckResultType checkResultType, NSError *error) {
            
        } delegate:self];
        
    }
}

#pragma mark - 代理方法
- (void)gestureRetryReachMaxTimesWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType {
    
    [self showAlert:@"达到最大次数"];
}

- (void)assistOperationWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType operationType:(NSInteger)operationType {
    if (operationType == 0) {
        [self showAlert:@"点击了忘记手势密码"];
    } else {
        [self showAlert:@"使用其他账户登录"];
    }
}

#pragma mark - 提示信息
- (void)showAlert:(NSString*)string {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:string
                                                   delegate:nil
                                          cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}
@end
