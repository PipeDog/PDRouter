//
//  PDRouter.h
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDRouterGroup.h"

@protocol PDRouterDelegate <NSObject>

@optional
- (void)didFinishOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams;
- (void)didFailOpenURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams;

@end

@interface PDRouter : NSObject

@property (class, strong, readonly) PDRouter *defaultRouter;

@property (nonatomic, weak) id<PDRouterDelegate> delegate;

@property (nonatomic, copy) NSString *host;

- (void)on:(NSString *)fullPath eventHandler:(PDRouterEventHandler)eventHandler;

- (void)onGroup:(NSString *)basePath eventHandler:(void (^)(PDRouterGroup *group))eventHandler;

- (BOOL)openURL:(NSString *)URLString routerParams:(NSDictionary *)routerParams;

@end
