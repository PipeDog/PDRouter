//
//  PDRouterPlugin.m
//  PDRouter
//
//  Created by liang on 2019/5/29.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDRouterPlugin.h"

@implementation PDRouterPlugin

- (PDRouterPluginPriority)priority {
    return 0;
}

- (void)load {}
- (void)unload {}

- (BOOL)openURL:(NSString *)encodedURLString params:(NSDictionary *)params {
    return NO;
}

@end
