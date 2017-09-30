//
//  NatAlipay.h
//
//  Created by Acathur on 17/10/1.
//  Copyright © 2017 Instapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NatAlipay : NSObject

typedef void (^NatCallback)(id error, id result);

+ (NatAlipay *)singletonManger;

- (void)pay:(NSDictionary *)options :(NatCallback)callBack;
- (void)processPayResult:(NSURL *)url :(NatCallback)callBack;

- (void)auth:(NSDictionary *)options :(NatCallback)callBack;
- (void)processAuthResult:(NSURL *)url :(NatCallback)callBack;

@end
