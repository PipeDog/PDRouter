//
//  PDLogInterceptor.m
//  PDRouter_Example
//
//  Created by liang on 2024/3/21.
//  Copyright © 2024 liang. All rights reserved.
//

#import "PDLogInterceptor.h"

@implementation PDLogInterceptor

- (BOOL)intercept:(id<PDRouterInterceptorChain>)chain {
    NSLog(@"PDLogInterceptor#intercept -> %@.", chain.request);
    return [chain proceed:chain.request];
}

@end
