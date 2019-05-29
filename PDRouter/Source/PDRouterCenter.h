//
//  PDRouterCenter.h
//  PDRouter
//
//  Created by liang on 2019/5/17.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PDRouterCenterEventHandler)(NSDictionary * _Nullable routerParams);

@protocol PDRouterCenterDelegate <NSObject>

@optional
- (BOOL)tryOpenNotRecognizedURL:(NSString *)URLString params:(NSDictionary * _Nullable)params;
- (void)didFinishOpenURL:(NSString *)URLString params:(NSDictionary * _Nullable)params;
- (void)didFailOpenURL:(NSString *)URLString params:(NSDictionary * _Nullable)params;

@end

@interface PDRouterCenter : NSObject

@property (class, strong, readonly) PDRouterCenter *defaultCenter;

@property (nonatomic, weak) id<PDRouterCenterDelegate> delegate;

- (void)inject:(NSString *)pattern eventHandler:(PDRouterCenterEventHandler)eventHandler;
- (BOOL)openURL:(NSString *)URLString params:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
