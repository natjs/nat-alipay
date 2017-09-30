//
//  NatAlipay.m
//
//  Created by Acathur on 17/10/1.
//  Copyright © 2017 Instapp. All rights reserved.
//

#import "NatAlipay.h"
#import <AlipaySDK/AlipaySDK.h>

@interface NatAlipay ()
@end

@implementation NatAlipay

+ (NatAlipay *)singletonManger{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}


// Pay

- (void)handlePay:(NSDictionary *)resultDic :(NatCallback)callback {
    NSLog(@"[nat] [alipay] [pay] reslut = %@", resultDic);
    
    NSString *status = resultDic[@"resultStatus"];
    NSString *memo = resultDic[@"memo"];
    NSString *result = resultDic[@"result"];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSASCIIStringEncoding] options:kNilOptions error:nil];
    
    if ([status isEqual:@"9000"]) {
        callback(nil, data);
    } else {
        callback(@{@"error":@{@"msg":memo, @"code":status}}, nil);
    }
}

- (void)pay:(NSDictionary *)options :(NatCallback)callback {
    NSString *info = options[@"info"];
    NSString *scheme = options[@"scheme"];
    
    [[AlipaySDK defaultService] payOrder:info fromScheme:scheme callback:^(NSDictionary *resultDic) {
        [self handlePay :resultDic :callback];
    }];
}

- (void)processPayResult:(NSURL *)url :(NatCallback)callback{
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [self handlePay :resultDic :callback];
        }];
    }
}


// Auth

- (void)handleAuth:(NSDictionary *)resultDic :(NatCallback)callback {
    NSLog(@"[nat] [alipay] [auth] result = %@", resultDic);
    
    NSString *status = resultDic[@"resultStatus"];
    NSString *memo = resultDic[@"memo"];
    NSString *result = resultDic[@"result"];
    NSString *authCode = nil;
    
    if ([status isEqual:@"9000"] && result.length > 0) {
        NSArray *resultArr = [result componentsSeparatedByString:@"&"];
        for (NSString *subResult in resultArr) {
            if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                authCode = [subResult substringFromIndex:10];
                break;
            }
        }
        callback(nil, @{@"authCode":authCode});
    } else {
        callback(@{@"error":@{@"msg":memo, @"code":status}}, nil);
    }
}

- (void)auth:(NSDictionary *)options :(NatCallback)callback{
    NSString *info = options[@"info"];
    NSString *scheme = options[@"scheme"];
    
    [[AlipaySDK defaultService] auth_V2WithInfo:info fromScheme:scheme callback:^(NSDictionary *resultDic) {
        [self handleAuth :resultDic :callback];
    }];
}

- (void)processAuthResult:(NSURL *)url :(NatCallback)callback{
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            [self handleAuth :resultDic :callback];
        }];
    }
}

@end
