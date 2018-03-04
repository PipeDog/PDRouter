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
@property (nonatomic, copy) NSString *localScheme; // Custom scheme, this property is used to determine whether native processing is done.

// Call these method to open native page or web page.
- (void)sendAction:(NSString *)action;
- (void)sendAction:(NSString *)action to:(nullable id)target;

- (void)on:(NSString *)event completionHandler:(PDRouterHandler)handler;
- (void)off:(NSString *)event;
- (void)offAll;

@end

NS_ASSUME_NONNULL_END
