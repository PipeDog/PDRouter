//
//  PDRouter.h
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDRouteCenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDRouter : NSObject

@property (class, strong, readonly) PDRouter *globalRouter;

@property (nonatomic, strong) __kindof UINavigationController *navigationController;

- (void)registerClass:(Class)aClass forPattern:(NSString *)pattern;
- (void)registerEventHandler:(PDRouteCenterEventHandler)eventHandler forPattern:(NSString *)pattern;

- (BOOL)openURL:(NSString *)URLString routerParams:(nullable NSDictionary *)routerParams;

@end

NS_ASSUME_NONNULL_END
