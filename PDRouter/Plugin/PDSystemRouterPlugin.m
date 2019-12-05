//
//  PDSystemRouterPlugin.m
//  PDRouter
//
//  Created by liang on 2019/5/29.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDSystemRouterPlugin.h"

@implementation PDSystemRouterPlugin

#pragma mark - Override Methods
- (void)load {
    // Do nothing...
}

- (BOOL)openURL:(NSString *)encodedURLString params:(NSDictionary *)params {
    NSURL *URL = [NSURL URLWithString:encodedURLString];
    if ([self canOpenURL:URL]) {
        [self openURL:URL];
        return YES;
    }
    return NO;
}

#pragma mark - Tool Methods
- (BOOL)canOpenURL:(NSURL *)URL {
    return [[UIApplication sharedApplication] canOpenURL:URL];
}

- (void)openURL:(NSURL *)URL {
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

@end
