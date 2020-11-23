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
    if (!components) { return @{}; }
    
    NSArray<NSURLQueryItem *> *queryItems = components.queryItems;
    if (!queryItems.count) { return @{}; }
    
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

- (instancetype)init {
    self = [super init];
    if (self) {
        _plugins = [NSMutableArray array];
        _listeners = [NSMutableDictionary dictionary];
        
        [self collectPlugins];
    }
    return self;
}

- (void)collectPlugins {
    NSMutableArray<PDRouterPlugin *> *plugins = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [self loadPluginWithRegisterHandler:^(NSString *pluginname, NSString *classname) {
        Class pluginClass = NSClassFromString(classname);
        PDRouterPlugin *plugin = [[pluginClass alloc] init];
        plugin.name = pluginname;
        plugin.router = weakSelf;
        [plugin load];
        
        [plugins addObject:plugin];
    }];
    
    [plugins sortUsingComparator:^NSComparisonResult(PDRouterPlugin * _Nonnull obj1, PDRouterPlugin * _Nonnull obj2) {
        return [obj1 priority] < [obj2 priority];
    }];
    
    _plugins = [plugins copy];
}

- (void)loadPluginWithRegisterHandler:(void (^)(NSString *pluginname, NSString *classname))registerHandler {
    Dl_info info; dladdr(&__globalRouter, &info);
    
#ifdef __LP64__
    uint64_t addr = 0; const uint64_t mach_header = (uint64_t)info.dli_fbase;
    const struct section_64 *section = getsectbynamefromheader_64((void *)mach_header, "__DATA", "pd_exp_plugin");
#else
    uint32_t addr = 0; const uint32_t mach_header = (uint32_t)info.dli_fbase;
    const struct section *section = getsectbynamefromheader((void *)mach_header, "__DATA", "pd_exp_plugin");
#endif
    
    if (section == NULL) { return; }
    
    for (addr = section->offset; addr < section->offset + section->size; addr += sizeof(PDRouterPluginName)) {
        PDRouterPluginName *plugin = (PDRouterPluginName *)(mach_header + addr);
        if (!plugin) { continue; }
        
        NSString *pluginname = [NSString stringWithUTF8String:plugin->pluginname];
        NSString *classname = [NSString stringWithUTF8String:plugin->classname];
        !registerHandler ?: registerHandler(pluginname, classname);
    }
}

#pragma mark - Public Methods
- (void)inject:(NSString *)urlString eventHandler:(void (^)(NSDictionary * _Nullable))eventHandler {
    NSAssert(urlString != nil, @"Param urlString can not be nil!");

    if (urlString.isValidURL) {
        NSURL *URL = [NSURL URLWithString:[urlString encodeWithURLQueryAllowedCharacterSet]];
        urlString = [self jointURLStringWithoutQueriesWithURL:URL];
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
    NSURL *URL = [NSURL URLWithString:urlString];
    if (!URL) {
        URL = [NSURL URLWithString:[urlString encodeWithURLQueryAllowedCharacterSet]];
    }

    NSString *noQueriesURLString = [self jointURLStringWithoutQueriesWithURL:URL];
    void (^eventHandler)(NSDictionary *) = _listeners[noQueriesURLString];

    if (!eventHandler) { // Match eventHandler failed
        return [self tryOpenNotRecognizedURL:urlString params:params];
    }
    
    // Match eventHandler success
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
    if (!urlString.length) {
        return NO;
    }

    for (PDRouterPlugin *plugin in _plugins) {
        if ([plugin openURL:urlString params:params]) {
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

- (NSString *)jointURLStringWithoutQueriesWithURL:(NSURL *)URL {
    if (!URL || !URL.absoluteString.length) {
        return @"";
    }
    
    // scheme://host[:port] + path
    NSMutableString *noQueriesURLString = [NSMutableString string];
    [noQueriesURLString appendFormat:@"%@", URL.scheme ?: @""];
    [noQueriesURLString appendString:@"://"];
    [noQueriesURLString appendFormat:@"%@", URL.host ?: @""];

    if (URL.port) {
        [noQueriesURLString appendFormat:@":%lu", (unsigned long)[URL.port unsignedIntegerValue]];
    }

    [noQueriesURLString appendFormat:@"%@", URL.path ?: @""];
    return [noQueriesURLString copy];
}

#pragma mark - Setter Methods
- (void)setNavigationController:(__kindof UINavigationController *)navigationController {
    _navigationController = navigationController;
    
    for (PDRouterPlugin *plugin in _plugins) {
        plugin.navigationController = navigationController;
    }
}

@end
