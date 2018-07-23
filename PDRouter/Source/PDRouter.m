//
//  PDRouter.m
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDRouter.h"

@interface NSURL (PDAdd)

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *queryItems;

@end

@implementation NSURL (PDAdd)

- (NSDictionary <NSString *, NSString *>*)queryItems {
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    NSArray<NSURLQueryItem *> *queryItems = components.queryItems;
    NSMutableDictionary<NSString *, id> *queryDict = [NSMutableDictionary dictionary];
    
    for (NSURLQueryItem *item in queryItems) {
        if (!item.name.length || !item.value) continue;
        [queryDict setObject:item.value forKey:item.name];
    }
    return [queryDict copy];
}

@end

@interface PDRouter () {
    struct {
        unsigned didFinishOpenURL : 1;
        unsigned didFailOpenURL : 1;
    } _delegateHas;
}

@property (nonatomic, strong) NSMutableDictionary<NSString *, PDRouterEventHandler> *listeners;

@end

@implementation PDRouter

static PDRouter *__defaultRouter = nil;

+ (PDRouter *)defaultRouter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (__defaultRouter == nil) {
            __defaultRouter = [[self alloc] init];
        }
    });
    return __defaultRouter;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (__defaultRouter == nil) {
            __defaultRouter = [super allocWithZone:zone];
        }
    });
    return __defaultRouter;
}

#pragma mark - Event Handler Methods
- (void)on:(NSString *)fullPath eventHandler:(PDRouterEventHandler)eventHandler {
    NSAssert(fullPath != nil, @"Param fullPath can not be nil!");
    [self.listeners setValue:[eventHandler copy] forKey:fullPath];
}

- (void)onGroup:(NSString *)basePath eventHandler:(void (^)(PDRouterGroup *))eventHandler {
    NSAssert(basePath != nil, @"Param basePath can not be nil!");
    
    PDRouterGroup *group = [[PDRouterGroup alloc] init];
    
    if (eventHandler) eventHandler(group);
    
    NSArray<NSString *> *allKeys = [group.listeners allKeys];
    
    for (NSString *relativePath in allKeys) {
        NSString *fullPath = [basePath stringByAppendingString:relativePath];
        void (^handler)(NSDictionary *) = group.listeners[relativePath];
        [self.listeners setValue:handler forKey:fullPath];
    }
}

- (BOOL)openURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSString *host = [NSString stringWithFormat:@"%@://%@", URL.scheme, URL.host];
    if (![host isEqualToString:self.host]) {
        [self didFailOpenURL:URLString routerParams:routerParams];
        return NO;
    }

    NSString *path = URL.path;
    void (^eventHandler)(NSDictionary *) = self.listeners[path];
    if (!eventHandler) {
        [self didFailOpenURL:URLString routerParams:routerParams];
        return NO;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:routerParams ?: @{}];
    [params addEntriesFromDictionary:URL.queryItems];
    
    eventHandler(params);
    [self didFinishOpenURL:URLString routerParams:routerParams];
    return YES;
}

#pragma mark - Throw Out Methods
- (void)didFinishOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    if (_delegateHas.didFinishOpenURL) {
        [self.delegate didFinishOpenURL:URLString routerParams:routerParams];
    }
}

- (void)didFailOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    if (_delegateHas.didFailOpenURL) {
        [self.delegate didFailOpenURL:URLString routerParams:routerParams];
    }
}

#pragma mark - Setter Methods
- (void)setDelegate:(id<PDRouterDelegate>)delegate {
    _delegate = delegate;
    
    _delegateHas.didFinishOpenURL = [_delegate respondsToSelector:@selector(didFinishOpenURL:routerParams:)];
    _delegateHas.didFailOpenURL = [_delegate respondsToSelector:@selector(didFailOpenURL:routerParams:)];
}

#pragma mark - Getter Methods
- (NSMutableDictionary<NSString *, PDRouterEventHandler> *)listeners {
    if (!_listeners) {
        _listeners = [NSMutableDictionary dictionary];
    }
    return _listeners;
}

@end
