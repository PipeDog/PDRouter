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
    static PDRouter *__defaultRouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultRouter = [[self alloc] init];
    });
    return __defaultRouter;
}

#pragma mark - Send Action Methods
- (BOOL)sendAction:(NSString *)action {
    return [self sendAction:action params:nil];
}

- (BOOL)sendAction:(NSString *)action params:(NSDictionary *)params {
    return [self sendAction:action params:params from:nil];
}

- (BOOL)sendAction:(NSString *)action params:(NSDictionary *)params from:(id)sender {    
    if (!action.length) return NO;
    
    NSURL *URL = [NSURL URLWithString:action];
    NSString *path = URL.path; // eventname, eg: "/push"
    
    if ([action hasPrefix:self.host]) { // Matching host.
        // Check whether the event has been registered, and has handler.
        BOOL hasHandlers = [self containsEvent:path];
        
        if (hasHandlers) {
            // The event has been registered.
            NSMutableArray<PDRouterHandler> *handlers = self.listeners[path];
            
            NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
            [paramsDict addEntriesFromDictionary:params ?: @{}];
            [paramsDict addEntriesFromDictionary:URL.queryItems];
            
            NSDictionary *paramsCopy = [paramsDict copy];
            
            for (PDRouterHandler handler in handlers) {
                if (handler) handler(sender, paramsCopy);
            }
            return YES;
        } else {
            // The event has not yet been registered.
            BOOL result = [self openURL:URL];
            if (!result) NSLog(@"Can not open url, url = %@", URL);
            return result;
        }
    } else { // Other url.
        BOOL result = [self openURL:URL];
        if (!result) NSLog(@"Can not open url, url = %@", URL);
        return result;
    }
}

- (BOOL)openURL:(NSURL *)url {
    if ([self.delegate conformsToProtocol:@protocol(PDRouterDelegate)] ||
        [self.delegate respondsToSelector:@selector(openURL:)]) {
        return [self.delegate openURL:url];
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
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
    
    [_listeners removeObjectForKey:event];
}

- (void)offAll {
    [_listeners removeAllObjects];
}

- (BOOL)hasEvent:(NSString *)event {
    return [self containsEvent:event];
}

- (BOOL)containsEvent:(NSString *)event {
    if (!event.length) return NO;
    
    NSMutableArray *handlers = _listeners[event];
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
