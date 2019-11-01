//
//  PDRouter.m
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDRouter.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/getsect.h>
#import "PDRouterPlugin.h"

@interface NSURL (_PDAdd)

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *queryItems;

@end

@implementation NSURL (_PDAdd)

- (NSDictionary <NSString *, NSString *>*)queryItems {
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    NSArray<NSURLQueryItem *> *queryItems = components.queryItems;
    NSMutableDictionary<NSString *, id> *queryDict = [NSMutableDictionary dictionary];
    
    for (NSURLQueryItem *item in queryItems) {
        if (!item.name.length/* || !item.value*/) continue;
        [queryDict setValue:item.value forKey:item.name];
    }
    return [queryDict copy];
}

@end

@interface NSString (_PDAdd)

- (NSString *)encodeWithURLQueryAllowedCharacterSet;
- (BOOL)isValidURL;

@end

@implementation NSString (_PDAdd)

- (NSString *)encodeWithURLQueryAllowedCharacterSet {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (BOOL)isValidURL {
    NSString *regex = @"[a-zA-z]+://[^\\s]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

@end

@interface PDRouter () {
    NSMutableArray<__kindof PDRouterPlugin *> *_plugins;
    NSMutableDictionary<NSString *, void (^)(NSDictionary * _Nullable)> *_listeners;
}

@end

@implementation PDRouter

static PDRouter *__globalRouter;

+ (PDRouter *)globalRouter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!__globalRouter) {
            __globalRouter = [[self alloc] init];
        }
    });
    return __globalRouter;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!__globalRouter) {
            __globalRouter = [super allocWithZone:zone];
        }
    });
    return __globalRouter;
}

- (void)dealloc {
    for (PDRouterPlugin *plugin in _plugins) {
        [plugin unload];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _plugins = [NSMutableArray array];
        _listeners = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)collectPluginsWithPluginNames:(NSArray<NSString *> *)pluginNames {
    for (NSString *pluginName in pluginNames) {
        [self collectPluginWithPluginName:pluginName];
    }
}

- (void)collectPluginWithPluginName:(NSString *)pluginName {
    if (!pluginName.length) { return; }
    
    Class pluginClass = NSClassFromString(pluginName);
    if (!pluginClass) { return; }
    
    PDRouterPlugin *plugin = [[pluginClass alloc] init];
    plugin.navigationController = self.navigationController;
    plugin.router = self;
    [plugin load];

    [_plugins addObject:plugin];
}

#pragma mark - Public Methods
- (void)inject:(NSString *)urlString eventHandler:(void (^)(NSDictionary * _Nullable))eventHandler {
    NSAssert(urlString != nil, @"Param urlString can not be nil!");
    
    if (urlString.isValidURL) {
        // Format URL
        NSURL *URL = [NSURL URLWithString:[urlString encodeWithURLQueryAllowedCharacterSet]];
        
        urlString = [NSString stringWithFormat:@"%@://%@%@",
                     URL.scheme ?: @"",
                     URL.host ?: @"",
                     URL.path ?: @""];
    }
    
    [_listeners setValue:[eventHandler copy] forKey:urlString];
}

- (BOOL)openURL:(NSString *)urlString params:(NSDictionary *)params {    
    /** Invalid URL **/
    if (!urlString.isValidURL) {
        void (^eventHandler)(NSDictionary *) = _listeners[urlString];
        
        if (!eventHandler) { // Match eventHandler failed
            return [self tryOpenNotRecognizedURL:urlString params:params];
        }
        
        eventHandler(params); // Match eventHandler success
        
        if ([self.delegate respondsToSelector:@selector(didFinishOpenURL:params:)]) {
            [self.delegate didFinishOpenURL:urlString params:params];
        }
        return YES;
    }
    
    /** Valid URL **/
    NSURL *URL = [NSURL URLWithString:[urlString encodeWithURLQueryAllowedCharacterSet]];
    
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
        return [self tryOpenNotRecognizedURL:urlString params:params];
    }
    
    NSMutableDictionary *throwParams = [NSMutableDictionary dictionary];
    [throwParams addEntriesFromDictionary:params ?: @{}];
    [throwParams addEntriesFromDictionary:URL.queryItems];
    eventHandler(throwParams);
    
    if ([self.delegate respondsToSelector:@selector(didFinishOpenURL:params:)]) {
        [self.delegate didFinishOpenURL:urlString params:params];
    }
    return YES;
}

#pragma mark - Private Methods
- (BOOL)tryOpenNotRecognizedURL:(NSString *)urlString params:(NSDictionary *)params {
    
    NSString *encodedURLString = [urlString encodeWithURLQueryAllowedCharacterSet];
    
    for (PDRouterPlugin *plugin in _plugins) {
        if ([plugin openURL:encodedURLString params:params]) {
            if ([self.delegate respondsToSelector:@selector(didFinishOpenURL:params:)]) {
                [self.delegate didFinishOpenURL:urlString params:params];
            }
            return YES;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didFailOpenURL:params:)]) {
        [self.delegate didFailOpenURL:urlString params:params];
    }
    return NO;
}

#pragma mark - Setter Methods
- (void)setNavigationController:(__kindof UINavigationController *)navigationController {
    _navigationController = navigationController;
    
    for (PDRouterPlugin *plugin in _plugins) {
        plugin.navigationController = navigationController;
    }
}

@end
