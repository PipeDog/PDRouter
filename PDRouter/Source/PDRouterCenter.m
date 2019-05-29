//
//  PDRouterCenter.m
//  PDRouter
//
//  Created by liang on 2019/5/17.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDRouterCenter.h"

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

@implementation PDRouterCenter {
    NSMutableDictionary<NSString *, PDRouterCenterEventHandler> *_listeners;
}

+ (PDRouterCenter *)defaultCenter {
    static PDRouterCenter *__defaultCenter;
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
- (void)inject:(NSString *)pattern eventHandler:(PDRouterCenterEventHandler)eventHandler {
    NSAssert(pattern != nil, @"Param pattern can not be nil!");
    
    if (pattern.isValidURL) {
        // Format URL
        NSURL *URL = [NSURL URLWithString:[[pattern copy] encodeWithURLQueryAllowedCharacterSet]];
        
        pattern = [NSString stringWithFormat:@"%@://%@%@",
                   URL.scheme ?: @"",
                   URL.host ?: @"",
                   URL.path ?: @""];
    }
    
    [_listeners setValue:[eventHandler copy] forKey:pattern];
}

- (BOOL)openURL:(NSString *)URLString params:(NSDictionary *)params {
    
    /** Invalid URL **/
    if (!URLString.isValidURL) {
        void (^eventHandler)(NSDictionary *) = _listeners[URLString];
        
        if (!eventHandler) { // Match eventHandler failed
            return [self tryOpenNotRecognizedURL:URLString params:params];
        }
        
        eventHandler(params); // Match eventHandler success
        
        [self didFinishOpenURL:URLString params:params];
        return YES;
    }
    
    /** Valid URL **/
    NSURL *URL = [NSURL URLWithString:[URLString encodeWithURLQueryAllowedCharacterSet]];

    // scheme://host + path
    NSString *noQueriesURLString = [NSString stringWithFormat:@"%@://%@%@",
                                    URL.scheme ?: @"",
                                    URL.host ?: @"",
                                    URL.path ?: @""];
    
    void (^eventHandler)(NSDictionary *) = _listeners[noQueriesURLString];
    
    if (!eventHandler) {
        // scheme://host
        noQueriesURLString = [noQueriesURLString substringToIndex:(noQueriesURLString.length - URL.path.length)];
        eventHandler = _listeners[noQueriesURLString];
    }
    
    if (!eventHandler) {
        return [self tryOpenNotRecognizedURL:URLString params:params];
    }
    
    NSMutableDictionary *throwParams = [NSMutableDictionary dictionary];
    [throwParams addEntriesFromDictionary:params ?: @{}];
    [throwParams addEntriesFromDictionary:URL.queryItems];
    eventHandler(throwParams);
    
    [self didFinishOpenURL:URLString params:params];
    return YES;
}

#pragma mark - Private Methods
- (BOOL)tryOpenNotRecognizedURL:(NSString *)URLString params:(NSDictionary *)params {
    BOOL result = NO;
    
    if ([self.delegate respondsToSelector:@selector(tryOpenNotRecognizedURL:params:)]) {
        result = [self.delegate tryOpenNotRecognizedURL:URLString params:params];
    }
    
    if (result) {
        [self didFinishOpenURL:URLString params:params];
    } else {
        [self didFailOpenURL:URLString params:params];
    }
    return result;
}

- (void)didFinishOpenURL:(NSString *)URLString params:(NSDictionary *)params {
    if ([self.delegate respondsToSelector:@selector(didFinishOpenURL:params:)]) {
        [self.delegate didFinishOpenURL:URLString params:params];
    }
}

- (void)didFailOpenURL:(NSString *)URLString params:(NSDictionary *)params {
    if ([self.delegate respondsToSelector:@selector(didFailOpenURL:params:)]) {
        [self.delegate didFailOpenURL:URLString params:params];
    }
}

@end
