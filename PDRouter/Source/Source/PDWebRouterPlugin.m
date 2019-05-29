//
//  PDWebRouterPlugin.m
//  PDRouter
//
//  Created by 雷亮 on 2019/5/29.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDWebRouterPlugin.h"
#import "PDWebPage.h"

@implementation PDWebRouterPlugin

- (BOOL)isValidURL:(NSString *)URLString {
    NSString *regex = @"[a-zA-z]+://[^\\s]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:URLString];
}

- (BOOL)openURL:(NSString *)encodedURLString params:(NSDictionary *)params {
    if ([self isValidURL:encodedURLString]) {
        PDWebPage *webPage = [[PDWebPage alloc] init];
        
        NSAssert(self.navigationController != nil, @"Property navigationController can not be nil.");
        [self.navigationController pushViewController:webPage animated:YES];
        
        NSURL *URL = [NSURL URLWithString:encodedURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [webPage loadRequest:request];
        return YES;
    }
    return NO;
}

@end
