//
//  AppDelegate.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "AppDelegate.h"
#import "LCAuthManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self checkAuth];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
        gestureAuthViewController = [LCAuthManager showGestureAuthViewControllerWithType:LCGestureAuthViewTypeCheck hostViewControllerView:self.window.rootViewController delegate:nil];
    }
    
    // 生物识别
    if ([LCAuthManager isBiometricsAuthOpened]) {
        // 开始验证生物识别
        NSString *reason = (([LCBiometricsAuthManager isSupportBiometricsAuth] == BiometricsTypeTouchID) ? @"按压您的指纹以解锁" : @"验证您的面容以解锁");
        
        [LCBiometricsAuthManager verifyBiometricsAuthWithReason:reason fallbackTitle:@"使用手势密码" Success:^{
            
            // 需要切到主线程处理，当网页弹出键盘时，切出APP再切入，在子线程处理会引发崩溃
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (gestureAuthViewController != nil && self.window.rootViewController.presentedViewController == gestureAuthViewController) {
                    
                    // 跳过手势密码的验证
                    [gestureAuthViewController cancelCheck];
                }
                
            });
            
        } Fail:^(NSError *error, LAError errorCode) {
            
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
            
        } Fallback:^(NSError *error, LAError errorCode) {
            
        }];
        
    }
}

@end
