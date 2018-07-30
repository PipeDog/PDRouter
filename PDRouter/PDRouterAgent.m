//
//  PDRouterAgent.m
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDRouterAgent.h"
#import <objc/runtime.h>
#import "PDPage.h"
#import "PDWebPage.h"
#import "PDRouter.h"

static inline BOOL isKindOfClass(Class parent, Class child) {
    for (Class cls = child; cls; cls = class_getSuperclass(cls)) {
        if (cls == parent) {
            return YES;
        }
    }
    return NO;
}

@interface PDRouterAgent () <PDRouterDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation PDRouterAgent

+ (PDRouterAgent *)defaultAgent {
    static PDRouterAgent *__defaultAgent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultAgent = [[self alloc] init];
    });
    return __defaultAgent;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [PDRouter defaultRouter].delegate = self;
        [PDRouter defaultRouter].host = @"pdog://net.pipedog.com";
    }
    return self;
}

- (void)registerPage:(Class)pageClass {
    if (!isKindOfClass([PDPage class], [pageClass class])) {
        NSAssert(NO, @"Param pageClass must be child class for PDPage!");
        return;
    }
    
    // Format to url path.
    NSString *event = [NSString stringWithFormat:@"/%@", NSStringFromClass([pageClass class])];
    
    [[PDRouter defaultRouter] on:event eventHandler:^(NSDictionary *routerParams) {
        PDPage *page = (PDPage *)[[[pageClass class] alloc] init];
        page.routerParams = routerParams;
        [self.navigationController pushViewController:page animated:YES];
    }];
}

- (void)openPage:(Class)pageClass params:(NSDictionary *)params {
    if (!isKindOfClass([PDPage class], [pageClass class])) {
        NSAssert(NO, @"Param pageClass must be child class for PDPage!");
        return;
    }
    
    NSString *event = [NSString stringWithFormat:@"%@/%@", PDRouterHost, NSStringFromClass([pageClass class])];
    [[PDRouter defaultRouter] openURL:event routerParams:params];
}

#pragma mark - PDRouterDelegate Methods
- (void)didFinishOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    NSLog(@"didFinishOpenURL, args = [%@, %@]", URLString, routerParams);
}

- (void)didFailOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    NSLog(@"didFailOpenURL, args = [%@, %@]", URLString, routerParams);
    
    if ([URLString hasPrefix:@"http"]) {
        PDWebPage *webPage = [[PDWebPage alloc] init];
        [self.navigationController pushViewController:webPage animated:YES];
        
        [webPage loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]]];
    } else {
        NSLog(@"Not registered yet.");
    }
}

#pragma mark - Setter Methods
- (void)setNavigationController:(UINavigationController *)navigationController {
    _navigationController = navigationController;
}

@end
