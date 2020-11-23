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

- (void)load {
    // Override this method...
}

- (BOOL)openURL:(NSString *)urlString params:(NSDictionary *)params {
    return NO;
}

@end
