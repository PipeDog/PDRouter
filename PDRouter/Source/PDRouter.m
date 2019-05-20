//
//  PDRouter.m
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDRouter.h"
#import "PDWebPage.h"
#import "PDPage.h"
#import <objc/runtime.h>

static NSString *httpScheme = @"http";

static inline BOOL isKindOfClass(Class parent, Class child) {
    for (Class cls = child; cls; cls = class_getSuperclass(cls)) {
        if (cls == parent) {
            return YES;
        }
    }
    return NO;
}

@interface PDRouter () <PDRouteCenterDelegate>

@property (nonatomic, strong) PDRouteCenter *routeCenter;

@end

@implementation PDRouter

+ (PDRouter *)globalRouter {
    static PDRouter *__globalRouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __globalRouter = [[self alloc] init];
    });
    return __globalRouter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _routeCenter = [PDRouteCenter defaultCenter];
        _routeCenter.delegate = self;
    }
    return self;
}

#pragma mark - Public Methods
- (BOOL)openURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    return [self.routeCenter openURL:URLString routerParams:routerParams];
}

- (void)registerClass:(Class)aClass forPattern:(NSString *)pattern {
    if (!isKindOfClass([PDPage class], aClass)) {
        NSAssert(NO, @"Param aClass must be subclass of [PDPage class].");
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.routeCenter on:pattern eventHandler:^(NSDictionary * _Nonnull routerParams) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf) {
            PDPage *page = [[aClass alloc] init];
            page.routerParams = routerParams;
            NSAssert(self.navigationController != nil, @"Property navigationController can not be nil.");
            
            if ([routerParams[@"present"] integerValue] == 1) {
                [strongSelf.navigationController presentViewController:page animated:YES completion:nil];
            } else {
                [strongSelf.navigationController pushViewController:page animated:YES];
            }
        }
    }];
}

- (void)registerEventHandler:(PDRouteCenterEventHandler)eventHandler forPattern:(NSString *)pattern {
    [self.routeCenter on:pattern eventHandler:eventHandler];
}

#pragma mark - PDRouterDelegate Methods
- (BOOL)tryOpenUnregisteredURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    if (!URLString.length) { return NO; }
    
    URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *URL = [NSURL URLWithString:URLString];
    
    if ([self openNativePage:URLString routerParams:routerParams]) {
        return YES;
    } else if ([self openWebPage:URLString routerParams:routerParams]) {
        return YES;
    } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        if (@available(iOS 10, *)) {
            [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:URL];
        }
        return YES;
    }
    return NO;
}

- (void)didFinishOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    NSLog(@"✌️✌️✌️didFinishOpenURL, args = [%@, %@]", URLString, routerParams);
}

- (void)didFailOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    NSLog(@"❌❌❌didFailOpenURL, args = [%@, %@]", URLString, routerParams);
}

#pragma mark - Private Methods
- (BOOL)openNativePage:(NSString *)pageName routerParams:(NSDictionary *)routerParams {
    
    Class aClass = NSClassFromString(pageName);
    if (!aClass) { return NO; }
    if (!isKindOfClass([PDPage class], aClass)) { return NO; }
    
    PDPage *page = [[aClass alloc] init];
    page.routerParams = routerParams;
    NSAssert(self.navigationController != nil, @"Property navigationController can not be nil.");
    
    if ([routerParams[@"present"] integerValue] == 1) {
        [self.navigationController presentViewController:page animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:page animated:YES];
    }
    
    [self registerClass:aClass forPattern:pageName];
    return YES;
}

- (BOOL)openWebPage:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    if ([URLString hasPrefix:httpScheme]) {
        PDWebPage *webPage = [[PDWebPage alloc] init];
        
        NSAssert(self.navigationController != nil, @"Property navigationController can not be nil.");
        [self.navigationController pushViewController:webPage animated:YES];
        
        URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *URL = [NSURL URLWithString:URLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [webPage loadRequest:request];
        return YES;
    }
    return NO;
}

@end
