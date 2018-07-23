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
#import "PDRouter+PDAdd.h"

#define PDRouterHost @"pdog://net.pipedog.com"

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
        [[PDRouter defaultRouter] registerEvents];
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
    
    [[PDRouter defaultRouter] on:event actionHandler:^(id  _Nullable sender, NSDictionary * _Nullable params) {
        PDPage *page = (PDPage *)[[[pageClass class] alloc] init];
        page.routerParams = params;
        [self.navigationController pushViewController:page animated:YES];
    }];
}

- (void)openPage:(Class)pageClass params:(NSDictionary *)params {
    if (!isKindOfClass([PDPage class], [pageClass class])) {
        NSAssert(NO, @"Param pageClass must be child class for PDPage!");
        return;
    }
    
    NSString *event = [NSString stringWithFormat:@"%@/%@", PDRouterHost, NSStringFromClass([pageClass class])];
    [[PDRouter defaultRouter] sendAction:event params:params];
}

#pragma mark - PDRouterDelegate Methods
- (BOOL)openURL:(NSURL *)url params:(NSDictionary *)params {
    if ([url.absoluteString hasPrefix:@"http"]) {
        PDWebPage *webPage = [[PDWebPage alloc] init];
        [self.navigationController pushViewController:webPage animated:YES];
        
        [webPage loadRequest:[NSURLRequest requestWithURL:url]];
        return YES;
    }
    return NO;
}

#pragma mark - Setter Methods
- (void)setNavigationController:(UINavigationController *)navigationController {
    NSAssert(navigationController != nil, @"Param navigationController can not be nil!");
    _navigationController = navigationController;
}

@end
