//
//  PDRouterHelper.m
//  PDRouter
//
//  Created by liang on 2018/3/4.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDRouterHelper.h"
#import "PDWebViewController.h"
#import "AppDelegate.h"

@implementation PDRouterHelper

+ (PDRouterHelper *)defaultHelper {
    static PDRouterHelper *routerHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routerHelper = [[self alloc] init];
    });
    return routerHelper;
}

- (BOOL)isUrlInWhiteList:(NSURL *)url {
    if (!url || !url.absoluteString.length) return NO;
    
    if (![url.scheme isEqualToString:@"http"] &&
        ![url.scheme isEqualToString:@"https"]) {
        return NO;
    }
    // URL path check...
    // Other URL checks...
    return YES;
}

#pragma mark - PDRouterProtocol Methods
- (BOOL)openURL:(NSURL *)url {
    if (![self isUrlInWhiteList:url]) return NO;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navigationController = (UINavigationController *)appDelegate.window.rootViewController;

    PDWebViewController *webVC = [[PDWebViewController alloc] init];
    [navigationController pushViewController:webVC animated:YES];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webVC loadRequest:request];
    return YES;
}

@end
