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

@interface PDRouter () <PDRouterCenterDelegate> {
    NSArray<PDRouterPlugin *> *_plugins;
}

@property (nonatomic, strong) PDRouterCenter *routerCenter;

@end

@implementation PDRouter

static PDRouter *__globalRouter;

+ (PDRouter *)globalRouter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __globalRouter = [[self alloc] init];
    });
    return __globalRouter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _plugins = [NSMutableArray array];
        _routerCenter = [PDRouterCenter defaultCenter];
        _routerCenter.delegate = self;
        
        [self collectPlugins];
    }
    return self;
}

- (void)collectPlugins {
    NSMutableArray<PDRouterPlugin *> *plugins = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [self loadPlugin:^(NSString *classname) {
        
        Class pluginClass = NSClassFromString(classname);
        PDRouterPlugin *plugin = [[pluginClass alloc] init];
        plugin.navigationController = weakSelf.navigationController;
        plugin.router = weakSelf;
        [plugin load];

        [plugins addObject:plugin];
    }];
    
    _plugins = [plugins copy];
}

- (void)loadPlugin:(void (^)(NSString *classname))registerHandler {
    Dl_info info; dladdr(&__globalRouter, &info);
    
#ifdef __LP64__
    uint64_t addr = 0; const uint64_t mach_header = (uint64_t)info.dli_fbase;
    const struct section_64 *section = getsectbynamefromheader_64((void *)mach_header, "__DATA", "pd_exp_plugin");
#else
    uint32_t addr = 0; const uint32_t mach_header = (uint32_t)info.dli_fbase;
    const struct section *section = getsectbynamefromheader((void *)mach_header, "__DATA", "pd_exp_plugin");
#endif
    
    if (section == NULL)  return;
    
    for (addr = section->offset; addr < section->offset + section->size; addr += sizeof(PDRouterPluginName)) {
        PDRouterPluginName *plugin = (PDRouterPluginName *)(mach_header + addr);
        if (!plugin) continue;
        
        NSString *classname = [NSString stringWithUTF8String:plugin->classname];
        !registerHandler ?: registerHandler(classname);
    }
}

#pragma mark - Public Methods
- (BOOL)openURL:(NSString *)URLString params:(NSDictionary *)params {
    return [self.routerCenter openURL:URLString params:params];
}

- (void)registerEventHandler:(PDRouterCenterEventHandler)eventHandler forPattern:(NSString *)pattern {
    [self.routerCenter inject:pattern eventHandler:eventHandler];
}

#pragma mark - PDRouterDelegate Methods
- (BOOL)tryOpenNotRecognizedURL:(NSString *)URLString params:(NSDictionary *)params {
    if (!URLString.length) { return NO; }

    NSCharacterSet *charSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodedURLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    
    for (PDRouterPlugin *plugin in _plugins) {
        if ([plugin openURL:encodedURLString params:params]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)didFinishOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    NSLog(@"✌️✌️✌️didFinishOpenURL, args = [%@, %@]", URLString, routerParams);
}

- (void)didFailOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams {
    NSLog(@"❌❌❌didFailOpenURL, args = [%@, %@]", URLString, routerParams);
}

#pragma mark - Setter Methods
- (void)setNavigationController:(__kindof UINavigationController *)navigationController {
    _navigationController = navigationController;
    
    for (PDRouterPlugin *plugin in _plugins) {
        plugin.navigationController = navigationController;
    }
}

@end
