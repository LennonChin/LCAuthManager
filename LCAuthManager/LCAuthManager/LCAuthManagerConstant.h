//
//  LCAuthManagerConstant.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/27.
//  Copyright © 2018 coderap. All rights reserved.
//

#ifndef LCAuthManagerConstant_h
#define LCAuthManagerConstant_h

#ifdef DEBUG
#define LCLog(format, ...) NSLog((@"%s[%d]:" format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define LCLog(format, ...) /* */
#endif

// 判断系统版本是否大于等于8.0
#define IOS_VERSION_8_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)? (YES):(NO))

// 判断系统版本是否大于等于9.0
#define IOS_VERSION_9_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)? (YES):(NO))

// 屏幕尺寸
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

#endif /* LCAuthManagerConstant_h */
