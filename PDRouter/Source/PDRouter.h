//
//  PDRouter.h
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDRouterCenter.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    const char *pluginname;
    const char *classname;
} PDRouterPluginName;

/* Export plugin */
#define __PD_EXPORT_PLUGIN_EXT(pluginname, classname) \
__attribute__((used, section("__DATA , pd_exp_plugin"))) \
static const PDRouterPluginName __pd_exp_plugin_##pluginname##__ = {#pluginname, #classname};

#define PD_EXPORT_PLUGIN(classname) __PD_EXPORT_PLUGIN_EXT(classname, classname)

@interface PDRouter : NSObject

@property (class, strong, readonly) PDRouter *globalRouter;

@property (nonatomic, weak) __kindof UINavigationController *navigationController;

- (void)registerEventHandler:(PDRouterCenterEventHandler)eventHandler forPattern:(NSString *)pattern;

- (BOOL)openURL:(NSString *)URLString params:(NSDictionary * _Nullable)params;

@end

NS_ASSUME_NONNULL_END
