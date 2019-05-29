//
//  PDSystemRouterPlugin.m
//  PDRouter
//
//  Created by 雷亮 on 2019/5/29.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDSystemRouterPlugin.h"

@implementation PDSystemRouterPlugin

- (BOOL)openURL:(NSString *)encodedURLString params:(NSDictionary *)params {
    NSURL *URL = [NSURL URLWithString:encodedURLString];

    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        if (@available(iOS 10, *)) {
            [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:URL];
        }
        return YES;
    }
    
    return NO;
}

@end
