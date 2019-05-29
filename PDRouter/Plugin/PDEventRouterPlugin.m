//
//  PDEventRouterPlugin.m
//  PDRouter
//
//  Created by liang on 2019/5/29.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDEventRouterPlugin.h"

@implementation PDEventRouterPlugin

- (void)load {
    [self.router inject:@"log" eventHandler:^(NSDictionary * _Nullable params) {
        NSLog(@"======================================>");
        NSLog(@"url = %@, params = %@", @"log", params);
        NSLog(@"======================================>");
    }];
}

- (BOOL)openURL:(NSString *)encodedURLString params:(NSDictionary *)params {
    // TODO: recognize and process
    return NO;
}

@end
