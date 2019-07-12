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

typedef NSInteger PDRouterPluginPriority;

@interface PDRouterPlugin : NSObject

@property (nonatomic, weak, nullable) __kindof UINavigationController *navigationController;
@property (nonatomic, weak) PDRouter *router;

- (PDRouterPluginPriority)priority;

- (void)load;
- (void)unload;

- (BOOL)openURL:(NSString *)encodedURLString params:(NSDictionary * _Nullable)params;

@end

NS_ASSUME_NONNULL_END
