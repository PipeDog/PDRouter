//
//  PDRouter.m
//  PDRouter
//
//  Created by liang on 2018/3/3.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDRouter.h"
#import "NSURL+PDAdd.h"

@interface PDRouter ()

/*
 @eg:
    listeners :
    {
        event1: [handler1, handler2, ...],
        event2: [handler1, handler2, ...],
        ...
    }
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<PDRouterHandler> *> *listeners;

@end

@implementation PDRouter

- (void)dealloc {
    [self offAll];
}

+ (PDRouter *)defaultRouter {
    static PDRouter *defaultRouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRouter = [[self alloc] init];
    });
    return defaultRouter;
}

#pragma mark - Send Action Methods
- (void)sendAction:(NSString *)action {
    [self sendAction:action to:nil];
}

- (void)sendAction:(NSString *)action to:(nullable id)target {
    if (!action.length) return;

    // Matching order
    //   1. scheme://event/query
    //   2. unregistered url.

    NSURL *URL = [NSURL URLWithString:action];
    NSString *scheme = URL.scheme;
    NSString *host = URL.host; // event
    NSString __unused *path = URL.path;
    NSString __unused *query = URL.query;
    
    if ([scheme isEqualToString:self.localScheme]) { // Matching scheme.
        // Check whether the event has been registered, and has handler.
        BOOL hasHandlers = [self containsEvent:host];
        
        if (hasHandlers) {
            // The event has been registered.
            NSMutableArray<PDRouterHandler> *handlers = self.listeners[host];

            for (PDRouterHandler handler in handlers) {
                if (handler) handler(target, URL.queryItems);
            }
        } else {
            // The event has not yet been registered.
            BOOL result = [self openURL:URL];
            if (!result) NSLog(@"Can not open url, url = %@", URL);
        }
    } else { // Other url.
        BOOL result = [self openURL:URL];
        if (!result) NSLog(@"Can not open url, url = %@", URL);
    }
}

- (BOOL)openURL:(NSURL *)url {
    if ([self.delegate conformsToProtocol:@protocol(PDRouterProtocol)] ||
        [self.delegate respondsToSelector:@selector(openURL:)]) {
        return [self.delegate openURL:url];
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
#ifdef __IPHONE_10_0
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
#else
        [[UIApplication sharedApplication] openURL:url];
#endif
        return YES;
    }
    return NO;
}

#pragma mark - Register Event Methods
- (void)on:(NSString *)event completionHandler:(PDRouterHandler)handler {
    if (!event.length) return;
    
    NSMutableArray<PDRouterHandler> *handlers = self.listeners[event];
    if (!handlers) {
        handlers = [NSMutableArray array];
        [self.listeners setObject:handlers forKey:event];
    }
    
    if (handler) [handlers addObject:handler];
}

- (void)off:(NSString *)event {
    if (!event.length) return;
    
    [self.listeners removeObjectForKey:event];
}

- (void)offAll {
    [self.listeners removeAllObjects];
}

- (BOOL)containsEvent:(NSString *)event {
    if (!event.length) return NO;
    
    NSMutableArray *handlers = self.listeners[event];
    return (handlers.count > 0 ? YES : NO);
}

#pragma mark - Getter Methods
- (NSMutableDictionary<NSString *, NSMutableArray<PDRouterHandler> *> *)listeners {
    if (!_listeners) {
        _listeners = [NSMutableDictionary dictionary];
    }
    return _listeners;
}

@end
