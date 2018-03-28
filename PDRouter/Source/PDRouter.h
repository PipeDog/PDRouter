//
//  PDRouter.h
//  PDRouter
//
//  Created by liang on 2018/3/3.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PDRouterProtocol.h"

@class PDRouterNode;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PDRouterHandler)(id _Nullable target, NSDictionary * _Nullable parameters);

@interface PDRouter : NSObject

@property (class, strong, readonly) PDRouter *defaultRouter;

@property (nonatomic, weak) id<PDRouterProtocol> delegate;

// Custom scheme and host, used to confirm whether a local event has been registered.
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *host;

// Send actions to trigger events, the param action is a link.
- (BOOL)sendAction:(NSString *)action;
- (BOOL)sendAction:(NSString *)action to:(nullable id)target;
- (BOOL)sendAction:(NSString *)action to:(nullable id)target params:(nullable NSDictionary *)params;

// Register event with eventname, match URL path with eventname.
- (void)on:(NSString *)event completionHandler:(PDRouterHandler)handler;
- (void)off:(NSString *)event; // Unregister event with eventname.
- (void)offAll; // Unregister all events.

@end

NS_ASSUME_NONNULL_END
