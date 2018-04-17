//
//  PDRouteKeeper.m
//  PDRouter
//
//  Created by liang on 2018/4/17.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDRouteKeeper.h"
#import "PDWebViewController.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

static inline BOOL isKindOfClass(Class parent, Class child) {
    for (Class cls = child; cls; cls = class_getSuperclass(cls)) {
        if (cls == parent) {
            return YES;
        }
    }
    return NO;
}

@interface PDRouteKeeper ()

@property (nonatomic, copy) PDRouterHandler handler;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *pages;

@end

@implementation PDRouteKeeper

+ (PDRouteKeeper *)defaultKeeper {
    static PDRouteKeeper *__defaultKeeper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultKeeper = [[self alloc] init];
    });
    return __defaultKeeper;
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

#pragma mark - Bind Methods
- (void)bind:(NSString *)pageName forEvent:(NSString *)event {
    if (!pageName.length || !event.length) return;

    Class cls = NSClassFromString(pageName);
    
    if (cls && isKindOfClass([UIViewController class], [cls class])) {
        [self.pages setObject:pageName forKey:event];
    }
}

- (void)unbind:(NSString *)event {
    if (!event.length) return;

    [self.pages removeObjectForKey:event];
}

#pragma mark - Handle OpenURL Methods
- (BOOL)sendAction:(NSString *)action {
    return [self sendAction:action params:nil];
}

- (BOOL)sendAction:(NSString *)action params:(NSDictionary *)params {
    return [self sendAction:action params:params from:nil];
}

- (BOOL)sendAction:(NSString *)action params:(NSDictionary *)params from:(id)sender {
    if (!action.length) return NO;

    BOOL success = [[PDRouter defaultRouter] sendAction:action params:params from:sender];
    if (success) return success;

    NSURL *URL = [NSURL URLWithString:action];
    NSString *path = URL.path;
    
    BOOL isRouterHost = [action hasPrefix:[PDRouter defaultRouter].host];
    BOOL eventHasRegisted = [[PDRouter defaultRouter] hasEvent:path];
    BOOL hasBindPageForEvent = (self.pages[path] ? YES : NO);
    
    if (isRouterHost && !eventHasRegisted && hasBindPageForEvent) {
        [[PDRouter defaultRouter] on:path completionHandler:^(id  _Nullable sender, NSDictionary * _Nullable params) {
            NSString *pageName = self.pages[path];
            Class cls = NSClassFromString(pageName);
            UIViewController *page = [[cls alloc] init];
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UINavigationController *navigationController = (UINavigationController *)appDelegate.window.rootViewController;
            [navigationController pushViewController:page animated:YES];
        }];
        
        return [[PDRouter defaultRouter] sendAction:action params:params from:sender];
    }
    return NO;
}

#pragma mark - Getter Methods
- (NSMutableDictionary<NSString *, NSString *> *)pages {
    if (!_pages) {
        _pages = [NSMutableDictionary dictionary];
    }
    return _pages;
}

@end
