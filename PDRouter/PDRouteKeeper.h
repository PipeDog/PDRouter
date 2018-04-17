//
//  PDRouteKeeper.h
//  PDRouter
//
//  Created by liang on 2018/4/17.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDRouteKeeper : NSObject <PDRouterDelegate>

@property (class, nonatomic, strong, readonly) PDRouteKeeper *defaultKeeper;

- (void)bind:(NSString *)pageName forEvent:(NSString *)event;
- (void)unbind:(NSString *)event;

- (BOOL)sendAction:(NSString *)action;
- (BOOL)sendAction:(NSString *)action params:(nullable NSDictionary *)params;
- (BOOL)sendAction:(NSString *)action params:(nullable NSDictionary *)params from:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
