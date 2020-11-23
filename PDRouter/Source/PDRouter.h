//
//  PDRouter.h
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDRouterDelegate <NSObject>

@optional
- (void)didFinishOpenURL:(NSString *)urlString params:(NSDictionary * _Nullable)params;
- (void)didFailOpenURL:(NSString *)urlString params:(NSDictionary * _Nullable)params;

@end

@interface PDRouter : NSObject

@property (class, strong, readonly) PDRouter *globalRouter;

@property (nonatomic, weak) __kindof UINavigationController *navigationController;
@property (nonatomic, weak) id<PDRouterDelegate> delegate;

- (void)inject:(NSString *)urlString eventHandler:(void (^)(NSDictionary * _Nullable params))eventHandler;
- (BOOL)openURL:(NSString *)urlString params:(NSDictionary * _Nullable)params;

@end

NS_ASSUME_NONNULL_END
