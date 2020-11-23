//
//  PDRouterPlugin.h
//  PDRouter
//
//  Created by liang on 2019/5/29.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDRouter.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    const char *pluginname;
    const char *classname;
} PDRouterPluginName;

/* Export plugin */
#define __PD_EXPORT_PLUGIN_EXT(pluginname, classname) \
__attribute__((used, section("__DATA , pd_exp_plugin"))) \
static const PDRouterPluginName __pd_exp_plugin_##pluginname##__ = {#pluginname, #classname};

#define PD_EXPORT_PLUGIN(pluginname, classname) __PD_EXPORT_PLUGIN_EXT(pluginname, classname)

typedef NSInteger PDRouterPluginPriority;

@interface PDRouterPlugin : NSObject

@property (nonatomic, weak, nullable) __kindof UINavigationController *navigationController;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, weak) PDRouter *router;

- (PDRouterPluginPriority)priority;

- (void)load;

- (BOOL)openURL:(NSString *)urlString params:(NSDictionary * _Nullable)params;

@end

NS_ASSUME_NONNULL_END
