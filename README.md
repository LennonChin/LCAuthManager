# LCAuthManager简介

LCAuthManager是一个简单易用的权限验证库，提供了手势密码、生物特性验证（包括Touch ID和Face ID）的集成。

![ProjectLogo](https://github.com/LennonChin/LCAuthManager/tree/master/LCAuthManager/Images/ProjectLogo.jpg)

LCAuthManager有以下优点：

- 可配置性强，提供了针对手势密码页面及特性的配置，例如密码长度、试错最大次数、辅助操作等。
- 可结合使用，可以将手势密码和生物特性验证结合在一起，由开发者自定义进行配置。
- 提供大量对外接口，提供了凭证存储的对外接口，开发者可以接入自己的凭证存储方式。
- 项目提供了常见的Demo，可以协助开发者快速集成。

# 使用效果

1. 使用Face ID + 手势密码的效果：

![Face ID with Gesture Password Demo](https://github.com/LennonChin/LCAuthManager/tree/master/LCAuthManager/Images/FaceIDDemo.gif)

2. 使用Touch ID + 手势密码的效果：

![Touch ID with Gesture Password Demo](https://github.com/LennonChin/LCAuthManager/tree/master/LCAuthManager/Images/TouchIDDemo.gif)

# 快速上手

- 使用场景一：使用FaceID或TouchID进行验证

> 注意：使用FaceID时需要在`info.plist`文件中添加`NSFaceIDUsageDescription`权限申请说明，否则无法使用FaceID，系统会直接Crash。配置例子如下：

```xml
<key>NSFaceIDUsageDescription</key>
<string>App需要您的同意，才能访问您的面容识别功能，用于安全验证</string>
```

然后使用下面的代码进行验证：

```objective-c
#import "LCAuthManager.h"
...

if ([LCAuthManager isBiometricsAuthOpened:LCBiometricsTypeUnknown]) { // 检查生物特性识别是否可用
	// 自定义提示信息
	NSString *reason = (([LCBiometricsAuthManager isSupportBiometricsAuth] == LCBiometricsTypeTouchID) ? @"按压您的指纹以解锁" : @"验证您的面容以解锁");
	// 开始验证生物特性识别，系统会自动判断是使用TouchID还是使用FaceID
	[LCAuthManager verifyBiometricsAuthWithReason:reason fallbackTitle:@"" Success:^(LCBiometricsAuthCheckResultType checkResultType) {
		dispatch_async(dispatch_get_main_queue(), ^{
			// 处理验证通过的场景
		});
	} Fail:^(LCBiometricsAuthCheckResultType checkResultType, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			// 处理验证未通过的场景
		});
	} Fallback:^(LCBiometricsAuthCheckResultType checkResultType, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			// 处理当用户多次验证未通过，点击了系统弹出框右侧按钮的事件
		});
	} delegate:self];
}
```

- 使用场景二：创建手势密码

```objective-c
#import "LCAuthManager.h"
#import "LCAuthManagerConfig.h"
...

// 打开创建手势密码页面
UIWindow *window = [UIApplication sharedApplication].keyWindow;
if(window.rootViewController.presentingViewController == nil){
	[LCAuthManager globalConfig].useAssistOperations = NO;
	[LCAuthManager showGestureAuthViewControllerWithType:LCGestureAuthViewTypeCreate hostViewControllerView:self delegate:self];
}

// 处理结果的代理方法
- (void)gestureCheckState:(LCGestureAuthCheckResultType)checkResultType viewType:(LCGestureAuthViewType)viewType {
    if (viewType == LCGestureAuthViewTypeCreate) {
        if (checkResultType == LCGestureAuthViewCheckResultSuccess) {
            [self showAlert:@"创建手势密码成功"];
        } else if (checkResultType == LCGestureAuthViewCheckResultFailed) {
            [self showAlert:@"创建手势密码失败"];
        } else if (checkResultType == LCGestureAuthViewCheckResultCancel) {
            
            [self showAlert:@"取消创建手势密码"];
        }
        
    }
}
```

- 使用场景三：使用手势密码验证

```objective-c
#import "LCAuthManager.h"
...

// 手势密码
LCGestureAuthViewController *gestureAuthViewController = nil;
if ([LCAuthManager isGestureAuthOpened]) {
	UINavigationController *rootViewController = (UINavigationController *)self.window.rootViewController;
	gestureAuthViewController = [LCAuthManager showGestureAuthViewControllerWithType:LCGestureAuthViewTypeCheck hostViewControllerView:rootViewController.topViewController delegate:self];
}
```

# 详细使用

1. 引入本项目

目前仓库并未提交CocoaPods托管，你可以选择手动引入。克隆本项目到本地，将项目主目录下的LCAuthManager文件夹拖入工程，在需要使用的地方引入`#import "LCAuthManager.h`头文件即可。

2. 了解项目配置和代理：

- 项目枚举

项目中使用的枚举统一位于`LCAuthManagerConstant.h`文件中，开发过程中可以参考。

- 全局配置

LCAuthManager的配置都交由LCAuthManagerConfig类处理，并且配置是全局唯一的，所有的配置项全都可以在该类中找到；可以使用`[LCAuthManager globalConfig]`获取到全局LCAuthManagerConfig对象，然后直接修改配置项即可，如：

```objective-c
// 配置手势密码页面的背景图
[LCAuthManager globalConfig].gestrueVCBackgroundImage = [UIImage imageNamed:@"background"];
// 配置手势密码的最小长度
[LCAuthManager globalConfig].gesturePasswordMinLength = 5;
// 配置手势密码最大试错次数
[LCAuthManager globalConfig].maxGestureRetryTimes = 3;
// 配置使用手势密码时是否使用生物特性识别辅助
[LCAuthManager globalConfig].useBiometricsAuthAssist = YES;
```

> 注：需要注意的是，由于配置是全局唯一，所以前一次的配置会影响到后一次的功能，如果每次使用需求不同则每次使用都应该单独配置。

- 代理

关于功能上的某些回调，大部分使用了代理向外暴露接口，将操作委托给用户处理；本项目的对外代理都位于LCAuthManager类的中LCAuthManagerDelegate中，如下：

```objective-c
@protocol LCAuthManagerDelegate <NSObject>

@optional
#pragma mark - 手势密码相关
/** 手势密码相关，针对某种验证的验证结果 */
- (void)gestureCheckState:(LCGestureAuthCheckResultType)checkResultType viewType:(LCGestureAuthViewType)viewType;
/** 手势密码相关，达到最大次数代理方法 */
- (void)gestureRetryReachMaxTimesWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType;
/** 辅助操作相关，operationType：0-第一个辅助按钮被点击，1-第二个辅助按钮被点击 */
- (void)assistOperationWithAuthController:(LCGestureAuthViewController *)gestureAuthViewController viewType:(LCGestureAuthViewType)viewType operationType:(NSInteger)operationType;

#pragma mark - 生物特性识别相关
/** 生物特性识别相关，针对某种验证的验证结果 */
- (void)biometricsCheckState:(LCBiometricsAuthCheckResultType)checkResultType biometricsType:(LCBiometricsType)biometricsType error:(LCBiometricsCheckError *)error;

#pragma mark - 密码持久化相关
/** 查看是否设置了生物特性识别 */
- (BOOL)isBiometricsAuthOpened:(LCBiometricsType)biometricsType;
/** 生物特性识别相关，持久化生物特性识别的开启状态 */
- (BOOL)persistBiometricsAuth:(LCBiometricsType)biometricsType isOn:(BOOL)isOn;
/** 查看是否设置了手势密码 */
- (BOOL)isGestureAuthOpened;
/** 手势密码相关，持久化手势密码 */
- (BOOL)persistGestureAuth:(NSString *)password;
/** 加载手势密码 */
- (NSString *)loadGestureAuth;
@end
```

当然针对某些便捷操作也提供了相应的Block简化流程；当代理和Block同时设置时，相应的委托操作将同时有效。

3. 使用生物特性识别

> 注意：使用FaceID时需要在`info.plist`文件中添加`NSFaceIDUsageDescription`权限申请说明，否则无法使用FaceID，系统会直接Crash。

iOS中生物特性识别包括TouchID和FaceID，这两种验证方式对外暴露的接口非常简单，仅仅只提供了验证逻辑，也就是说，用户在使用这两类验证时，**只能是调用验证方法，获得验证结果**这两种操作。在LCAuthManager中对TouchID和FaceID进行了封装，外界不需要关心设备是否支持生物特性识别或设备支持哪种生物特性识别方法，只需要使用统一的方法进行调用即可。LCAuthManager中提供了对生物特性识别相关的支持方法：

```objective-c
/** 是否支持生物特性识别 */
+ (LCBiometricsType)isSupportBiometricsAuth;
/** 查看是否设置了生物特性识别 */
+ (BOOL)isBiometricsAuthOpened:(LCBiometricsType)biometricsType;
/** 生物特性识别相关，持久化生物特性识别的开启状态 */
+ (BOOL)persistBiometricsAuth:(LCBiometricsType)biometricsType isOn:(BOOL)isOn;
```

其中第一个方法可以用于判断设备是否支持生物特性识别及支持生物特性识别的类型；第二和第三个方法提供了对生物特性识别凭证的持久化存储和读取，默认情况下凭证是存储在用户偏好设置（`[NSUserDefaults standardUserDefaults]`）中以`LCAuthManagerConfig`为键的字典中的，开发者也可以自定义自己的凭证存储方式，这一点在后面进行讨论。

对生物特性识别的调用可以直接使用LCAuthManager类下面的方法：

```objective-c
/**
 使用生物识别验证
 
 @param reason 显示的理由
 @param fallbackTitle 验证出错后的右边按钮
 @param successBlock 成功回调Block
 @param failBlock 失败回调Block
 @param fallbackBlock 当生物识别达到最大次数时，会出现弹框，点击右侧按钮会调用该Block
 */
+ (void)verifyBiometricsAuthWithReason:(NSString *)reason
                         fallbackTitle:(NSString *)fallbackTitle
                               Success:(void (^)(LCBiometricsAuthCheckResultType checkResultType))successBlock
                                  Fail:(void (^)(LCBiometricsAuthCheckResultType checkResultType, NSError *error))failBlock
                              Fallback:(void (^)(LCBiometricsAuthCheckResultType checkResultType, NSError *error))fallbackBlock
                              delegate:(id<LCAuthManagerDelegate>)delegate;
```

该方法有三个Block可以处理三种不同的验证结果，同时还可以传入代理，让代理来处理验证结果。

4. 使用手势密码

手势密码提供下面的几类操作：

```objective-c
typedef NS_ENUM(NSUInteger, LCGestureAuthViewType) {
    LCGestureAuthViewTypeCheck,     // 检查手势密码
    LCGestureAuthViewTypeCreate,    // 创建手势密码
    LCGestureAuthViewTypeModify,    // 修改
    LCGestureAuthViewTypeClean,     // 清除
    LCGestureAuthViewTypeUnknown,   // 其他未知
};
```

所有的操作都通过LCAuthManager类的一个方法进行：

```objective-c
+ (LCGestureAuthViewController *)showGestureAuthViewControllerWithType:(LCGestureAuthViewType)lockViewType hostViewControllerView:(UIViewController *)hostViewController delegate:(id<LCAuthManagerDelegate>)delegate;
```

该方法要求传入操作类型、`hostViewControllerView`和代理，其中操作类型用于加载不同的手势识别页面和处理逻辑，`hostViewControllerView`用于以present的方式展示手势密码控制器，代理用于处理验证业务中的各类结果和委托事件，相关的代理事件方法可以查阅前一个小节。

5. 限时忽略验证

在某些场景中，我们可能需要暂时忽略权限的验证，比如当我们从App内分享内容到社交平台后，大部分用户在分享完成后会立即返回App，此时如果也需要权限的验证将会降低使用连贯性，因此LCAuthManager提供了临时忽略验证的方法：

```objective-c
/**
 暂时关闭验证
 适用于如对外分享内容后返回App，此时应该暂时不用验证

 @param timeout 限时时间，单位：秒
 */
+ (void)setCloseAuthTemporary:(NSTimeInterval)timeout;
```

例如我们可以在AppDelegate的`- (void)applicationDidEnterBackground:(UIApplication *)application`方法中设置忽略限时时间，如下面的例子设置了15秒的限时忽略：

```objective-c
- (void)applicationDidEnterBackground:(UIApplication *)application {
    /**
     * 设置不验证的限时时间
     * 设置这个时间之后，用户切出App，并在这个时间内切回不会有验证操作
     * 使用场景：比如分享内容到其他App后切回本App，时间间隔很短，可以临时关闭验证
     */
    [LCAuthManager setCloseAuthTemporary:15];
}
```

那么当App进入后台后，在15秒的时间内重新切回App是不会有权限验证的。

# 凭证的存储和读取

手势密码及生物特性识别虽然提供给开发者一种便捷的权限验证方法，但权限验证的凭证存储依旧是需要面对的问题。作为开发者来说，我并不推荐大家使用这些功能来保护重要的私密数据。**在本项目中对凭证也只是简单地做了本地的存储（存放在用户偏好设置中）。当然如果你想要使用这些功能来保护重要的数据，建议使用本项目提供的接口，自己处理凭证的存储，例如存储在钥匙串中。**

> 注意：本项目默认对凭证的存储处理是直接存放在用户偏好设置中，其中手势密码是明文存储的数字序列，生物特性识别是简单存储的开启或关闭的标识。相关代码可以查看LCAuthPasswordManager类和LCBiometricsAuthManager类。

在LCAuthManagerConfig的配置中有一项`keepAuthentication`的配置，该配置项默认为`NO`，如果你想要自己处理凭证的存储和读取，可以将该配置置为`YES`，然后实现LCAuthManagerDelegate指定的下列方法手动处理凭证的存储和读取：

```objective-c
#pragma mark - 密码持久化相关
/** 查看是否设置了生物识别 */
- (BOOL)isBiometricsAuthOpened:(LCBiometricsType)biometricsType;
/** 生物识别相关，持久化生物识别的开启状态 */
- (BOOL)persistBiometricsAuth:(LCBiometricsType)biometricsType isOn:(BOOL)isOn;
/** 查看是否设置了手势密码 */
- (BOOL)isGestureAuthOpened;
/** 手势密码相关，持久化手势密码 */
- (BOOL)persistGestureAuth:(NSString *)password;
/** 加载手势密码 */
- (NSString *)loadGestureAuth;
```

这些方法都是与用户无关的，开发者可以自定义绑定凭证信息到用户标识，只需要保证凭证在存储和读取时的一致性即可。

> 注意：如果你配置了`keepAuthentication`为`YES`，但没有实现上述的任意一个方法，运行时将会出现断言错误。

# License

[MIT](https://opensource.org/licenses/mit)

Copyright (c) 2018-present, LennonChin









