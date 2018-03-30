//
//  PDRouter.h
//  PDRouter
//
//  Created by liang on 2018/3/3.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PDRouterHandler)(id _Nullable sender, NSDictionary * _Nullable parameters);

@protocol PDRouterDelegate <NSObject>

- (BOOL)openURL:(NSURL *)url; // Handle the url of the unregistered event.

@end

@interface PDRouter : NSObject

@property (class, strong, readonly) PDRouter *defaultRouter;

@property (nonatomic, weak) id<PDRouterDelegate> delegate;
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *host;

- (BOOL)sendAction:(NSString *)action;
- (BOOL)sendAction:(NSString *)action from:(nullable id)sender;
- (BOOL)sendAction:(NSString *)action from:(nullable id)sender params:(nullable NSDictionary *)params;

- (void)on:(NSString *)event completionHandler:(PDRouterHandler)handler;
- (void)off:(NSString *)event;
- (void)offAll;

@end

NS_ASSUME_NONNULL_END
