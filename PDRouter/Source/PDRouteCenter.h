//
//  PDRouteCenter.h
//  PDRouter
//
//  Created by liang on 2019/5/17.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PDRouteCenterEventHandler)(NSDictionary * _Nullable routerParams);

@protocol PDRouteCenterDelegate <NSObject>

@optional
- (BOOL)tryOpenUnregisteredURL:(NSString *)URLString routerParams:(nullable NSDictionary *)routerParams;
- (void)didFinishOpenURL:(NSString *)URLString routerParams:(nullable NSDictionary *)routerParams;
- (void)didFailOpenURL:(NSString *)URLString routerParams:(nullable NSDictionary *)routerParams;

@end

@interface PDRouteCenter : NSObject

@property (class, strong, readonly) PDRouteCenter *defaultCenter;

@property (nonatomic, weak) id<PDRouteCenterDelegate> delegate;

- (void)on:(NSString *)pattern eventHandler:(PDRouteCenterEventHandler)eventHandler;
- (BOOL)openURL:(NSString *)URLString routerParams:(nullable NSDictionary *)routerParams;

@end

NS_ASSUME_NONNULL_END
