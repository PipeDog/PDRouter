//
//  PDRouteCenter.m
//  PDRouter
//
//  Created by liang on 2019/5/17.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDRouteCenter.h"

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

@interface NSString (PDAdd)

- (NSString *)encodeWithURLQueryAllowedCharacterSet;
- (BOOL)isValidURL;

@end

@implementation NSString (PDAdd)

- (NSString *)encodeWithURLQueryAllowedCharacterSet {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (BOOL)isValidURL {
    NSString *regex = @"[a-zA-z]+://[^\\s]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

@end

@implementation PDRouteCenter {
    struct {
        unsigned tryOpenUnregisteredURL : 1;
        unsigned didFinishOpenURL : 1;
        unsigned didFailOpenURL : 1;
    } _delegateHas;
    
    NSMutableDictionary<NSString *, PDRouteCenterEventHandler> *_listeners;
}

+ (PDRouteCenter *)defaultCenter {
    static PDRouteCenter *__defaultCenter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultCenter = [[self alloc] init];
    });
    return __defaultCenter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _listeners = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Public Methods
- (void)on:(NSString *)pattern eventHandler:(PDRouteCenterEventHandler)eventHandler {
    NSAssert(pattern != nil, @"Param pattern can not be nil!");
    
    if (pattern.isValidURL) {
        // Format URL
        NSURL *URL = [NSURL URLWithString:[[pattern copy] encodeWithURLQueryAllowedCharacterSet]];
        
        pattern = [NSString stringWithFormat:@"%@://%@", URL.scheme, URL.host];
        pattern = [pattern stringByAppendingString:URL.path ?: @""];
    }
    
    [_listeners setValue:[eventHandler copy] forKey:pattern];
}

- (BOOL)openURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    
    NSURL *URL = [NSURL URLWithString:[URLString encodeWithURLQueryAllowedCharacterSet]];
    
    if (!URLString.isValidURL) { // Invalid URL
        void (^eventHandler)(NSDictionary *) = _listeners[URLString];
        
        if (!eventHandler) { // Match eventHandler failed
            return [self tryOpenUnregisteredURL:URLString routerParams:routerParams];
        }
        
        eventHandler(routerParams); // Match eventHandler success
        
        [self didFinishOpenURL:URLString routerParams:routerParams];
        return YES;
    }
    
    // Valid URL
    // scheme://host
    NSString *noQueriesURLString = [NSString stringWithFormat:@"%@://%@", URL.scheme, URL.host];
    void (^eventHandler)(NSDictionary *) = _listeners[noQueriesURLString];
    
    if (!eventHandler) {
        // scheme://host + path
        noQueriesURLString = [noQueriesURLString stringByAppendingString:URL.path ?: @""];
        eventHandler = _listeners[noQueriesURLString];
    }
    
    if (!eventHandler) {
        return [self tryOpenUnregisteredURL:URLString routerParams:routerParams];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:routerParams ?: @{}];
    [params addEntriesFromDictionary:URL.queryItems];
    
    eventHandler(params);
    
    [self didFinishOpenURL:URLString routerParams:routerParams];
    return YES;
}

#pragma mark - Private Methods
- (BOOL)tryOpenUnregisteredURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    BOOL result = NO;
    
    if (_delegateHas.tryOpenUnregisteredURL) {
        result = [self.delegate tryOpenUnregisteredURL:URLString routerParams:routerParams];
    }
    
    if (result) {
        [self didFinishOpenURL:URLString routerParams:routerParams];
    } else {
        [self didFailOpenURL:URLString routerParams:routerParams];
    }
    return result;
}

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
- (void)setDelegate:(id<PDRouteCenterDelegate>)delegate {
    _delegate = delegate;
    
    _delegateHas.tryOpenUnregisteredURL = [_delegate respondsToSelector:@selector(tryOpenUnregisteredURL:routerParams:)];
    _delegateHas.didFinishOpenURL = [_delegate respondsToSelector:@selector(didFinishOpenURL:routerParams:)];
    _delegateHas.didFailOpenURL = [_delegate respondsToSelector:@selector(didFailOpenURL:routerParams:)];
}

@end
