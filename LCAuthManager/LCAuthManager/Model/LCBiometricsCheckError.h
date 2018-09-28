//
//  LCBiometricsCheckError.h
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/28.
//  Copyright © 2018 coderap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCAuthManagerConstant.h"

@interface LCBiometricsCheckError : NSError
@property (readonly) LCBiometricsAuthCheckResultType errorCode;
- (instancetype)initWithDomain:(NSErrorDomain)domain originCode:(NSInteger)originCode errorCode:(LCBiometricsAuthCheckResultType)errorCode userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict;
@end
