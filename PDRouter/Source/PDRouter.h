//
//  PDRouter.h
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PDRouterEventHandler)(NSDictionary *routerParams);

/// Router throw events.
@protocol PDRouterDelegate <NSObject>

@optional
- (void)didFinishOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams;
- (void)didFailOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams;

@end

/// Group implement.
@protocol PDRouterGroup <NSObject>

@property (nonatomic, copy, readonly) NSDictionary<NSString *, PDRouterEventHandler> *listeners;

- (void)on:(NSString *)relativePath eventHandler:(PDRouterEventHandler)eventHandler;

@end

/// Router.
@interface PDRouter : NSObject

@property (class, strong, readonly) PDRouter *defaultRouter;

@property (nonatomic, weak) id<PDRouterDelegate> delegate;

@property (nonatomic, copy) NSString *host;

- (void)on:(NSString *)fullPath eventHandler:(PDRouterEventHandler)eventHandler;

- (void)onGroup:(NSString *)basePath eventHandler:(void (^)(id<PDRouterGroup> group))eventHandler;

- (BOOL)openURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams;

@end
