//
//  LCBiometricsCheckError.m
//  LCAuthManager
//
//  Created by LennonChin on 2018/9/28.
//  Copyright © 2018 coderap. All rights reserved.
//

#import "LCBiometricsCheckError.h"

@interface LCBiometricsCheckError () {
    LCBiometricsAuthCheckResultType _errorCode;
}
@end

@implementation LCBiometricsCheckError
- (instancetype)initWithDomain:(NSErrorDomain)domain originCode:(NSInteger)originCode errorCode:(LCBiometricsAuthCheckResultType)errorCode userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict {
    
    if (self = [super initWithDomain:domain code:originCode userInfo:dict]) {
        _errorCode = errorCode;
    }
    return self;
}

- (LCBiometricsAuthCheckResultType)errorCode {
    return _errorCode;
}
@end
