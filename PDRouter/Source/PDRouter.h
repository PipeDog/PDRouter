//
//  PDRouter.h
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PDRouterEventHandler)(NSDictionary * _Nullable params);

typedef struct {
    const char *pluginname;
    const char *classname;
} PDRouterPluginName;

/* Export plugin */
#define __PD_EXPORT_ROUTER_PLUGIN_EXT(pluginname, classname) \
__attribute__((used, section("__DATA , pd_exp_plugin"))) \
static const PDRouterPluginName __pd_exp_plugin_##pluginname##__ = {#pluginname, #classname};

#define PD_EXPORT_ROUTER_PLUGIN(classname) __PD_EXPORT_ROUTER_PLUGIN_EXT(classname, classname)

@protocol PDRouterDelegate <NSObject>

@optional
- (void)didFinishOpenURL:(NSString *)urlString params:(NSDictionary * _Nullable)params;
- (void)didFailOpenURL:(NSString *)urlString params:(NSDictionary * _Nullable)params;

@end

@interface PDRouter : NSObject

@property (class, strong, readonly) PDRouter *globalRouter;

@property (nonatomic, weak) __kindof UINavigationController *navigationController;
@property (nonatomic, weak) id<PDRouterDelegate> delegate;

- (void)inject:(NSString *)urlString eventHandler:(PDRouterEventHandler)eventHandler;
- (BOOL)openURL:(NSString *)urlString params:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
